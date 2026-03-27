enum TaskType { urgent, normal, noPriority }

enum TaskStatus { todo, inProgress, done }

extension TaskTypeX on TaskType {
  String get label {
    switch (this) {
      case TaskType.urgent:
        return 'Urgent';
      case TaskType.normal:
        return 'Normal';
      case TaskType.noPriority:
        return 'No Priority';
    }
  }

  String get apiValue {
    switch (this) {
      case TaskType.urgent:
        return 'urgent';
      case TaskType.normal:
        return 'normal';
      case TaskType.noPriority:
        return 'noPriority';
    }
  }
}

extension TaskStatusX on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'All';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
    }
  }

  bool get isDone => this == TaskStatus.done;

  String get apiValue {
    switch (this) {
      case TaskStatus.todo:
        return 'todo';
      case TaskStatus.inProgress:
        return 'inProgress';
      case TaskStatus.done:
        return 'done';
    }
  }
}

class TaskItem {
  const TaskItem({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.date,
    required this.responsible,
    required this.hours,
    required this.status,
    this.projectId,
    this.startedOn,
    this.completedOn,
  });

  final String id;
  final String name;
  final TaskType type;
  final String description;
  final DateTime date;
  final String responsible;
  final double hours;
  final TaskStatus status;
  final String? projectId;
  final DateTime? startedOn;
  final DateTime? completedOn;

  TaskItem copyWith({
    String? id,
    String? name,
    TaskType? type,
    String? description,
    DateTime? date,
    String? responsible,
    double? hours,
    TaskStatus? status,
    String? projectId,
    DateTime? startedOn,
    DateTime? completedOn,
    bool clearProjectId = false,
    bool clearStartedOn = false,
    bool clearCompletedOn = false,
  }) {
    return TaskItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      date: date ?? this.date,
      responsible: responsible ?? this.responsible,
      hours: hours ?? this.hours,
      status: status ?? this.status,
      projectId: clearProjectId ? null : (projectId ?? this.projectId),
      startedOn: clearStartedOn ? null : (startedOn ?? this.startedOn),
      completedOn: clearCompletedOn ? null : (completedOn ?? this.completedOn),
    );
  }

  Map<String, Object?> toJsonMap() {
    return {
      'id': id,
      'name': name,
      'type': type.apiValue,
      'description': description,
      'date': date.toIso8601String(),
      'responsible': responsible,
      'hours': hours,
      'status': status.apiValue,
      'projectId': projectId,
      'startedOn': startedOn?.toIso8601String(),
      'completedOn': completedOn?.toIso8601String(),
    };
  }

  static TaskItem fromJsonMap(Map<String, dynamic> map) {
    return TaskItem(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      type: _taskTypeFromRaw(map['type']),
      description: map['description'] as String? ?? '',
      date: _parseDate(map['date']) ?? DateTime.now(),
      responsible: map['responsible'] as String? ?? '',
      hours: _parseDouble(map['hours']),
      status: _taskStatusFromRaw(map['status']),
      projectId: map['projectId'] as String?,
      startedOn: _parseDate(map['startedOn']),
      completedOn: _parseDate(map['completedOn']),
    );
  }

  static TaskType _taskTypeFromRaw(Object? value) {
    final normalized = value?.toString().toLowerCase().replaceAll('_', '');
    switch (normalized) {
      case 'urgent':
        return TaskType.urgent;
      case 'normal':
        return TaskType.normal;
      case 'nopriority':
      default:
        return TaskType.noPriority;
    }
  }

  static TaskStatus _taskStatusFromRaw(Object? value) {
    final normalized = value?.toString().toLowerCase().replaceAll('_', '');
    switch (normalized) {
      case 'done':
        return TaskStatus.done;
      case 'inprogress':
        return TaskStatus.inProgress;
      case 'todo':
      default:
        return TaskStatus.todo;
    }
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(value.toString());
  }

  static double _parseDouble(Object? value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }
}
