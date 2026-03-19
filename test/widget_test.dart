import 'package:activities/features/projects/providers/project_provider.dart';
import 'package:activities/features/projects/services/project_service.dart';
import 'package:activities/features/reports/services/report_service.dart';
import 'package:activities/features/tasks/providers/task_provider.dart';
import 'package:activities/features/tasks/services/task_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('completing a task removes it from the active provider list only', () {
    final provider = TaskProvider(TaskService())..loadInitialTasks();
    final pendingTask = provider.tasks.firstWhere((task) => !task.completed);
    final initialActiveCount = provider.tasks.length;
    final initialTotalCount = provider.allTasks.length;

    provider.completeTask(pendingTask);

    expect(provider.tasks.contains(pendingTask), isFalse);
    expect(provider.tasks.length, initialActiveCount - 1);
    expect(provider.allTasks.length, initialTotalCount);
    expect(provider.allTasks.any((task) => task.name == pendingTask.name && task.completed), isTrue);
  });

  test('project provider resolves missing project ids to Others', () {
    final provider = ProjectProvider(ProjectService())..loadInitialProjects();

    expect(provider.resolveProjectName(null), ProjectProvider.othersProjectName);
    expect(provider.resolveProjectName('missing-id'), ProjectProvider.othersProjectName);
    expect(provider.resolveProjectName('proj-product'), 'Product Launch');
  });

  test('report service groups tasks by project and tracks completed versus pending', () {
    final projectProvider = ProjectProvider(ProjectService())..loadInitialProjects();
    final taskProvider = TaskProvider(TaskService())..loadInitialTasks();
    final reportService = ReportService();
    final month = taskProvider.availableReportMonths.first;

    final summaries = reportService.buildMonthlySummary(
      tasks: taskProvider.tasksForMonth(month),
      resolveProjectName: projectProvider.resolveProjectName,
    );

    expect(summaries, isNotEmpty);
    expect(summaries.any((summary) => summary.projectName == ProjectProvider.othersProjectName), isTrue);
    expect(
      summaries.every(
        (summary) => summary.totalTasks == summary.completedTasks + summary.pendingTasks,
      ),
      isTrue,
    );
  });
}
