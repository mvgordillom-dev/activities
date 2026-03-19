import 'package:flutter/material.dart';

import '../models/task_item.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider(this._taskService);

  final TaskService _taskService;
  List<TaskItem> _allTasks = const [];

  List<TaskItem> get allTasks {
    final sorted = [..._allTasks]..sort((first, second) => first.date.compareTo(second.date));
    return List.unmodifiable(sorted);
  }

  List<TaskItem> get activeTasks {
    return List.unmodifiable(allTasks.where((task) => !task.completed));
  }

  Map<DateTime, List<TaskItem>> get groupedTasks {
    final groups = <DateTime, List<TaskItem>>{};

    for (final task in activeTasks) {
      final key = DateTime(task.date.year, task.date.month, task.date.day);
      groups.putIfAbsent(key, () => []).add(task);
    }

    final entries = groups.entries.toList()
      ..sort((first, second) => first.key.compareTo(second.key));

    return Map.fromEntries(entries);
  }

  List<DateTime> get availableReportMonths {
    final uniqueMonths = {
      for (final task in allTasks) DateTime(task.date.year, task.date.month),
    }.toList()
      ..sort((first, second) => second.compareTo(first));

    return uniqueMonths;
  }

  int get completedCount => allTasks.where((task) => task.completed).length;

  int get pendingCount => allTasks.where((task) => !task.completed).length;

  void loadInitialTasks() {
    _allTasks = _taskService.fetchTasks();
    notifyListeners();
  }

  List<TaskItem> tasksForMonth(DateTime month) {
    return allTasks
        .where((task) => task.date.year == month.year && task.date.month == month.month)
        .toList(growable: false);
  }

  int taskCountForProject(String? projectId) {
    return allTasks.where((task) => task.projectId == projectId).length;
  }

  int activeTaskCountForProject(String? projectId) {
    return activeTasks.where((task) => task.projectId == projectId).length;
  }

  void addTask({
    required String name,
    required TaskType type,
    required String description,
    required DateTime date,
    required String responsible,
    String? projectId,
  }) {
    _taskService.addTask(
      TaskItem(
        id: _buildTaskId(),
        name: name,
        type: type,
        description: description,
        date: date,
        responsible: responsible,
        completed: false,
        projectId: projectId,
      ),
    );
    _allTasks = _taskService.fetchTasks();
    notifyListeners();
  }

  void completeTask(TaskItem task) {
    _taskService.completeTask(task.id);
    _allTasks = _taskService.fetchTasks();
    notifyListeners();
  }

  String _buildTaskId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return 'task-$now';
  }
}
