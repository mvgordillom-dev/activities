import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/section_card.dart';
import '../../../projects/providers/project_provider.dart';
import '../../models/task_item.dart';
import '../../providers/task_provider.dart';
import 'task_completion_dialog.dart';
import 'task_form_dialog.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
  });

  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 600;
    final typeStyle = _TaskTypePalette.from(task.type);
    final statusStyle = _TaskStatusPalette.from(task.status);
    final projectName = context.watch<ProjectProvider>().resolveProjectName(task.projectId);

    return SectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flex(
            direction: isCompact ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCompact)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _StatusToggle(task: task),
                ),
              if (isCompact)
                _TaskCardHeader(
                  task: task,
                  typeStyle: typeStyle,
                  statusStyle: statusStyle,
                  projectName: projectName,
                )
              else
                Expanded(
                  child: _TaskCardHeader(
                    task: task,
                    typeStyle: typeStyle,
                    statusStyle: statusStyle,
                    projectName: projectName,
                  ),
                ),
              if (!isCompact) _StatusToggle(task: task),
            ],
          ),
          const SizedBox(height: 12),
          _TaskMetaRow(
            icon: Icons.schedule_rounded,
            label: 'Hours logged',
            value: _formatHours(task.hours),
          ),
          const SizedBox(height: 10),
          _TaskMetaRow(
            icon: Icons.description_rounded,
            label: 'Description',
            value: task.description,
          ),
          const SizedBox(height: 10),
          _TaskMetaRow(
            icon: Icons.event_rounded,
            label: 'Creation date',
            value: DateFormat('MMM d, y').format(task.date),
          ),
          const SizedBox(height: 10),
          _TaskMetaRow(
            icon: Icons.person_rounded,
            label: 'Assigned to',
            value: task.responsible,
          ),
          const SizedBox(height: 10),
          _TaskMetaRow(
            icon: Icons.folder_special_rounded,
            label: 'Project',
            value: projectName,
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _editTask(context),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Edit'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _changeStatus(context, TaskStatus.inProgress),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('In Progress'),
                ),
                FilledButton.icon(
                  onPressed: () => _changeStatus(context, TaskStatus.done),
                  icon: const Icon(Icons.done_rounded),
                  label: const Text('Complete'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editTask(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) {
        return Dialog(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: TaskFormView(initialTask: task),
          ),
        );
      },
    );
  }

  Future<void> _changeStatus(BuildContext context, TaskStatus nextStatus) async {
    final taskProvider = context.read<TaskProvider>();

    if (nextStatus == TaskStatus.done) {
      final details = await showTaskCompletionDialog(context, task: task);
      if (details == null || !context.mounted) {
        return;
      }

      taskProvider.completeTask(
        task,
        hours: details.hours,
        startedOn: details.startedOn,
        completedOn: details.completedOn,
      );
      return;
    }

    taskProvider.updateTaskStatus(
      task,
      nextStatus,
      startedOn: nextStatus == TaskStatus.inProgress ? (task.startedOn ?? DateTime.now()) : null,
    );
  }

  String _formatHours(double hours) {
    final wholeHours = hours.truncateToDouble() == hours;
    final value = wholeHours ? hours.toStringAsFixed(0) : hours.toStringAsFixed(2);
    return '$value hour${hours == 1 ? '' : 's'}';
  }
}

class _TaskCardHeader extends StatelessWidget {
  const _TaskCardHeader({
    required this.task,
    required this.typeStyle,
    required this.statusStyle,
    required this.projectName,
  });

  final TaskItem task;
  final _TaskTypePalette typeStyle;
  final _TaskStatusPalette statusStyle;
  final String projectName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              avatar: Icon(Icons.flag_rounded, color: typeStyle.foreground, size: 18),
              label: Text(task.type.label),
              backgroundColor: typeStyle.background,
              labelStyle: TextStyle(
                color: typeStyle.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
            Chip(
              avatar: Icon(Icons.sync_alt_rounded, color: statusStyle.foreground, size: 18),
              label: Text(task.status.label),
              backgroundColor: statusStyle.background,
              labelStyle: TextStyle(
                color: statusStyle.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
            Chip(
              avatar: const Icon(Icons.folder_open_rounded, size: 18),
              label: Text(projectName),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusToggle extends StatelessWidget {
  const _StatusToggle({required this.task});

  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Move this daily entry to In Progress',
      child: Checkbox(
        value: task.status == TaskStatus.inProgress,
        onChanged: (value) {
          if (value ?? false) {
            context.read<TaskProvider>().updateTaskStatus(
                  task,
                  TaskStatus.inProgress,
                  startedOn: task.startedOn ?? DateTime.now(),
                );
          }
        },
      ),
    );
  }
}

class _TaskMetaRow extends StatelessWidget {
  const _TaskMetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.45),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.grey.shade700,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaskTypePalette {
  const _TaskTypePalette({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;

  factory _TaskTypePalette.from(TaskType type) {
    switch (type) {
      case TaskType.urgent:
        return const _TaskTypePalette(
          background: Color(0xFFFEE2E2),
          foreground: Color(0xFFB91C1C),
        );
      case TaskType.normal:
        return const _TaskTypePalette(
          background: Color(0xFFDBEAFE),
          foreground: Color(0xFF1D4ED8),
        );
      case TaskType.noPriority:
        return const _TaskTypePalette(
          background: Color(0xFFEDE9FE),
          foreground: Color(0xFF6D28D9),
        );
    }
  }
}

class _TaskStatusPalette {
  const _TaskStatusPalette({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;

  factory _TaskStatusPalette.from(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return const _TaskStatusPalette(
          background: Color(0xFFF3F4F6),
          foreground: Color(0xFF374151),
        );
      case TaskStatus.inProgress:
        return const _TaskStatusPalette(
          background: Color(0xFFFEF3C7),
          foreground: Color(0xFFB45309),
        );
      case TaskStatus.done:
        return const _TaskStatusPalette(
          background: Color(0xFFDCFCE7),
          foreground: Color(0xFF166534),
        );
    }
  }
}
