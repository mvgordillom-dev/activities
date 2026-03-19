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

  List<TaskItem> get tasks {
    return List.unmodifiable(allTasks.where((task) => !task.completed));
  }

  Map<DateTime, List<TaskItem>> get groupedTasks {
    final groups = <DateTime, List<TaskItem>>{};

    for (final task in tasks) {
      final key = DateTime(task.date.year, task.date.month, task.date.day);
      groups.putIfAbsent(key, () => []).add(task);
    }

    return Map.fromEntries(
      groups.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  List<DateTime> get availableReportMonths {
    final uniqueMonths = {
      for (final task in allTasks) DateTime(task.date.year, task.date.month),
    }.toList()
      ..sort((first, second) => second.compareTo(first));

    return uniqueMonths;
  }

  List<TaskItem> tasksForMonth(DateTime month) {
    return allTasks
        .where((task) => task.date.year == month.year && task.date.month == month.month)
        .toList(growable: false);
  }

  void loadInitialTasks() {
    _allTasks = _taskService.fetchTasks();
    notifyListeners();
  }

  void addTask(TaskItem task) {
    _taskService.addTask(task);
    _allTasks = _taskService.fetchTasks();
    notifyListeners();
  }

  void completeTask(TaskItem task) {
    _taskService.completeTask(task);
    _allTasks = _taskService.fetchTasks();
    notifyListeners();
  }
}
