class ProjectReportSummary {
  const ProjectReportSummary({
    required this.projectName,
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.completionRate,
  });

  final String projectName;
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final double completionRate;
}
