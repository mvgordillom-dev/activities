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

  List<TaskItem> get tasks => activeTasks;

  List<TaskItem> get activeTasks {
    return List.unmodifiable(allTasks.where((task) => !task.status.isDone));
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

  int get completedCount => allTasks.where((task) => task.status.isDone).length;

  int get pendingCount => allTasks.where((task) => !task.status.isDone).length;

  double get totalLoggedHours =>
      allTasks.fold<double>(0.0, (total, task) => total + task.hours);

  void loadInitialTasks() {
    _allTasks = _taskService.fetchTasks();
    notifyListeners();
  }

  List<TaskItem> tasksForMonth(DateTime month) {
    return allTasks
        .where((task) => task.date.year == month.year && task.date.month == month.month)
        .toList(growable: false);
  }

  List<TaskItem> tasksForProject(String? projectId) {
    final filtered = allTasks.where((task) => task.projectId == projectId).toList()
      ..sort((first, second) => first.date.compareTo(second.date));
    return List.unmodifiable(filtered);
  }

  List<TaskItem> tasksForProjectAndStatus(String? projectId, TaskStatus status) {
    return tasksForProject(projectId)
        .where((task) => task.status == status)
        .toList(growable: false);
  }

  int taskCountForProject(String? projectId) {
    return allTasks.where((task) => task.projectId == projectId).length;
  }

  int activeTaskCountForProject(String? projectId) {
    return activeTasks.where((task) => task.projectId == projectId).length;
  }

  double loggedHoursForProject(String? projectId) {
    return allTasks
        .where((task) => task.projectId == projectId)
        .fold<double>(0.0, (total, task) => total + task.hours);
  }

  void addTask({
    required String name,
    required TaskType type,
    required String description,
    required DateTime date,
    required String responsible,
    required double hours,
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
        hours: hours,
        status: TaskStatus.todo,
        projectId: projectId,
      ),
    );
    _allTasks = _taskService.fetchTasks();
    notifyListeners();
  }

  void completeTask(TaskItem task) {
    updateTaskStatus(task, TaskStatus.done);
  }

  void updateTaskStatus(TaskItem task, TaskStatus status) {
    _taskService.updateTaskStatus(task.id, status);
    _allTasks = _taskService.fetchTasks();
    notifyListeners();
  }

  String _buildTaskId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return 'task-$now';
  }
}
