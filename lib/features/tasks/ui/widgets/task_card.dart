import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
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
                      Chip(
                        avatar: Icon(Icons.flag_rounded, color: typeStyle.foreground, size: 18),
                        label: Text(task.type.label),
                        backgroundColor: typeStyle.background,
                        labelStyle: TextStyle(
                          color: typeStyle.foreground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: task.completed,
                  onChanged: (_) => context.read<TaskProvider>().completeTask(task),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _TaskMetaRow(
              icon: Icons.description_rounded,
              label: 'Description',
              value: task.description,
            ),
            const SizedBox(height: 10),
            _TaskMetaRow(
              icon: Icons.event_rounded,
              label: 'Date',
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
              icon: Icons.done_all_rounded,
              label: 'Completed',
              value: task.completed ? 'Yes' : 'No',
            ),
          ],
        ),
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
