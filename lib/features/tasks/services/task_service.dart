import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/task_item.dart';
import 'task_signalr_service.dart';

class TaskService {
  TaskService({TaskSignalRService? realtimeService})
      : _realtimeService = realtimeService;

  final TaskSignalRService? _realtimeService;
  final StreamController<TaskItem> _remoteTaskAddedController =
      StreamController<TaskItem>.broadcast();

  StreamSubscription<TaskItem>? _incomingSubscription;
  bool _isRealtimeInitialized = false;

  final List<TaskItem> _tasks = [
    TaskItem(
      id: 'task-1001',
      name: 'Finalize sprint roadmap',
      type: TaskType.urgent,
      description: 'Align product scope, dependencies, and timeline for the next release.',
      date: DateTime.now().subtract(const Duration(days: 1)),
      responsible: 'Alicia',
      hours: 2,
      status: TaskStatus.inProgress,
      projectId: 'proj-product',
      startedOn: DateTime.now().subtract(const Duration(days: 1)),
    ),
    TaskItem(
      id: 'task-1002',
      name: 'Prepare onboarding checklist',
      type: TaskType.normal,
      description: 'Create a welcome checklist for new team members joining next week.',
      date: DateTime.now().add(const Duration(days: 1)),
      responsible: 'Marcus',
      hours: 1.5,
      status: TaskStatus.todo,
      projectId: 'proj-operations',
    ),
    TaskItem(
      id: 'task-1003',
      name: 'Archive old design files',
      type: TaskType.noPriority,
      description: 'Clean outdated mockups and move relevant assets to shared storage.',
      date: DateTime.now().add(const Duration(days: 2)),
      responsible: 'Taylor',
      hours: 0.75,
      status: TaskStatus.todo,
    ),
    TaskItem(
      id: 'task-1004',
      name: 'Retrospective notes',
      type: TaskType.normal,
      description: 'Summarize lessons learned and follow-up actions for the latest sprint.',
      date: DateTime.now().subtract(const Duration(days: 6)),
      responsible: 'Morgan',
      hours: 1.25,
      status: TaskStatus.done,
      projectId: 'proj-product',
      startedOn: DateTime.now().subtract(const Duration(days: 7)),
      completedOn: DateTime.now().subtract(const Duration(days: 4)),
    ),
    TaskItem(
      id: 'task-1005',
      name: 'Review client feedback',
      type: TaskType.urgent,
      description: 'Consolidate the latest feedback received from the pilot customers.',
      date: DateTime.now().add(const Duration(days: 12)),
      responsible: 'Jordan',
      hours: 3,
      status: TaskStatus.todo,
      projectId: 'proj-product',
    ),
    TaskItem(
      id: 'task-1006',
      name: 'Budget reconciliation',
      type: TaskType.normal,
      description: 'Validate expense lines and close the operational budget for the month.',
      date: DateTime.now().subtract(const Duration(days: 18)),
      responsible: 'Sam',
      hours: 2.5,
      status: TaskStatus.done,
      projectId: 'proj-operations',
      startedOn: DateTime.now().subtract(const Duration(days: 20)),
      completedOn: DateTime.now().subtract(const Duration(days: 16)),
    ),
  ];

  Stream<TaskItem> get remoteTaskAddedStream => _remoteTaskAddedController.stream;

  List<TaskItem> fetchTasks() {
    return List.unmodifiable(_tasks);
  }

  Future<void> initializeRealtime() async {
    if (_isRealtimeInitialized || _realtimeService == null) {
      return;
    }

    _isRealtimeInitialized = true;
    _incomingSubscription = _realtimeService!.incomingTasks.listen(
      _handleIncomingTask,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Task stream listener failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      },
    );

    try {
      await _realtimeService!.start();
    } catch (error, stackTrace) {
      debugPrint('Task realtime initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> addTask(TaskItem task) async {
    _tasks.add(task);

    if (_realtimeService == null) {
      return;
    }

    try {
      await _realtimeService!.sendTask(task);
    } catch (error, stackTrace) {
      debugPrint('Failed to sync task to server: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void updateTask(TaskItem updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index == -1) {
      return;
    }

    _tasks[index] = updatedTask;
  }

  Future<void> dispose() async {
    await _incomingSubscription?.cancel();
    await _remoteTaskAddedController.close();
    await _realtimeService?.dispose();
  }

  void _handleIncomingTask(TaskItem incomingTask) {
    final existingIndex = _tasks.indexWhere((task) => task.id == incomingTask.id);
    if (existingIndex != -1) {
      _tasks[existingIndex] = incomingTask;
      return;
    }

    _tasks.add(incomingTask);
    _remoteTaskAddedController.add(incomingTask);
  }
}
