import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/section_card.dart';
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
    final projectColumns = _buildProjectColumns(projectProvider);

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
                        'Create project categories, manage project workflow, and review project workload summaries.',
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
                          message:
                              'Add your first project to classify daily work logs beyond the automatic Others bucket.',
                        )
                      else ...[
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
                                'Drag projects between All, In Progress, and Done, or use the menu on each card for unrestricted status changes.',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 18),
                              if (isWide)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (var index = 0; index < projectColumns.length; index++) ...[
                                      Expanded(child: projectColumns[index]),
                                      if (index != projectColumns.length - 1)
                                        const SizedBox(width: 12),
                                    ],
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    for (var index = 0; index < projectColumns.length; index++) ...[
                                      projectColumns[index],
                                      if (index != projectColumns.length - 1)
                                        const SizedBox(height: 16),
                                    ],
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ProjectListTile(
                          name: ProjectProvider.othersProjectName,
                          subtitle: 'Automatic category for entries without a linked project',
                          totalTasks: taskProvider.taskCountForProject(null),
                          activeTasks: taskProvider.activeTaskCountForProject(null),
                          loggedHours: taskProvider.loggedHoursForProject(null),
                          statusLabel: projectProvider.resolveProjectStatusLabel(null),
                          isVirtualProject: true,
                        ),
                        const SizedBox(height: 12),
                        for (var index = 0; index < projects.length; index++) ...[
                          ProjectListTile(
                            name: projects[index].name,
                            subtitle: 'ID: ${projects[index].id}',
                            totalTasks: taskProvider.taskCountForProject(projects[index].id),
                            activeTasks:
                                taskProvider.activeTaskCountForProject(projects[index].id),
                            loggedHours: taskProvider.loggedHoursForProject(projects[index].id),
                            statusLabel: projects[index].status.label,
                          ),
                          if (index != projects.length - 1) const SizedBox(height: 12),
                        ],
                      ],
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

  List<Widget> _buildProjectColumns(ProjectProvider projectProvider) {
    return ProjectStatus.values
        .map(
          (status) => ProjectKanbanColumn(
            title: status.label,
            projectStatus: status,
            projects: projectProvider.projectsForStatus(status),
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
}
