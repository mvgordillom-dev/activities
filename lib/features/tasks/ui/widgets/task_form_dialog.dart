import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task_item.dart';
import '../../providers/task_provider.dart';

class TaskFormDialog extends StatefulWidget {
  const TaskFormDialog({super.key});

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _responsibleController = TextEditingController();
  TaskType _selectedType = TaskType.normal;
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _responsibleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 700;

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create task',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add a task with priority, scheduling, and responsibility details.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 22),
                _ResponsiveFields(
                  isWide: isWide,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Task name'),
                      validator: _requiredValidator,
                    ),
                    DropdownButtonFormField<TaskType>(
                      value: _selectedType,
                      decoration: const InputDecoration(labelText: 'Priority type'),
                      items: TaskType.values
                          .map(
                            (type) => DropdownMenuItem<TaskType>(
                              value: type,
                              child: Text(type.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _selectedType = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 16),
                _ResponsiveFields(
                  isWide: isWide,
                  children: [
                    TextFormField(
                      controller: _responsibleController,
                      decoration: const InputDecoration(labelText: 'Responsible'),
                      validator: _requiredValidator,
                    ),
                    _DateSelector(
                      selectedDate: _selectedDate,
                      onSelect: _pickDateTime,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      FilledButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Save task'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Future<void> _pickDateTime() async {
    final selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _selectedDate,
    );

    if (!mounted || selectedDate == null) {
      return;
    }

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );

    if (!mounted || selectedTime == null) {
      return;
    }

    setState(() {
      _selectedDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<TaskProvider>().addTask(
          TaskItem(
            name: _nameController.text.trim(),
            type: _selectedType,
            description: _descriptionController.text.trim(),
            date: _selectedDate,
            responsible: _responsibleController.text.trim(),
            completed: false,
          ),
        );

    Navigator.of(context).pop();
  }
}

class _ResponsiveFields extends StatelessWidget {
  const _ResponsiveFields({
    required this.isWide,
    required this.children,
  });

  final bool isWide;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Row(
        children: children
            .map(
              (child) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: child,
                ),
              ),
            )
            .toList(),
      );
    }

    return Column(
      children: children
          .map(
            (child) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: child,
            ),
          )
          .toList(),
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.selectedDate,
    required this.onSelect,
  });

  final DateTime selectedDate;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final formatted = MaterialLocalizations.of(context).formatFullDate(selectedDate);
    final time = TimeOfDay.fromDateTime(selectedDate).format(context);

    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date & time',
          suffixIcon: Icon(Icons.calendar_month_rounded),
        ),
        child: Text('$formatted • $time'),
      ),
    );
  }
}
