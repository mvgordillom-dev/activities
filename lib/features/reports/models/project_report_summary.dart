class ProjectReportSummary {
  const ProjectReportSummary({
    required this.projectName,
    required this.entryCount,
    required this.doneEntryCount,
    required this.daysTracked,
    required this.totalHours,
  });

  final String projectName;
  final int entryCount;
  final int doneEntryCount;
  final int daysTracked;
  final double totalHours;
}
