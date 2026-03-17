import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/services/task_service.dart';

import 'unit_test.mocks.dart';

@GenerateMocks([TaskService])
void main() {
  // ── Task Model — Constructor & Properties ────────────────────────────────────

  group('Task Model — Constructor & Properties', () {
    late Task sampleTask;

    setUp(() {
      sampleTask = Task(
        id: 'abc',
        title: 'Buy milk',
        description: 'From the store',
        priority: Priority.high,
        dueDate: DateTime(2026, 4, 1),
        isCompleted: true,
      );
    });

    test('stores the id and title provided at construction', () {
      expect(sampleTask.id, 'abc');
      expect(sampleTask.title, 'Buy milk');
    });

    test('stores the dueDate provided at construction', () {
      expect(sampleTask.dueDate, DateTime(2026, 4, 1));
    });

    test('stores the priority provided at construction', () {
      expect(sampleTask.priority, Priority.high);
    });

    test('uses empty string as default description when none is provided', () {
      final task = Task(id: '1', title: 'T', dueDate: DateTime(2026, 4, 1));

      expect(task.description, '');
    });

    test('uses medium as default priority when none is provided', () {
      final task = Task(id: '1', title: 'T', dueDate: DateTime(2026, 4, 1));

      expect(task.priority, Priority.medium);
    });

    test('uses false as default isCompleted when none is provided', () {
      final task = Task(id: '1', title: 'T', dueDate: DateTime(2026, 4, 1));

      expect(task.isCompleted, isFalse);
    });
  });

  // ── Task Model — copyWith() ──────────────────────────────────────────────────

  group('Task Model — copyWith()', () {
    late Task original;

    setUp(() {
      original = Task(
        id: 'orig',
        title: 'Original',
        description: 'desc',
        priority: Priority.low,
        dueDate: DateTime(2026, 4, 1),
        isCompleted: false,
      );
    });

    test('returns a new task with only the specified field updated', () {
      final updated = original.copyWith(title: 'Updated');

      expect(updated.title, 'Updated');
      expect(updated.id, original.id);
      expect(updated.priority, original.priority);
    });

    test('returns a new task with all fields replaced when all are provided',
        () {
      final newDue = DateTime(2026, 12, 31);
      final updated = original.copyWith(
        id: 'new',
        title: 'New Title',
        description: 'new desc',
        priority: Priority.high,
        dueDate: newDue,
        isCompleted: true,
      );

      expect(updated.id, 'new');
      expect(updated.title, 'New Title');
      expect(updated.priority, Priority.high);
      expect(updated.dueDate, newDue);
      expect(updated.isCompleted, isTrue);
    });

    test('leaves the original task unchanged after copyWith is called', () {
      original.copyWith(title: 'Should not affect original');

      expect(original.title, 'Original');
    });
  });

  // ── Task Model — isOverdue getter ────────────────────────────────────────────

  group('Task Model — isOverdue getter', () {
    test('returns true when task is incomplete and due date is in the past', () {
      final task = Task(
        id: '1',
        title: 'T',
        dueDate: DateTime(2000, 1, 1),
        isCompleted: false,
      );

      expect(task.isOverdue, isTrue);
    });

    test('returns false when task is incomplete and due date is in the future',
        () {
      final task = Task(
        id: '1',
        title: 'T',
        dueDate: DateTime(2099, 1, 1),
        isCompleted: false,
      );

      expect(task.isOverdue, isFalse);
    });

    test('returns false when task is completed even if due date is in the past',
        () {
      final task = Task(
        id: '1',
        title: 'T',
        dueDate: DateTime(2000, 1, 1),
        isCompleted: true,
      );

      expect(task.isOverdue, isFalse);
    });
  });

  // ── Task Model — toJson() / fromJson() ───────────────────────────────────────

  group('Task Model — toJson() / fromJson()', () {
    late Task task;

    setUp(() {
      task = Task(
        id: 'x1',
        title: 'Test',
        description: 'Details',
        priority: Priority.high,
        dueDate: DateTime(2026, 6, 15),
        isCompleted: true,
      );
    });

    test('restores all fields correctly after a toJson and fromJson round-trip',
        () {
      final restored = Task.fromJson(task.toJson());

      expect(restored.id, task.id);
      expect(restored.title, task.title);
      expect(restored.description, task.description);
      expect(restored.priority, task.priority);
      expect(restored.dueDate, task.dueDate);
      expect(restored.isCompleted, task.isCompleted);
    });

    test('encodes priority as an integer index in the JSON map', () {
      final json = task.toJson();

      expect(json['priority'], isA<int>());
    });

    test('maps Priority.high to index 2 in the JSON representation', () {
      final json = task.toJson();

      expect(json['priority'], Priority.high.index);
    });
  });

  // ── TaskService — addTask() ──────────────────────────────────────────────────

  group('TaskService — addTask()', () {
    late TaskService service;
    late Task sampleTask;

    setUp(() {
      service = TaskService();
      sampleTask = Task(id: '1', title: 'My Task', dueDate: DateTime(2026, 4, 1));
    });

    test('adds the task so it appears in allTasks after a successful add', () {
      service.addTask(sampleTask);

      expect(service.allTasks, contains(sampleTask));
    });

    test('throws ArgumentError when the task title is empty or whitespace', () {
      final blankTask =
          Task(id: '2', title: '   ', dueDate: DateTime(2026, 4, 1));

      expect(() => service.addTask(blankTask), throwsA(isA<ArgumentError>()));
    });

    test('allows two tasks with the same id to coexist in the list', () {
      service.addTask(Task(id: 'dup', title: 'First', dueDate: DateTime(2026, 4, 1)));
      service.addTask(Task(id: 'dup', title: 'Second', dueDate: DateTime(2026, 4, 1)));

      expect(service.allTasks.length, 2);
    });
  });

  // ── TaskService — deleteTask() ───────────────────────────────────────────────

  group('TaskService — deleteTask()', () {
    late TaskService service;
    late Task sampleTask;

    setUp(() {
      service = TaskService();
      sampleTask = Task(id: 't1', title: 'Remove me', dueDate: DateTime(2026, 4, 1));
      service.addTask(sampleTask);
    });

    test('removes the task from allTasks when a matching id is found', () {
      service.deleteTask('t1');

      expect(service.allTasks, isEmpty);
    });

    test('does nothing and throws no error when the id does not exist', () {
      expect(() => service.deleteTask('ghost'), returnsNormally);
    });
  });

  // ── TaskService — toggleComplete() ──────────────────────────────────────────

  group('TaskService — toggleComplete()', () {
    late TaskService service;
    late Task sampleTask;

    setUp(() {
      service = TaskService();
      sampleTask = Task(id: 't1', title: 'Task', dueDate: DateTime(2026, 4, 1));
      service.addTask(sampleTask);
    });

    test('marks an incomplete task as completed when toggled', () {
      service.toggleComplete('t1');

      expect(service.allTasks.first.isCompleted, isTrue);
    });

    test('marks a completed task back to incomplete when toggled again', () {
      service.toggleComplete('t1');
      service.toggleComplete('t1');

      expect(service.allTasks.first.isCompleted, isFalse);
    });

    test('throws StateError when the given id does not match any task', () {
      expect(
        () => service.toggleComplete('missing'),
        throwsA(isA<StateError>()),
      );
    });
  });

  // ── TaskService — getByStatus() ──────────────────────────────────────────────

  group('TaskService — getByStatus()', () {
    late TaskService service;
    late Task activeTask;
    late Task completedTask;

    setUp(() {
      service = TaskService();
      activeTask = Task(id: 'a', title: 'Active', dueDate: DateTime(2026, 4, 1));
      completedTask = Task(id: 'c', title: 'Done', dueDate: DateTime(2026, 4, 1));
      service.addTask(activeTask);
      service.addTask(completedTask);
      service.toggleComplete('c');
    });

    test('returns only incomplete tasks when filtering by completed: false', () {
      final result = service.getByStatus(completed: false);

      expect(result.every((t) => !t.isCompleted), isTrue);
    });

    test('returns only completed tasks when filtering by completed: true', () {
      final result = service.getByStatus(completed: true);

      expect(result.every((t) => t.isCompleted), isTrue);
    });
  });

  // ── TaskService — sortByPriority() ───────────────────────────────────────────

  group('TaskService — sortByPriority()', () {
    late TaskService service;

    setUp(() {
      service = TaskService();
      service.addTask(Task(id: 'low', title: 'Low', priority: Priority.low, dueDate: DateTime(2026, 4, 1)));
      service.addTask(Task(id: 'high', title: 'High', priority: Priority.high, dueDate: DateTime(2026, 4, 1)));
      service.addTask(Task(id: 'med', title: 'Med', priority: Priority.medium, dueDate: DateTime(2026, 4, 1)));
    });

    test('places the highest priority task first in the sorted result', () {
      final sorted = service.sortByPriority();

      expect(sorted.first.id, 'high');
    });

    test('does not mutate the original allTasks list after sorting', () {
      final before = service.allTasks.map((t) => t.id).toList();
      service.sortByPriority();

      expect(service.allTasks.map((t) => t.id).toList(), before);
    });
  });

  // ── TaskService — sortByDueDate() ────────────────────────────────────────────

  group('TaskService — sortByDueDate()', () {
    late TaskService service;

    setUp(() {
      service = TaskService();
      service.addTask(Task(id: 'late', title: 'Late', dueDate: DateTime(2026, 12, 1)));
      service.addTask(Task(id: 'early', title: 'Early', dueDate: DateTime(2026, 1, 1)));
    });

    test('places the task with the earliest due date first in the sorted result',
        () {
      final sorted = service.sortByDueDate();

      expect(sorted.first.id, 'early');
    });

    test('does not mutate the original allTasks list after sorting', () {
      final before = service.allTasks.map((t) => t.id).toList();
      service.sortByDueDate();

      expect(service.allTasks.map((t) => t.id).toList(), before);
    });
  });

  // ── TaskService — statistics getter ─────────────────────────────────────────

  group('TaskService — statistics getter', () {
    late TaskService service;

    setUp(() => service = TaskService());

    test('returns zero for all counts when the service has no tasks', () {
      final stats = service.statistics;

      expect(stats['total'], 0);
      expect(stats['completed'], 0);
      expect(stats['overdue'], 0);
    });

    test('counts total and completed correctly when tasks have mixed status', () {
      service.addTask(Task(id: '1', title: 'A', dueDate: DateTime(2026, 4, 1)));
      service.addTask(Task(id: '2', title: 'B', dueDate: DateTime(2026, 4, 1)));
      service.addTask(Task(id: '3', title: 'C', dueDate: DateTime(2026, 4, 1)));
      service.toggleComplete('1');
      service.toggleComplete('2');

      final stats = service.statistics;

      expect(stats['total'], 3);
      expect(stats['completed'], 2);
    });

    test('counts only incomplete past-due tasks in the overdue total', () {
      service.addTask(Task(id: 'od', title: 'Overdue', dueDate: DateTime(2000, 1, 1)));
      service.addTask(Task(id: 'cp', title: 'Done past', dueDate: DateTime(2000, 1, 1)));
      service.toggleComplete('cp');
      service.addTask(Task(id: 'fu', title: 'Future', dueDate: DateTime(2099, 1, 1)));

      final stats = service.statistics;

      expect(stats['overdue'], 1);
    });
  });

  // ── TaskProvider — tasks getter (mocked service) ─────────────────────────────

  group('TaskProvider — tasks getter (mocked service)', () {
    late MockTaskService mockService;
    late TaskProvider provider;
    late Task sampleTask;

    setUp(() {
      mockService = MockTaskService();
      provider = TaskProvider(service: mockService);
      sampleTask = Task(id: '1', title: 'Task 1', dueDate: DateTime(2026, 3, 20));
    });

    test('returns tasks sorted by earliest due date first by default', () {
      final early = sampleTask.copyWith(id: 'early', dueDate: DateTime(2026, 3, 18));
      final late_ = sampleTask.copyWith(id: 'late', dueDate: DateTime(2026, 3, 25));
      when(mockService.allTasks).thenReturn([late_, early]);

      expect(provider.tasks.map((t) => t.id), ['early', 'late']);
    });

    test('returns tasks sorted by highest priority first when sort mode is priority', () {
      final low = sampleTask.copyWith(id: 'low', priority: Priority.low);
      final high = sampleTask.copyWith(id: 'high', priority: Priority.high);
      when(mockService.allTasks).thenReturn([low, high]);

      provider.setSortMode(SortMode.priority);

      expect(provider.tasks.map((t) => t.id), ['high', 'low']);
    });

    test('calls getByStatus(completed: false) when filter is set to active', () {
      final active = sampleTask.copyWith(id: 'active', isCompleted: false);
      when(mockService.getByStatus(completed: false)).thenReturn([active]);

      provider.setFilter(FilterStatus.active);

      expect(provider.tasks.map((t) => t.id), ['active']);
      verify(mockService.getByStatus(completed: false)).called(1);
    });

    test('calls getByStatus(completed: true) when filter is set to completed', () {
      final done = sampleTask.copyWith(id: 'done', isCompleted: true);
      when(mockService.getByStatus(completed: true)).thenReturn([done]);

      provider.setFilter(FilterStatus.completed);

      expect(provider.tasks.map((t) => t.id), ['done']);
      verify(mockService.getByStatus(completed: true)).called(1);
    });
  });

  // ── TaskProvider — mutations (mocked service) ────────────────────────────────

  group('TaskProvider — mutations (mocked service)', () {
    late MockTaskService mockService;
    late TaskProvider provider;
    late Task sampleTask;

    setUp(() {
      mockService = MockTaskService();
      provider = TaskProvider(service: mockService);
      sampleTask = Task(id: '1', title: 'T', dueDate: DateTime(2026, 4, 1));
    });

    test('delegates to service.addTask and notifies listeners when a task is added', () {
      when(mockService.allTasks).thenReturn([sampleTask]);

      var notified = false;
      provider.addListener(() => notified = true);
      provider.addTask(sampleTask);

      verify(mockService.addTask(sampleTask)).called(1);
      expect(notified, isTrue);
    });

    test('delegates to service.deleteTask and notifies listeners when a task is deleted', () {
      var notified = false;
      provider.addListener(() => notified = true);
      provider.deleteTask('abc');

      verify(mockService.deleteTask('abc')).called(1);
      expect(notified, isTrue);
    });

    test('delegates to service.toggleComplete and notifies listeners when a task is toggled', () {
      var notified = false;
      provider.addListener(() => notified = true);
      provider.toggleComplete('abc');

      verify(mockService.toggleComplete('abc')).called(1);
      expect(notified, isTrue);
    });

    test('returns the statistics map provided by the service', () {
      final stats = {'total': 3, 'completed': 2, 'overdue': 1};
      when(mockService.statistics).thenReturn(stats);

      expect(provider.statistics, equals(stats));
    });
  });
}
