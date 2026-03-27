import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:signalr_core/signalr_core.dart';

import '../models/task_item.dart';

class TaskSignalRService {
  TaskSignalRService({required this.hubUrl});

  final String hubUrl;
  final StreamController<TaskItem> _incomingTaskController =
      StreamController<TaskItem>.broadcast();

  HubConnection? _connection;
  bool _isConnecting = false;

  Stream<TaskItem> get incomingTasks => _incomingTaskController.stream;

  Future<void> start() async {
    final connection = _connection;
    if (connection != null &&
        connection.state != HubConnectionState.disconnected) {
      return;
    }

    if (_isConnecting) {
      return;
    }

    _isConnecting = true;
    try {
      final hubConnection = connection ?? _buildConnection();
      await hubConnection.start();
    } catch (error, stackTrace) {
      debugPrint('SignalR start failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> stop() async {
    if (_connection == null) {
      return;
    }

    try {
      await _connection!.stop();
    } catch (error, stackTrace) {
      debugPrint('SignalR stop failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> sendTask(TaskItem task) async {
    final connection = _connection;
    if (connection == null || connection.state != HubConnectionState.connected) {
      await start();
    }

    final activeConnection = _connection;
    if (activeConnection == null ||
        activeConnection.state != HubConnectionState.connected) {
      throw StateError('SignalR connection is not available.');
    }

    try {
      await activeConnection.invoke('AddTask', args: [task.toJsonMap()]);
    } catch (error, stackTrace) {
      debugPrint('SignalR send task failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> dispose() async {
    await stop();
    await _incomingTaskController.close();
  }

  HubConnection _buildConnection() {
    final connection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          HttpConnectionOptions(
            logging: (level, message) {
              debugPrint('SignalR [$level]: $message');
            },
          ),
        )
        .withAutomaticReconnect(retryDelays: [0, 2000, 5000, 10000])
        .build();

    connection.on('TaskAdded', _onTaskAdded);
    connection.onclose((error) {
      if (error != null) {
        debugPrint('SignalR disconnected: $error');
      }
    });
    connection.onreconnecting((error) {
      debugPrint('SignalR reconnecting: ${error ?? 'unknown reason'}');
    });
    connection.onreconnected((connectionId) {
      debugPrint('SignalR reconnected. ConnectionId: $connectionId');
    });

    _connection = connection;
    return connection;
  }

  void _onTaskAdded(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) {
      return;
    }

    final rawTask = arguments.first;
    final task = _parseTask(rawTask);

    if (task == null) {
      debugPrint('SignalR TaskAdded payload could not be parsed.');
      return;
    }

    _incomingTaskController.add(task);
  }

  TaskItem? _parseTask(Object? rawTask) {
    if (rawTask is Map<String, dynamic>) {
      return TaskItem.fromJsonMap(rawTask);
    }

    if (rawTask is Map) {
      final normalized = <String, dynamic>{};
      for (final entry in rawTask.entries) {
        normalized[entry.key.toString()] = entry.value;
      }
      return TaskItem.fromJsonMap(normalized);
    }

    if (rawTask is String) {
      final decoded = jsonDecode(rawTask);
      if (decoded is Map<String, dynamic>) {
        return TaskItem.fromJsonMap(decoded);
      }
      if (decoded is Map) {
        final normalized = <String, dynamic>{};
        for (final entry in decoded.entries) {
          normalized[entry.key.toString()] = entry.value;
        }
        return TaskItem.fromJsonMap(normalized);
      }
    }

    return null;
  }
}
