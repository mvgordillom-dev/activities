import 'package:flutter/material.dart';

import '../models/task_item.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider(this._taskService);

  final TaskService _taskService;
  List<TaskItem> _tasks = const [];

  List<TaskItem> get tasks {
    final sorted = [..._tasks]..sort((first, second) => first.date.compareTo(second.date));
    return List.unmodifiable(sorted);
  }

  Map<DateTime, List<TaskItem>> get groupedTasks {
    final groups = <DateTime, List<TaskItem>>{};

    for (final task in tasks.where((task) => !task.completed)) {
      final key = DateTime(task.date.year, task.date.month, task.date.day);
      groups.putIfAbsent(key, () => []).add(task);
    }

    return Map.fromEntries(
      groups.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  void loadInitialTasks() {
    _tasks = _taskService.fetchTasks();
    notifyListeners();
  }

  void addTask(TaskItem task) {
    _taskService.addTask(task);
    _tasks = _taskService.fetchTasks();
    notifyListeners();
  }

  void completeTask(TaskItem task) {
    _taskService.completeTask(task);
    _tasks = _taskService.fetchTasks();
    notifyListeners();
  }
}
