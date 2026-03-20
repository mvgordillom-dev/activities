import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/section_card.dart';
import '../../../projects/providers/project_provider.dart';
import '../../models/task_item.dart';
import '../../providers/task_provider.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
  });

  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    final typeStyle = _TaskTypePalette.from(task.type);
    final statusStyle = _TaskStatusPalette.from(task.status);
    final projectName = context.watch<ProjectProvider>().resolveProjectName(task.projectId);

    return SectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
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
                ),
              ),
              Checkbox(
                value: task.status.isDone,
                onChanged: (_) => context.read<TaskProvider>().updateTaskStatus(
                      task,
                      task.status.isDone ? TaskStatus.todo : TaskStatus.done,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TaskMetaRow(
            icon: Icons.schedule_rounded,
            label: 'Daily hours logged',
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
            label: 'Entry date',
            value: DateFormat('MMM d, y • h:mm a').format(task.date),
          ),
          const SizedBox(height: 10),
          _TaskMetaRow(
            icon: Icons.person_rounded,
            label: 'Responsible',
            value: task.responsible,
          ),
          const SizedBox(height: 10),
          _TaskMetaRow(
            icon: Icons.folder_special_rounded,
            label: 'Project classification',
            value: projectName,
          ),
        ],
      ),
    );
  }

  String _formatHours(double hours) {
    final wholeHours = hours.truncateToDouble() == hours;
    final value = wholeHours ? hours.toStringAsFixed(0) : hours.toStringAsFixed(2);
    return '$value hour${hours == 1 ? '' : 's'}';
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
