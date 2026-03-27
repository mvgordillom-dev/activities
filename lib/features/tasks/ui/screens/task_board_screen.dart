import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../projects/models/project_item.dart';
import '../../../projects/providers/project_provider.dart';
import '../../models/task_item.dart';
import '../../providers/task_provider.dart';
import '../widgets/task_group_section.dart';
import '../widgets/task_kanban_column.dart';
import 'add_task_screen.dart';

class TaskBoardScreen extends StatefulWidget {
  const TaskBoardScreen({
    super.key,
    this.onCreateTask,
  });

  final VoidCallback? onCreateTask;

  @override
  State<TaskBoardScreen> createState() => _TaskBoardScreenState();
}

class _TaskBoardScreenState extends State<TaskBoardScreen> {
  static const _allProjectsFilter = '__all_projects__';

  String? _selectedProjectId = _allProjectsFilter;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width >= 1100;
    final isTablet = size.width >= 700;
    final taskProvider = context.watch<TaskProvider>();
    final projectProvider = context.watch<ProjectProvider>();
    final groupedTasks = taskProvider.groupedTasks;
    final projects = projectProvider.projects;
    final selectedProjectId = _resolveSelectedProjectId(projects);
    final boardTasks = _tasksForSelectedProject(taskProvider, selectedProjectId);
    final taskColumns = TaskStatus.values
        .map(
          (status) => TaskKanbanColumn(
            title: status.label,
            status: status,
            tasks: boardTasks.where((task) => task.status == status).toList(growable: false),
          ),
        )
        .toList(growable: false);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 1320 : 920),
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : 16,
              vertical: 20,
            ),
            children: [
              _HeroHeader(
                isWide: isTablet,
                activeDays: groupedTasks.length,
                activeTasks: taskProvider.pendingCount,
                completedTasks: taskProvider.completedCount,
                projectsCount: projectProvider.projects.length,
                totalHours: taskProvider.totalLoggedHours,
                onCreateTask: widget.onCreateTask,
              ),
              const SizedBox(height: 20),
              SectionCard(
                padding: EdgeInsets.all(isDesktop ? 28 : 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily entries board',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track active daily entries by date. Entries stay visible here while they are open or already in progress, so the board never clears unexpectedly.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 18),
                    if (groupedTasks.isEmpty)
                      EmptyStateCard(
                        icon: Icons.task_alt_rounded,
                        title: 'No active daily entries',
                        message:
                            'All daily entries are completed. Create a new entry to add work back onto the board.',
                        action: FilledButton.icon(
                          onPressed: widget.onCreateTask ??
                              () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const AddTaskScreen(),
                                    ),
                                  ),
                          icon: const Icon(Icons.add_task_rounded),
                          label: const Text('Create entry'),
                        ),
                      )
                    else
                      Column(
                        children: [
                          for (var index = 0; index < groupedTasks.length; index++) ...[
                            TaskGroupSection(
                              day: groupedTasks.entries.elementAt(index).key,
                              tasks: groupedTasks.entries.elementAt(index).value,
                            ),
                            if (index != groupedTasks.length - 1) const SizedBox(height: 18),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SectionCard(
                padding: EdgeInsets.all(isDesktop ? 28 : 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task status board',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage task workflow independently from Projects. Move cards between All, In Progress, and Done while filtering by project when needed.',
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
                          value: _allProjectsFilter,
                          child: Text('All projects'),
                        ),
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
                        title: selectedProjectId == _allProjectsFilter
                            ? 'No task cards yet'
                            : 'No cards for this project',
                        message:
                            'Create a daily work log for ${_boardLabel(projectProvider, selectedProjectId)} to populate the board.',
                      )
                    else
                      _ResponsiveTaskBoard(
                        isDesktop: isDesktop,
                        columns: taskColumns,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _resolveSelectedProjectId(List<ProjectItem> projects) {
    if (_selectedProjectId == null || _selectedProjectId == _allProjectsFilter) {
      return _selectedProjectId;
    }

    final exists = projects.any((project) => project.id == _selectedProjectId);
    if (!exists) {
      _selectedProjectId = _allProjectsFilter;
    }

    return _selectedProjectId;
  }

  List<TaskItem> _tasksForSelectedProject(
    TaskProvider taskProvider,
    String? selectedProjectId,
  ) {
    if (selectedProjectId == _allProjectsFilter) {
      return taskProvider.allTasks;
    }

    return taskProvider.tasksForProject(selectedProjectId);
  }

  String _boardLabel(ProjectProvider projectProvider, String? selectedProjectId) {
    if (selectedProjectId == _allProjectsFilter) {
      return 'all projects';
    }

    return projectProvider.resolveProjectName(selectedProjectId);
  }
}

class _ResponsiveTaskBoard extends StatelessWidget {
  const _ResponsiveTaskBoard({
    required this.isDesktop,
    required this.columns,
  });

  final bool isDesktop;
  final List<Widget> columns;

  @override
  Widget build(BuildContext context) {
    if (!isDesktop) {
      return Column(
        children: [
          for (var index = 0; index < columns.length; index++) ...[
            columns[index],
            if (index != columns.length - 1) const SizedBox(height: 16),
          ],
        ],
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < columns.length; index++) ...[
            SizedBox(
              width: 320,
              child: columns[index],
            ),
            if (index != columns.length - 1) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.isWide,
    required this.activeDays,
    required this.activeTasks,
    required this.completedTasks,
    required this.projectsCount,
    required this.totalHours,
    this.onCreateTask,
  });

  final bool isWide;
  final int activeDays;
  final int activeTasks;
  final int completedTasks;
  final int projectsCount;
  final double totalHours;
  final VoidCallback? onCreateTask;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: EdgeInsets.all(isWide ? 28 : 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _HeaderText(onCreateTask: onCreateTask)),
                  const SizedBox(width: 24),
                  Flexible(
                    child: _SummaryGrid(
                      items: [
                        _SummaryItem(label: 'Active days', value: '$activeDays'),
                        _SummaryItem(label: 'Open entries', value: '$activeTasks'),
                        _SummaryItem(label: 'Done entries', value: '$completedTasks'),
                        _SummaryItem(label: 'Logged hours', value: _formatHours(totalHours)),
                        _SummaryItem(label: 'Projects', value: '$projectsCount'),
                      ],
                    ),
                  ),
                ],
              )
            else ...[
              _HeaderText(onCreateTask: onCreateTask),
              const SizedBox(height: 20),
              _SummaryGrid(
                items: [
                  _SummaryItem(label: 'Active days', value: '$activeDays'),
                  _SummaryItem(label: 'Open entries', value: '$activeTasks'),
                  _SummaryItem(label: 'Done entries', value: '$completedTasks'),
                  _SummaryItem(label: 'Logged hours', value: _formatHours(totalHours)),
                  _SummaryItem(label: 'Projects', value: '$projectsCount'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatHours(double hours) {
    return hours.truncateToDouble() == hours ? hours.toStringAsFixed(0) : hours.toStringAsFixed(2);
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText({this.onCreateTask});

  final VoidCallback? onCreateTask;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage daily work logs by date, owner, project, and status.',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'Daily entries stay visible until they are completed, and the task board below keeps every workflow column available on desktop, tablet, and mobile layouts.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.92),
                height: 1.45,
              ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
          onPressed: onCreateTask ??
              () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AddTaskScreen(),
                    ),
                  ),
          icon: const Icon(Icons.add_task_rounded),
          label: const Text('Create entry'),
        ),
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.items});

  final List<_SummaryItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map(
            (item) => SizedBox(
              width: 170,
              child: SectionCard(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.value,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SummaryItem {
  const _SummaryItem({required this.label, required this.value});

  final String label;
  final String value;
}
