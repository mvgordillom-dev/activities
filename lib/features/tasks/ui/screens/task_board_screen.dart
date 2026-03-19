import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../projects/providers/project_provider.dart';
import '../../providers/task_provider.dart';
import '../widgets/task_form_dialog.dart';
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
    final completedTasks = taskProvider.allTasks.where((task) => task.completed).length;
    final projectsCount = context.watch<ProjectProvider>().projects.length;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isWide ? 1200 : 720,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 32 : 16,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ResponsiveHeader(
                  isWide: isWide,
                  activeDays: groupedTasks.length,
                  completedTasks: completedTasks,
                  projectsCount: projectsCount,
                  onCreateTask: onCreateTask,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: groupedTasks.isEmpty
                      ? _EmptyState(isWide: isWide)
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

class _ResponsiveHeader extends StatelessWidget {
  const _ResponsiveHeader({
    required this.isWide,
    required this.activeDays,
    required this.completedTasks,
    required this.projectsCount,
    this.onCreateTask,
  });

  final bool isWide;
  final int activeDays;
  final int completedTasks;
  final int projectsCount;
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
                  _SummaryGrid(
                    isWide: true,
                    activeDays: activeDays,
                    completedTasks: completedTasks,
                    projectsCount: projectsCount,
                  ),
                ],
              )
            else ...[
              _HeaderText(onCreateTask: onCreateTask),
              const SizedBox(height: 20),
              _SummaryGrid(
                isWide: false,
                activeDays: activeDays,
                completedTasks: completedTasks,
                projectsCount: projectsCount,
              ),
            ],
          ],
        ),
      ),
    );
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
          'Plan, prioritize, and deliver tasks efficiently.',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tasks stay grouped by day, keep full details visible, and disappear from the active board once completed.',
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
          onPressed: onCreateTask ?? () => showDialog<void>(
            context: context,
            builder: (_) => const TaskFormDialog(),
          ),
          icon: const Icon(Icons.add_task_rounded),
          label: const Text('Create task'),
        ),
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({
    required this.isWide,
    required this.activeDays,
    required this.completedTasks,
    required this.projectsCount,
  });

  final bool isWide;
  final int activeDays;
  final int completedTasks;
  final int projectsCount;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryCard(label: 'Active Days', value: '$activeDays'),
      _SummaryCard(label: 'Projects', value: '$projectsCount'),
      _SummaryCard(label: 'Completed', value: '$completedTasks'),
    ];

    if (isWide) {
      return SizedBox(
        width: 320,
        child: Column(
          children: [
            for (var index = 0; index < cards.length; index++) ...[
              cards[index],
              if (index != cards.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: cards
          .map(
            (card) => SizedBox(
              width: 180,
              child: card,
            ),
          )
          .toList(),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: EdgeInsets.all(isWide ? 32 : 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.task_alt_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No pending tasks',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a new task to populate the schedule. Completed work is automatically removed from this list.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
