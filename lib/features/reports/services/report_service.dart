import '../../tasks/models/task_item.dart';
import '../models/project_report_summary.dart';

class ReportService {
  List<ProjectReportSummary> buildMonthlySummary({
    required List<TaskItem> tasks,
    required String Function(String? projectId) resolveProjectName,
  }) {
    final grouped = <String, List<TaskItem>>{};

    for (final task in tasks) {
      final projectName = resolveProjectName(task.projectId);
      grouped.putIfAbsent(projectName, () => []).add(task);
    }

    final summaries = grouped.entries
        .map(
          (entry) => ProjectReportSummary(
            projectName: entry.key,
            totalTasks: entry.value.length,
            completedTasks: entry.value.where((task) => task.completed).length,
            pendingTasks: entry.value.where((task) => !task.completed).length,
          ),
        )
        .toList()
      ..sort((first, second) => first.projectName.compareTo(second.projectName));

    return summaries;
  }
}
