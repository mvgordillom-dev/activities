import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../projects/providers/project_provider.dart';
import '../../../tasks/providers/task_provider.dart';
import '../../services/report_service.dart';
import '../widgets/report_summary_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportService _reportService = ReportService();
  DateTime? _selectedMonth;

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final projectProvider = context.watch<ProjectProvider>();
    final availableMonths = taskProvider.availableReportMonths;
    final selectedMonth = _resolveMonth(availableMonths);
    final monthTasks = taskProvider.tasksForMonth(selectedMonth);
    final reportEntries = _reportService.buildMonthlySummary(
      tasks: monthTasks,
      resolveProjectName: projectProvider.resolveProjectName,
      othersProjectName: ProjectProvider.othersProjectName,
    );
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final completedCount = monthTasks.where((task) => task.completed).length;
    final pendingCount = monthTasks.where((task) => !task.completed).length;

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
                        'Monthly Reports',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Filter by month and review project-level totals, including the automatic Others classification for uncategorized tasks.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      if (isWide)
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<DateTime>(
                                value: availableMonths.isEmpty ? null : selectedMonth,
                                decoration: const InputDecoration(labelText: 'Month'),
                                items: (availableMonths.isEmpty ? [selectedMonth] : availableMonths)
                                    .map(
                                      (month) => DropdownMenuItem<DateTime>(
                                        value: month,
                                        child: Text(DateFormat('MMMM y').format(month)),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) {
                                    return;
                                  }
                                  setState(() {
                                    _selectedMonth = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.end,
                                children: [
                                  _MonthMetric(label: 'Projects', value: '${reportEntries.length}'),
                                  _MonthMetric(label: 'Completed', value: '$completedCount'),
                                  _MonthMetric(label: 'Pending', value: '$pendingCount'),
                                ],
                              ),
                            ),
                          ],
                        )
                      else ...[
                        DropdownButtonFormField<DateTime>(
                          value: availableMonths.isEmpty ? null : selectedMonth,
                          decoration: const InputDecoration(labelText: 'Month'),
                          items: (availableMonths.isEmpty ? [selectedMonth] : availableMonths)
                              .map(
                                (month) => DropdownMenuItem<DateTime>(
                                  value: month,
                                  child: Text(DateFormat('MMMM y').format(month)),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _selectedMonth = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _MonthMetric(label: 'Projects', value: '${reportEntries.length}'),
                            _MonthMetric(label: 'Completed', value: '$completedCount'),
                            _MonthMetric(label: 'Pending', value: '$pendingCount'),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: reportEntries.isEmpty
                      ? EmptyStateCard(
                          icon: Icons.analytics_rounded,
                          title: 'No report data',
                          message: 'There are no tasks for ${DateFormat('MMMM y').format(selectedMonth)}. Create or reschedule tasks to populate monthly reporting.',
                        )
                      : ListView.separated(
                          itemCount: reportEntries.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final report = reportEntries[index];
                            return ReportSummaryCard(report: report);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DateTime _resolveMonth(List<DateTime> availableMonths) {
    if (availableMonths.isEmpty) {
      final now = DateTime.now();
      return DateTime(now.year, now.month);
    }

    if (_selectedMonth == null || !availableMonths.contains(_selectedMonth)) {
      _selectedMonth = availableMonths.first;
    }

    return _selectedMonth!;
  }
}

class _MonthMetric extends StatelessWidget {
  const _MonthMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
