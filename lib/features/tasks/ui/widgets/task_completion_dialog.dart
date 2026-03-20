import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/task_item.dart';

class TaskCompletionDetails {
  const TaskCompletionDetails({
    required this.hours,
    required this.startedOn,
    required this.completedOn,
  });

  final double hours;
  final DateTime startedOn;
  final DateTime completedOn;
}

Future<TaskCompletionDetails?> showTaskCompletionDialog(
  BuildContext context, {
  required TaskItem task,
}) {
  return showDialog<TaskCompletionDetails>(
    context: context,
    builder: (dialogContext) => _TaskCompletionDialog(task: task),
  );
}

class _TaskCompletionDialog extends StatefulWidget {
  const _TaskCompletionDialog({required this.task});

  final TaskItem task;

  @override
  State<_TaskCompletionDialog> createState() => _TaskCompletionDialogState();
}

class _TaskCompletionDialogState extends State<_TaskCompletionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _hoursController;
  late DateTime _startedOn;
  late final DateTime _completedOn;

  @override
  void initState() {
    super.initState();
    _hoursController = TextEditingController(
      text: widget.task.hours.truncateToDouble() == widget.task.hours
          ? widget.task.hours.toStringAsFixed(0)
          : widget.task.hours.toStringAsFixed(2),
    );
    _startedOn = widget.task.startedOn ?? widget.task.date;
    _completedOn = DateTime.now();
  }

  @override
  void dispose() {
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Complete task'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add the hours spent and task start date before moving this task to Done.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hoursController,
              decoration: const InputDecoration(labelText: 'Hours spent'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validateHours,
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Task start date'),
              child: InkWell(
                onTap: _pickStartDate,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(DateFormat('MMMM d, y').format(_startedOn)),
                      ),
                      const Icon(Icons.expand_more_rounded),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save and complete'),
        ),
      ],
    );
  }

  String? _validateHours(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Hours are required';
    }

    final hours = double.tryParse(value.trim());
    if (hours == null || hours <= 0) {
      return 'Enter a valid number greater than 0';
    }

    return null;
  }

  Future<void> _pickStartDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _startedOn,
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (!mounted || selectedDate == null) {
      return;
    }

    setState(() {
      _startedOn = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      TaskCompletionDetails(
        hours: double.parse(_hoursController.text.trim()),
        startedOn: _startedOn,
        completedOn: DateTime(_completedOn.year, _completedOn.month, _completedOn.day),
      ),
    );
  }
}
