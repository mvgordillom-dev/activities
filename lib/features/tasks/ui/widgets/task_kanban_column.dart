import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/section_card.dart';
import '../../../projects/providers/project_provider.dart';
import '../../models/task_item.dart';
import '../../providers/task_provider.dart';
import 'task_completion_dialog.dart';

class TaskKanbanColumn extends StatelessWidget {
  const TaskKanbanColumn({
    super.key,
    required this.title,
    required this.status,
    required this.tasks,
  });

  final String title;
  final TaskStatus status;
  final List<TaskItem> tasks;

  @override
  Widget build(BuildContext context) {
    return DragTarget<TaskItem>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) => _updateTaskStatus(context, details.data, status),
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isHighlighted ? const Color(0xFFE0F2FE) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isHighlighted ? const Color(0xFF38BDF8) : const Color(0xFFE2E8F0),
              width: isHighlighted ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${tasks.length}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (tasks.isEmpty)
                const _EmptyColumnState()
              else
                Column(
                  children: [
                    for (var index = 0; index < tasks.length; index++) ...[
                      _TaskBoardCard(task: tasks[index]),
                      if (index != tasks.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateTaskStatus(
    BuildContext context,
    TaskItem task,
    TaskStatus nextStatus,
  ) async {
    final provider = context.read<TaskProvider>();

    if (nextStatus == TaskStatus.done) {
      final details = await showTaskCompletionDialog(context, task: task);
      if (details == null || !context.mounted) {
        return;
      }

      provider.completeTask(
        task,
        hours: details.hours,
        startedOn: details.startedOn,
        completedOn: details.completedOn,
      );
      return;
    }

    provider.updateTaskStatus(
      task,
      nextStatus,
      startedOn: nextStatus == TaskStatus.inProgress ? (task.startedOn ?? DateTime.now()) : null,
    );
  }
}

class _TaskBoardCard extends StatelessWidget {
  const _TaskBoardCard({required this.task});

  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<TaskItem>(
      data: task,
      feedback: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Opacity(
            opacity: 0.92,
            child: _TaskBoardCardBody(task: task),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: _TaskBoardCardBody(task: task),
      ),
      child: _TaskBoardCardBody(task: task),
    );
  }
}

class _TaskBoardCardBody extends StatelessWidget {
  const _TaskBoardCardBody({required this.task});

  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    final projectName = context.watch<ProjectProvider>().resolveProjectName(task.projectId);

    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              PopupMenuButton<TaskStatus>(
                tooltip: 'Change task status',
                onSelected: (status) async {
                  final provider = context.read<TaskProvider>();
                  if (status == TaskStatus.done) {
                    final details = await showTaskCompletionDialog(context, task: task);
                    if (details == null || !context.mounted) {
                      return;
                    }

                    provider.completeTask(
                      task,
                      hours: details.hours,
                      startedOn: details.startedOn,
                      completedOn: details.completedOn,
                    );
                    return;
                  }

                  provider.updateTaskStatus(
                    task,
                    status,
                    startedOn: status == TaskStatus.inProgress
                        ? (task.startedOn ?? DateTime.now())
                        : null,
                  );
                },
                itemBuilder: (context) => TaskStatus.values
                    .map(
                      (status) => PopupMenuItem<TaskStatus>(
                        value: status,
                        child: Text(status.label),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DetailChip(
                icon: Icons.folder_open_rounded,
                label: projectName,
              ),
              _DetailChip(
                icon: Icons.schedule_rounded,
                label: '${_formatHours(task.hours)}h',
              ),
              _DetailChip(
                icon: Icons.event_rounded,
                label: DateFormat('MMM d, y').format(task.date),
              ),
              _DetailChip(
                icon: Icons.person_rounded,
                label: task.responsible,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatHours(double hours) {
    return hours.truncateToDouble() == hours
        ? hours.toStringAsFixed(0)
        : hours.toStringAsFixed(2);
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyColumnState extends StatelessWidget {
  const _EmptyColumnState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        'Drop a card here to update its workflow status.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade700,
            ),
      ),
    );
  }
}
