import 'package:flutter/material.dart';

import '../models/project_item.dart';
import '../services/project_service.dart';

class ProjectProvider extends ChangeNotifier {
  ProjectProvider(this._projectService);

  static const othersProjectName = 'Others';

  final ProjectService _projectService;
  List<ProjectItem> _projects = const [];

  List<ProjectItem> get projects {
    final sorted = [..._projects]..sort((first, second) => first.name.compareTo(second.name));
    return List.unmodifiable(sorted);
  }

  void loadInitialProjects() {
    _projects = _projectService.fetchProjects();
    notifyListeners();
  }

  void addProject(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final id = trimmed
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');

    final normalizedId = id.isEmpty ? 'project-${projects.length + 1}' : id;
    final uniqueId = projects.any((project) => project.id == normalizedId)
        ? '$normalizedId-${projects.length + 1}'
        : normalizedId;

    _projectService.addProject(ProjectItem(id: uniqueId, name: trimmed));
    _projects = _projectService.fetchProjects();
    notifyListeners();
  }

  String resolveProjectName(String? projectId) {
    if (projectId == null || projectId.isEmpty) {
      return othersProjectName;
    }

    for (final project in projects) {
      if (project.id == projectId) {
        return project.name;
      }
    }

    return othersProjectName;
  }
}
