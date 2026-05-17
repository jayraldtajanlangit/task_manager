import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    return Scaffold(
      key: const Key('task_list_scaffold'),
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          PopupMenuButton<SortMode>(
            key: const Key('sort_menu'),
            onSelected: provider.setSortMode,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: SortMode.priority,
                child: Text('Sort by Priority'),
              ),
              PopupMenuItem(
                value: SortMode.dueDate,
                child: Text('Sort by Due Date'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _StatsBar(stats: provider.statistics),
          _FilterChips(current: provider.filter, onChanged: provider.setFilter),
          Expanded(
            child: provider.tasks.isEmpty
                ? const Center(
                    key: Key('empty_state'),
                    child: Text('No tasks yet. Tap + to add one!'),
                  )
                : ListView.builder(
                    key: const Key('task_list'),
                    itemCount: provider.tasks.length,
                    itemBuilder: (_, i) {
                      final task = provider.tasks[i];
                      return TaskTile(
                        task: task,
                        onToggle: () => provider.toggleComplete(task.id),
                        onDelete: () => provider.deleteTask(task.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_task_fab'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTaskScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ── Stats bar ────────────────────────────────────────────────────────
class _StatsBar extends StatelessWidget {
  final Map<String, int> stats;
  const _StatsBar({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('stats_bar'),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatChip(
            label: 'Total',
            value: stats['total'] ?? 0,
            key: const Key('stat_total'),
          ),
          _StatChip(
            label: 'Done',
            value: stats['completed'] ?? 0,
            key: const Key('stat_completed'),
          ),
          _StatChip(
            label: 'Overdue',
            value: stats['overdue'] ?? 0,
            key: const Key('stat_overdue'),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  const _StatChip({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(label),
      ],
    );
  }
}

// ── Filter chips ─────────────────────────────────────────────────────
class _FilterChips extends StatelessWidget {
  final FilterStatus current;
  final ValueChanged<FilterStatus> onChanged;
  const _FilterChips({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const Key('filter_chips'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: FilterStatus.values.map((f) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: FilterChip(
            key: Key('filter_${f.name}'),
            label: Text(f.name.toUpperCase()),
            selected: current == f,
            onSelected: (_) => onChanged(f),
          ),
        );
      }).toList(),
    );
  }
}
