import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../tasks/providers/task_provider.dart';
import '../../providers/project_provider.dart';
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
    final projects = context.watch<ProjectProvider>().projects;
    final taskProvider = context.watch<TaskProvider>();

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 1160 : 760),
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
                        'Create project categories for your tasks. Any task left without a project is automatically classified as Others.',
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
                  child: projects.isEmpty
                      ? const EmptyStateCard(
                          icon: Icons.folder_copy_rounded,
                          title: 'No projects yet',
                          message: 'Add your first project to classify tasks beyond the automatic Others bucket.',
                        )
                      : ListView(
                          children: [
                            ProjectListTile(
                              name: ProjectProvider.othersProjectName,
                              subtitle: 'Automatic category for tasks without a linked project',
                              totalTasks: taskProvider.taskCountForProject(null),
                              activeTasks: taskProvider.activeTaskCountForProject(null),
                              isVirtualProject: true,
                            ),
                            const SizedBox(height: 12),
                            for (var index = 0; index < projects.length; index++) ...[
                              ProjectListTile(
                                name: projects[index].name,
                                subtitle: 'ID: ${projects[index].id}',
                                totalTasks: taskProvider.taskCountForProject(projects[index].id),
                                activeTasks: taskProvider.activeTaskCountForProject(projects[index].id),
                              ),
                              if (index != projects.length - 1) const SizedBox(height: 12),
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
