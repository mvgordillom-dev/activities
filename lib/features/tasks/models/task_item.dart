enum TaskType { urgent, normal, noPriority }

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

class TaskItem {
  const TaskItem({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.date,
    required this.responsible,
    required this.completed,
    this.projectId,
  });

  final String id;
  final String name;
  final TaskType type;
  final String description;
  final DateTime date;
  final String responsible;
  final bool completed;
  final String? projectId;

  TaskItem copyWith({
    String? id,
    String? name,
    TaskType? type,
    String? description,
    DateTime? date,
    String? responsible,
    bool? completed,
    String? projectId,
    bool clearProjectId = false,
  }) {
    return TaskItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      date: date ?? this.date,
      responsible: responsible ?? this.responsible,
      completed: completed ?? this.completed,
      projectId: clearProjectId ? null : (projectId ?? this.projectId),
    );
  }
}
