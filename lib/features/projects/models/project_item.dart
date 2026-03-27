enum ProjectStatus { backlog, inProgress, done }

extension ProjectStatusX on ProjectStatus {
  String get label {
    switch (this) {
      case ProjectStatus.backlog:
        return 'All';
      case ProjectStatus.inProgress:
        return 'In Progress';
      case ProjectStatus.done:
        return 'Done';
    }
  }
}

class ProjectItem {
  const ProjectItem({
    required this.id,
    required this.name,
    required this.status,
  });

  final String id;
  final String name;
  final ProjectStatus status;

  ProjectItem copyWith({
    String? id,
    String? name,
    ProjectStatus? status,
  }) {
    return ProjectItem(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
    );
  }
}
