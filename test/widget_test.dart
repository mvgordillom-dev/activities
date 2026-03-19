import 'package:activities/features/projects/providers/project_provider.dart';
import 'package:activities/features/projects/services/project_service.dart';
import 'package:activities/features/reports/services/report_service.dart';
import 'package:activities/features/tasks/models/task_item.dart';
import 'package:activities/features/tasks/providers/task_provider.dart';
import 'package:activities/features/tasks/services/task_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('moving a task to done removes it from the active provider list only', () {
    final provider = TaskProvider(TaskService())..loadInitialTasks();
    final pendingTask = provider.tasks.firstWhere((task) => !task.status.isDone);
    final initialActiveCount = provider.tasks.length;
    final initialTotalCount = provider.allTasks.length;

    provider.updateTaskStatus(pendingTask, TaskStatus.done);

    expect(provider.tasks.any((task) => task.id == pendingTask.id), isFalse);
    expect(provider.tasks.length, initialActiveCount - 1);
    expect(provider.allTasks.length, initialTotalCount);
    expect(
      provider.allTasks.any((task) => task.id == pendingTask.id && task.status == TaskStatus.done),
      isTrue,
    );
  });

  test('project provider resolves missing project ids to Others', () {
    final provider = ProjectProvider(ProjectService())..loadInitialProjects();

    expect(provider.resolveProjectName(null), ProjectProvider.othersProjectName);
    expect(provider.resolveProjectName('missing-id'), ProjectProvider.othersProjectName);
    expect(provider.resolveProjectName('proj-product'), 'Product Launch');
  });

  test('report service groups daily hours by project', () {
    final projectProvider = ProjectProvider(ProjectService())..loadInitialProjects();
    final taskProvider = TaskProvider(TaskService())..loadInitialTasks();
    final reportService = ReportService();
    final month = taskProvider.availableReportMonths.first;

    final summaries = reportService.buildMonthlySummary(
      tasks: taskProvider.tasksForMonth(month),
      resolveProjectName: projectProvider.resolveProjectName,
    );

    expect(summaries, isNotEmpty);
    expect(
      summaries.fold<double>(0.0, (sum, summary) => sum + summary.totalHours),
      closeTo(
        taskProvider.tasksForMonth(month).fold<double>(0.0, (sum, task) => sum + task.hours),
        0.0001,
      ),
    );
    expect(summaries.every((summary) => summary.entryCount >= summary.doneEntryCount), isTrue);
  });
}
