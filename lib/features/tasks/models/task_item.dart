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
}
