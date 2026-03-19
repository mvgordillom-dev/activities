class ProjectReportSummary {
  const ProjectReportSummary({
    required this.projectName,
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
  });

  final String projectName;
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
}
