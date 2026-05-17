import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/task_service.dart';

enum FilterStatus { all, active, completed }

enum SortMode { priority, dueDate }

class TaskProvider extends ChangeNotifier {
  final TaskService _service;

  TaskProvider({TaskService? service}) : _service = service ?? TaskService();

  FilterStatus _filter = FilterStatus.all;
  SortMode _sortMode = SortMode.dueDate;

  FilterStatus get filter => _filter;
  SortMode get sortMode => _sortMode;

  List<Task> get tasks {
    List<Task> base;
    switch (_filter) {
      case FilterStatus.active:
        base = _service.getByStatus(completed: false);
        break;
      case FilterStatus.completed:
        base = _service.getByStatus(completed: true);
        break;
      case FilterStatus.all:
        base = List<Task>.from(_service.allTasks);
    }
    return _sortMode == SortMode.priority
        ? _sortedByPriority(base)
        : _sortedByDueDate(base);
  }

  Map<String, int> get statistics => _service.statistics;

  void addTask(Task task) {
    _service.addTask(task);
    notifyListeners();
  }

  void deleteTask(String id) {
    _service.deleteTask(id);
    notifyListeners();
  }

  void toggleComplete(String id) {
    _service.toggleComplete(id);
    notifyListeners();
  }

  void setFilter(FilterStatus filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSortMode(SortMode mode) {
    _sortMode = mode;
    notifyListeners();
  }

  List<Task> _sortedByPriority(List<Task> list) {
    final sorted = List<Task>.from(list);
    sorted.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    return sorted;
  }

  List<Task> _sortedByDueDate(List<Task> list) {
    final sorted = List<Task>.from(list);
    sorted.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return sorted;
  }
}
