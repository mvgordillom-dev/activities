import '../models/project_item.dart';

class ProjectService {
  final List<ProjectItem> _projects = const [
    ProjectItem(id: 'proj-product', name: 'Product Launch'),
    ProjectItem(id: 'proj-operations', name: 'Operations'),
  ].toList();

  List<ProjectItem> fetchProjects() {
    return List.unmodifiable(_projects);
  }

  void addProject(ProjectItem project) {
    _projects.add(project);
  }
}
