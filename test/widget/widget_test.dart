import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/screens/task_list_screen.dart';
import 'package:task_manager/widgets/task_tile.dart';

import 'widget_test.mocks.dart';

@GenerateMocks([TaskProvider])
void main() {
  // ── Shared helpers ───────────────────────────────────────────────────────────

  Task makeTask({String id = 'test-id', bool isCompleted = false}) => Task(
    id: id,
    title: 'Sample Task',
    priority: Priority.high,
    dueDate: DateTime(2026, 4, 1),
    isCompleted: isCompleted,
  );

  Widget buildTile({
    required Task task,
    VoidCallback? onToggle,
    VoidCallback? onDelete,
  }) => MaterialApp(
    home: Scaffold(
      body: TaskTile(
        task: task,
        onToggle: onToggle ?? () {},
        onDelete: onDelete ?? () {},
      ),
    ),
  );

  // ── TaskTile — Rendering ─────────────────────────────────────────────────────

  group('TaskTile — Rendering', () {
    testWidgets('displays the task title as text', (tester) async {
      await tester.pumpWidget(buildTile(task: makeTask()));

      expect(find.text('Sample Task'), findsOneWidget);
    });

    testWidgets('displays the priority label in uppercase', (tester) async {
      await tester.pumpWidget(buildTile(task: makeTask()));

      expect(find.text('HIGH'), findsOneWidget);
    });

    testWidgets('checkbox value reflects the isCompleted state of the task', (
      tester,
    ) async {
      await tester.pumpWidget(buildTile(task: makeTask(isCompleted: true)));

      final cb = tester.widget<Checkbox>(
        find.byKey(const Key('checkbox_test-id')),
      );
      expect(cb.value, isTrue);
    });

    testWidgets('delete icon button is present in the tile', (tester) async {
      await tester.pumpWidget(buildTile(task: makeTask()));

      expect(find.byKey(const Key('delete_test-id')), findsOneWidget);
    });
  });

  // ── TaskTile — Checkbox Interaction ──────────────────────────────────────────

  group('TaskTile — Checkbox Interaction', () {
    testWidgets('calls onToggle when the checkbox is tapped', (tester) async {
      var toggled = false;
      await tester.pumpWidget(
        buildTile(task: makeTask(), onToggle: () => toggled = true),
      );

      await tester.tap(find.byKey(const Key('checkbox_test-id')));
      await tester.pump();

      expect(toggled, isTrue);
    });

    testWidgets('calls onToggle exactly once per tap', (tester) async {
      var callCount = 0;
      await tester.pumpWidget(
        buildTile(task: makeTask(), onToggle: () => callCount++),
      );

      await tester.tap(find.byKey(const Key('checkbox_test-id')));
      await tester.pump();

      expect(callCount, 1);
    });
  });

  // ── TaskTile — Delete Interaction ─────────────────────────────────────────────

  group('TaskTile — Delete Interaction', () {
    testWidgets('calls onDelete when the delete icon button is tapped', (
      tester,
    ) async {
      var deleted = false;
      await tester.pumpWidget(
        buildTile(task: makeTask(), onDelete: () => deleted = true),
      );

      await tester.tap(find.byKey(const Key('delete_test-id')));
      await tester.pump();

      expect(deleted, isTrue);
    });

    testWidgets('calls onDelete exactly once per tap', (tester) async {
      var callCount = 0;
      await tester.pumpWidget(
        buildTile(task: makeTask(), onDelete: () => callCount++),
      );

      await tester.tap(find.byKey(const Key('delete_test-id')));
      await tester.pump();

      expect(callCount, 1);
    });
  });

  // ── TaskTile — Completed State UI ────────────────────────────────────────────

  group('TaskTile — Completed State UI', () {
    testWidgets('title has LineThrough decoration when task is completed', (
      tester,
    ) async {
      await tester.pumpWidget(buildTile(task: makeTask(isCompleted: true)));

      final text = tester.widget<Text>(find.byKey(const Key('title_test-id')));
      expect(text.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('title has no decoration when task is active', (tester) async {
      await tester.pumpWidget(buildTile(task: makeTask(isCompleted: false)));

      final text = tester.widget<Text>(find.byKey(const Key('title_test-id')));
      expect(text.style?.decoration, TextDecoration.none);
    });
  });

  // ── TaskTile — Key Assertions ────────────────────────────────────────────────

  group('TaskTile — Key Assertions', () {
    testWidgets('tile key is a ValueKey that matches task.id', (tester) async {
      await tester.pumpWidget(buildTile(task: makeTask(id: 'test-id')));

      expect(find.byKey(const ValueKey('test-id')), findsOneWidget);
    });

    testWidgets('checkbox and delete button use the correct keys', (
      tester,
    ) async {
      await tester.pumpWidget(buildTile(task: makeTask(id: 'test-id')));

      expect(find.byKey(const Key('checkbox_test-id')), findsOneWidget);
      expect(find.byKey(const Key('delete_test-id')), findsOneWidget);
    });
  });

  // ── TaskListScreen (MockTaskProvider) ───────────────────────────────────────

  group('TaskListScreen', () {
    late MockTaskProvider mockProvider;

    Task makeScreenTask({String id = 'task-1', String title = 'Test Task'}) =>
        Task(
          id: id,
          title: title,
          priority: Priority.medium,
          dueDate: DateTime(2026, 4, 1),
        );

    setUp(() {
      mockProvider = MockTaskProvider();
      when(mockProvider.tasks).thenReturn([]);
      when(
        mockProvider.statistics,
      ).thenReturn({'total': 0, 'completed': 0, 'overdue': 0});
      when(mockProvider.filter).thenReturn(FilterStatus.all);
      when(mockProvider.sortMode).thenReturn(SortMode.dueDate);
    });

    Widget buildScreen() => MaterialApp(
      home: ChangeNotifierProvider<TaskProvider>.value(
        value: mockProvider,
        child: const TaskListScreen(),
      ),
    );

    testWidgets('shows empty state when no tasks', (tester) async {
      await tester.pumpWidget(buildScreen());

      expect(find.byKey(const Key('empty_state')), findsOneWidget);
      expect(find.text('No tasks yet. Tap + to add one!'), findsOneWidget);
    });

    testWidgets('shows task list when tasks exist', (tester) async {
      when(mockProvider.tasks).thenReturn([makeScreenTask()]);

      await tester.pumpWidget(buildScreen());

      expect(find.byKey(const Key('task_list')), findsOneWidget);
      expect(find.text('Test Task'), findsOneWidget);
    });

    testWidgets('displays stats bar with correct counts', (tester) async {
      when(
        mockProvider.statistics,
      ).thenReturn({'total': 5, 'completed': 3, 'overdue': 1});

      await tester.pumpWidget(buildScreen());

      expect(find.text('5'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('shows a filter chip for every FilterStatus', (tester) async {
      await tester.pumpWidget(buildScreen());

      for (final f in FilterStatus.values) {
        expect(find.byKey(Key('filter_${f.name}')), findsOneWidget);
      }
    });

    testWidgets('tapping a filter chip calls setFilter', (tester) async {
      await tester.pumpWidget(buildScreen());

      await tester.tap(find.byKey(const Key('filter_completed')));
      await tester.pump();

      verify(mockProvider.setFilter(FilterStatus.completed)).called(1);
    });

    testWidgets('FAB is present on screen', (tester) async {
      await tester.pumpWidget(buildScreen());

      expect(find.byKey(const Key('add_task_fab')), findsOneWidget);
    });

    testWidgets('tapping task checkbox calls toggleComplete', (tester) async {
      when(mockProvider.tasks).thenReturn([makeScreenTask(id: 'task-1')]);

      await tester.pumpWidget(buildScreen());
      await tester.tap(find.byKey(const Key('checkbox_task-1')));
      await tester.pump();

      verify(mockProvider.toggleComplete('task-1')).called(1);
    });

    testWidgets('tapping delete icon calls deleteTask', (tester) async {
      when(mockProvider.tasks).thenReturn([makeScreenTask(id: 'task-1')]);

      await tester.pumpWidget(buildScreen());
      await tester.tap(find.byKey(const Key('delete_task-1')));
      await tester.pump();

      verify(mockProvider.deleteTask('task-1')).called(1);
    });
  });
}
