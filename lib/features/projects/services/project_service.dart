import '../models/project_item.dart';

class ProjectService {
  final List<ProjectItem> _projects = const [
    ProjectItem(
      id: 'proj-product',
      name: 'Product Launch',
      status: ProjectStatus.inProgress,
    ),
    ProjectItem(
      id: 'proj-operations',
      name: 'Operations',
      status: ProjectStatus.backlog,
    ),
  ].toList();

  List<ProjectItem> fetchProjects() {
    return List.unmodifiable(_projects);
  }

  void addProject(ProjectItem project) {
    _projects.add(project);
  }

  void updateProject(ProjectItem updatedProject) {
    final index = _projects.indexWhere((project) => project.id == updatedProject.id);
    if (index == -1) {
      return;
    }

    _projects[index] = updatedProject;
  }
}
