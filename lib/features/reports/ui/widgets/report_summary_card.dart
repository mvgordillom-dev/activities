import 'package:flutter/material.dart';

import '../../../../core/widgets/section_card.dart';
import '../../models/project_report_summary.dart';

class ReportSummaryCard extends StatelessWidget {
  const ReportSummaryCard({
    super.key,
    required this.report,
  });

  final ProjectReportSummary report;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            report.projectName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricChip(label: 'Hours logged', value: _formatHours(report.totalHours)),
              _MetricChip(
                label: 'Daily entries',
                value: '${report.entryCount}',
                color: const Color(0xFFE0E7FF),
                foreground: const Color(0xFF3730A3),
              ),
              _MetricChip(
                label: 'Tracked days',
                value: '${report.daysTracked}',
                color: const Color(0xFFFEF3C7),
                foreground: const Color(0xFFB45309),
              ),
              _MetricChip(
                label: 'Done entries',
                value: '${report.doneEntryCount}',
                color: const Color(0xFFDCFCE7),
                foreground: const Color(0xFF166534),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatHours(double hours) {
    return hours.truncateToDouble() == hours ? hours.toStringAsFixed(0) : hours.toStringAsFixed(2);
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    this.color = const Color(0xFFE0E7FF),
    this.foreground = const Color(0xFF3730A3),
  });

  final String label;
  final String value;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: foreground,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
