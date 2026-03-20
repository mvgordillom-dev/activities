import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:intl/intl.dart';

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
          (entry) => ProjectReportSummary(
            projectName: entry.key,
            entryCount: entry.value.length,
            doneEntryCount: entry.value.where((task) => task.status.isDone).length,
            daysTracked: {
              for (final task in entry.value)
                DateTime(task.date.year, task.date.month, task.date.day),
            }.length,
            totalHours: entry.value.fold<double>(0.0, (total, task) => total + task.hours),
          ),
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

  Future<String> exportMonthlyHoursReport({
    required DateTime month,
    required List<TaskItem> tasks,
    required String Function(String? projectId) resolveProjectName,
    required String Function(String? projectId) resolveProjectStatusLabel,
  }) async {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null && defaultSheet != 'Daily Hours') {
      excel.delete(defaultSheet);
    }

    final sheet = excel['Daily Hours'];
    sheet.appendRow([
      TextCellValue('Project'),
      TextCellValue('Task'),
      TextCellValue('Description'),
      TextCellValue('Creation date'),
      TextCellValue('Completion date'),
      TextCellValue('Hours spent'),
      TextCellValue('Assigned to'),
      TextCellValue('Project status'),
    ]);

    final sortedTasks = [...tasks]
      ..sort((first, second) {
        final projectComparison =
            resolveProjectName(first.projectId).compareTo(resolveProjectName(second.projectId));
        if (projectComparison != 0) {
          return projectComparison;
        }

        final dateComparison = first.date.compareTo(second.date);
        if (dateComparison != 0) {
          return dateComparison;
        }

        return first.name.compareTo(second.name);
      });

    final dateFormat = DateFormat('yyyy-MM-dd');
    for (final task in sortedTasks) {
      sheet.appendRow([
        TextCellValue(resolveProjectName(task.projectId)),
        TextCellValue(task.name),
        TextCellValue(task.description),
        TextCellValue(dateFormat.format(task.date)),
        TextCellValue(task.completedOn == null ? '' : dateFormat.format(task.completedOn!)),
        DoubleCellValue(task.hours),
        TextCellValue(task.responsible),
        TextCellValue(resolveProjectStatusLabel(task.projectId)),
      ]);
    }

    final monthSlug = DateFormat('yyyy-MM').format(month);
    final fileName = 'daily-hours-report-$monthSlug';
    final bytes = excel.encode();
    if (bytes == null) {
      throw StateError('Unable to generate the Excel workbook.');
    }

    await FileSaver.instance.saveFile(
      name: fileName,
      bytes: Uint8List.fromList(bytes),
      ext: 'xlsx',
      mimeType: MimeType.other,
    );

    return '$fileName.xlsx';
  }
}
