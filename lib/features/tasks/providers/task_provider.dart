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

  List<TaskItem> get tasks => dailyBoardTasks;

  List<TaskItem> get dailyBoardTasks {
    return List.unmodifiable(allTasks.where((task) => !task.status.isDone));
  }

  List<TaskItem> get activeTasks {
    return List.unmodifiable(allTasks.where((task) => !task.status.isDone));
  }

  Map<DateTime, List<TaskItem>> get groupedTasks {
    final groups = <DateTime, List<TaskItem>>{};

    for (final task in dailyBoardTasks) {
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

  int get pendingCount => dailyBoardTasks.length;

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
        date: DateTime(date.year, date.month, date.day),
        responsible: responsible,
        hours: hours,
        status: TaskStatus.todo,
        projectId: projectId,
      ),
    );
    _refreshTasks();
  }

  void updateTaskDetails({
    required TaskItem task,
    required String name,
    required TaskType type,
    required String description,
    required DateTime date,
    required String responsible,
    required double hours,
    String? projectId,
  }) {
    _taskService.updateTask(
      task.copyWith(
        name: name,
        type: type,
        description: description,
        date: DateTime(date.year, date.month, date.day),
        responsible: responsible,
        hours: hours,
        projectId: projectId,
        clearProjectId: projectId == null,
      ),
    );
    _refreshTasks();
  }

  void completeTask(
    TaskItem task, {
    required double hours,
    required DateTime startedOn,
    DateTime? completedOn,
  }) {
    updateTaskStatus(
      task,
      TaskStatus.done,
      hours: hours,
      startedOn: startedOn,
      completedOn: completedOn ?? DateTime.now(),
    );
  }

  void updateTaskStatus(
    TaskItem task,
    TaskStatus status, {
    double? hours,
    DateTime? startedOn,
    DateTime? completedOn,
  }) {
    final normalizedStartedOn = startedOn == null
        ? null
        : DateTime(startedOn.year, startedOn.month, startedOn.day);
    final normalizedCompletedOn = completedOn == null
        ? null
        : DateTime(completedOn.year, completedOn.month, completedOn.day);

    _taskService.updateTask(
      task.copyWith(
        status: status,
        hours: hours,
        startedOn: status == TaskStatus.todo
            ? normalizedStartedOn
            : normalizedStartedOn ?? task.startedOn,
        completedOn: status == TaskStatus.done ? normalizedCompletedOn : null,
        clearCompletedOn: status != TaskStatus.done,
      ),
    );
    _refreshTasks();
  }

  void _refreshTasks() {
    _allTasks = _taskService.fetchTasks();
    notifyListeners();
  }

  String _buildTaskId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return 'task-$now';
  }
}
