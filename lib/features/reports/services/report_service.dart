import '../../tasks/models/task_item.dart';
import '../models/project_report_summary.dart';

class ReportService {
  List<ProjectReportSummary> buildMonthlySummary({
    required List<TaskItem> tasks,
    required String Function(String? projectId) resolveProjectName,
    String othersProjectName = 'Others',
  }) {
    final grouped = <String, List<TaskItem>>{};

    for (final task in tasks) {
      final projectName = resolveProjectName(task.projectId);
      grouped.putIfAbsent(projectName, () => []).add(task);
    }

    final summaries = grouped.entries
        .map(
          (entry) {
            final completed = entry.value.where((task) => task.completed).length;
            final total = entry.value.length;
            final pending = total - completed;
            final rate = total == 0 ? 0.0 : completed / total;

            return ProjectReportSummary(
              projectName: entry.key,
              totalTasks: total,
              completedTasks: completed,
              pendingTasks: pending,
              completionRate: rate,
            );
          },
        )
        .toList()
      ..sort((first, second) {
        if (first.projectName == othersProjectName) {
          return 1;
        }
        if (second.projectName == othersProjectName) {
          return -1;
        }
        return first.projectName.compareTo(second.projectName);
      });

    return summaries;
  }
}
