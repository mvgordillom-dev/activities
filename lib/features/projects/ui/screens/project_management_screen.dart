import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../tasks/models/task_item.dart';
import '../../../tasks/providers/task_provider.dart';
import '../../models/project_item.dart';
import '../../providers/project_provider.dart';
import '../widgets/project_kanban_column.dart';
import '../widgets/project_list_tile.dart';

class ProjectManagementScreen extends StatefulWidget {
  const ProjectManagementScreen({super.key});

  @override
  State<ProjectManagementScreen> createState() => _ProjectManagementScreenState();
}

class _ProjectManagementScreenState extends State<ProjectManagementScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedProjectId;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final projectProvider = context.watch<ProjectProvider>();
    final projects = projectProvider.projects;
    final taskProvider = context.watch<TaskProvider>();
    final selectedProjectId = _resolveSelectedProjectId(projects);
    final boardTasks = taskProvider.tasksForProject(selectedProjectId);
    final columns = _buildColumns(selectedProjectId, taskProvider);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 1240 : 760),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 32 : 16,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionCard(
                  padding: EdgeInsets.all(isWide ? 28 : 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Projects',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create project categories, review daily hours logged per project, and manage delivery with a Jira-style Kanban board.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: isWide
                            ? Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _nameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Project name',
                                      ),
                                      validator: _validateProject,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  FilledButton.icon(
                                    onPressed: _addProject,
                                    icon: const Icon(Icons.add_circle_outline_rounded),
                                    label: const Text('Add project'),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Project name',
                                    ),
                                    validator: _validateProject,
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: FilledButton.icon(
                                      onPressed: _addProject,
                                      icon: const Icon(Icons.add_circle_outline_rounded),
                                      label: const Text('Add project'),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      if (projects.isEmpty)
                        const EmptyStateCard(
                          icon: Icons.folder_copy_rounded,
                          title: 'No projects yet',
                          message: 'Add your first project to classify daily work logs beyond the automatic Others bucket.',
                        )
                      else
                        Column(
                          children: [
                            ProjectListTile(
                              name: ProjectProvider.othersProjectName,
                              subtitle: 'Automatic category for entries without a linked project',
                              totalTasks: taskProvider.taskCountForProject(null),
                              activeTasks: taskProvider.activeTaskCountForProject(null),
                              loggedHours: taskProvider.loggedHoursForProject(null),
                              isVirtualProject: true,
                            ),
                            const SizedBox(height: 12),
                            for (var index = 0; index < projects.length; index++) ...[
                              ProjectListTile(
                                name: projects[index].name,
                                subtitle: 'ID: ${projects[index].id}',
                                totalTasks: taskProvider.taskCountForProject(projects[index].id),
                                activeTasks: taskProvider.activeTaskCountForProject(projects[index].id),
                                loggedHours: taskProvider.loggedHoursForProject(projects[index].id),
                              ),
                              if (index != projects.length - 1) const SizedBox(height: 12),
                            ],
                          ],
                        ),
                      const SizedBox(height: 20),
                      SectionCard(
                        padding: EdgeInsets.all(isWide ? 28 : 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Project board',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Drag cards between To Do, In Progress, and Done. Status updates are persisted immediately for the selected project.',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 18),
                            DropdownButtonFormField<String?>(
                              value: selectedProjectId,
                              decoration: const InputDecoration(
                                labelText: 'Board project',
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text(ProjectProvider.othersProjectName),
                                ),
                                ...projects.map(
                                  (project) => DropdownMenuItem<String?>(
                                    value: project.id,
                                    child: Text(project.name),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedProjectId = value;
                                });
                              },
                            ),
                            const SizedBox(height: 18),
                            if (boardTasks.isEmpty)
                              EmptyStateCard(
                                icon: Icons.view_kanban_rounded,
                                title: 'No cards for this project',
                                message: 'Create a daily work log for ${projectProvider.resolveProjectName(selectedProjectId)} to populate the board.',
                              )
                            else if (isWide)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (var index = 0; index < columns.length; index++) ...[
                                    Expanded(child: columns[index]),
                                    if (index != columns.length - 1) const SizedBox(width: 12),
                                  ],
                                ],
                              )
                            else
                              Column(
                                children: [
                                  for (var index = 0; index < columns.length; index++) ...[
                                    columns[index],
                                    if (index != columns.length - 1) const SizedBox(height: 16),
                                  ],
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildColumns(String? projectId, TaskProvider taskProvider) {
    return TaskStatus.values
        .map(
          (status) => ProjectKanbanColumn(
            title: status.label,
            status: status,
            tasks: taskProvider.tasksForProjectAndStatus(projectId, status),
          ),
        )
        .toList(growable: false);
  }

  String? _validateProject(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Project name is required';
    }
    return null;
  }

  void _addProject() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<ProjectProvider>().addProject(_nameController.text);
    _nameController.clear();
  }

  String? _resolveSelectedProjectId(List<ProjectItem> projects) {
    if (_selectedProjectId == null) {
      return null;
    }

    final exists = projects.any((project) => project.id == _selectedProjectId);
    if (!exists) {
      _selectedProjectId = null;
    }

    return _selectedProjectId;
  }
}
