import 'package:flutter/material.dart';

import '../../../../core/widgets/section_card.dart';

class ProjectListTile extends StatelessWidget {
  const ProjectListTile({
    super.key,
    required this.name,
    required this.subtitle,
    required this.totalTasks,
    required this.activeTasks,
    required this.loggedHours,
    this.isVirtualProject = false,
  });

  final String name;
  final String subtitle;
  final int totalTasks;
  final int activeTasks;
  final double loggedHours;
  final bool isVirtualProject;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: isVirtualProject
                ? const Color(0xFFE0E7FF)
                : Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              isVirtualProject ? Icons.auto_awesome_mosaic_rounded : Icons.folder_rounded,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(subtitle),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MetricPill(label: 'Entries', value: '$totalTasks'),
                    _MetricPill(
                      label: 'Open',
                      value: '$activeTasks',
                      background: const Color(0xFFDCFCE7),
                      foreground: const Color(0xFF166534),
                    ),
                    _MetricPill(
                      label: 'Hours',
                      value: _formatHours(loggedHours),
                      background: const Color(0xFFFEF3C7),
                      foreground: const Color(0xFFB45309),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatHours(double hours) {
    return hours.truncateToDouble() == hours ? hours.toStringAsFixed(0) : hours.toStringAsFixed(2);
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    required this.value,
    this.background = const Color(0xFFE0E7FF),
    this.foreground = const Color(0xFF3730A3),
  });

  final String label;
  final String value;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
