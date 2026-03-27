import 'package:activities/features/projects/models/project_item.dart';
import 'package:activities/features/projects/providers/project_provider.dart';
import 'package:activities/features/projects/services/project_service.dart';
import 'package:activities/features/reports/services/report_service.dart';
import 'package:activities/features/tasks/models/task_item.dart';
import 'package:activities/features/tasks/providers/task_provider.dart';
import 'package:activities/features/tasks/services/task_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('moving a task to in progress keeps it on the daily board with updated status', () {
    final provider = TaskProvider(TaskService())..loadInitialTasks();
    final pendingTask = provider.dailyBoardTasks.firstWhere((task) => task.status == TaskStatus.todo);
    final initialDailyBoardCount = provider.dailyBoardTasks.length;
    final initialTotalCount = provider.allTasks.length;

    provider.updateTaskStatus(
      pendingTask,
      TaskStatus.inProgress,
      startedOn: pendingTask.date,
    );

    expect(provider.dailyBoardTasks.any((task) => task.id == pendingTask.id), isTrue);
    expect(provider.dailyBoardTasks.length, initialDailyBoardCount);
    expect(provider.allTasks.length, initialTotalCount);
    expect(
      provider.dailyBoardTasks.any(
        (task) =>
            task.id == pendingTask.id &&
            task.status == TaskStatus.inProgress &&
            task.startedOn != null,
      ),
      isTrue,
    );
  });

  test('completing a task stores hours spent and completion metadata', () {
    final provider = TaskProvider(TaskService())..loadInitialTasks();
    final task = provider.allTasks.firstWhere((item) => item.status != TaskStatus.done);
    final startedOn = DateTime(2026, 3, 1);
    final completedOn = DateTime(2026, 3, 5);

    provider.completeTask(
      task,
      hours: 4.5,
      startedOn: startedOn,
      completedOn: completedOn,
    );

    final completedTask = provider.allTasks.firstWhere((item) => item.id == task.id);
    expect(completedTask.status, TaskStatus.done);
    expect(completedTask.hours, 4.5);
    expect(completedTask.startedOn, startedOn);
    expect(completedTask.completedOn, completedOn);
  });

  test('project provider resolves missing project ids to Others and tracks status', () {
    final provider = ProjectProvider(ProjectService())..loadInitialProjects();
    final project = provider.projects.firstWhere((item) => item.id == 'proj-product');

    expect(provider.resolveProjectName(null), ProjectProvider.othersProjectName);
    expect(provider.resolveProjectName('missing-id'), ProjectProvider.othersProjectName);
    expect(provider.resolveProjectName('proj-product'), 'Product Launch');
    expect(provider.resolveProjectStatusLabel(null), ProjectStatus.backlog.label);

    provider.updateProjectStatus(project, ProjectStatus.done);

    expect(provider.resolveProjectStatusLabel('proj-product'), ProjectStatus.done.label);
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
