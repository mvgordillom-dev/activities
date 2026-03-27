import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../projects/providers/project_provider.dart';
import '../../providers/task_provider.dart';
import 'add_task_screen.dart';
import '../widgets/task_group_section.dart';

class TaskBoardScreen extends StatelessWidget {
  const TaskBoardScreen({
    super.key,
    this.onCreateTask,
  });

  final VoidCallback? onCreateTask;

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final groupedTasks = taskProvider.groupedTasks;
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final projectsCount = context.watch<ProjectProvider>().projects.length;

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
                _HeroHeader(
                  isWide: isWide,
                  activeDays: groupedTasks.length,
                  activeTasks: taskProvider.pendingCount,
                  completedTasks: taskProvider.completedCount,
                  projectsCount: projectsCount,
                  totalHours: taskProvider.totalLoggedHours,
                  onCreateTask: onCreateTask,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: groupedTasks.isEmpty
                      ? EmptyStateCard(
                          icon: Icons.task_alt_rounded,
                          title: 'No active daily entries',
                          message: 'Entries move off this board once they are started or completed. Create a new daily log to see it grouped by date here.',
                          action: FilledButton.icon(
                            onPressed: onCreateTask ??
                                () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => const AddTaskScreen(),
                                      ),
                                    ),
                            icon: const Icon(Icons.add_task_rounded),
                            label: const Text('Create entry'),
                          ),
                        )
                      : ListView.separated(
                          itemBuilder: (context, index) {
                            final group = groupedTasks.entries.elementAt(index);
                            return TaskGroupSection(
                              day: group.key,
                              tasks: group.value,
                            );
                          },
                          separatorBuilder: (_, __) => const SizedBox(height: 18),
                          itemCount: groupedTasks.length,
                        ),
                ),
              ],
            ),
          ),
        ),
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
                  SizedBox(
                    width: 360,
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
          'Manage daily work logs by date, owner, and project.',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'Each card represents hours logged for a single date. Start an entry to move it into In Progress, then finish it from the project board once the work is complete.',
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
