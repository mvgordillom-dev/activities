import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../projects/providers/project_provider.dart';
import '../../models/task_item.dart';
import '../../providers/task_provider.dart';

class TaskFormView extends StatefulWidget {
  const TaskFormView({
    super.key,
    this.onSaved,
  });

  final VoidCallback? onSaved;

  @override
  State<TaskFormView> createState() => _TaskFormViewState();
}

class _TaskFormViewState extends State<TaskFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _responsibleController = TextEditingController();
  final _hoursController = TextEditingController(text: '1');
  TaskType _selectedType = TaskType.normal;
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  String? _selectedProjectId;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _responsibleController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 700;
    final projects = context.watch<ProjectProvider>().projects;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create daily work log',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Each entry stores hours logged for a single day and project. Logged hours are never cumulative estimates.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 22),
          _ResponsiveFields(
            isWide: isWide,
            spacing: 16,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Work item name'),
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
            maxLines: 4,
            validator: _requiredValidator,
          ),
          const SizedBox(height: 16),
          _ResponsiveFields(
            isWide: isWide,
            spacing: 16,
            children: [
              TextFormField(
                controller: _responsibleController,
                decoration: const InputDecoration(labelText: 'Responsible'),
                validator: _requiredValidator,
              ),
              DropdownButtonFormField<String?>(
                value: _selectedProjectId,
                decoration: const InputDecoration(labelText: 'Project'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Others'),
                  ),
                  ...projects.map(
                    (project) => DropdownMenuItem<String?>(
                      value: project.id,
                      child: Text(project.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedProjectId = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ResponsiveFields(
            isWide: isWide,
            spacing: 16,
            children: [
              TextFormField(
                controller: _hoursController,
                decoration: const InputDecoration(
                  labelText: 'Hours logged for this day',
                  helperText: 'Example: 2 hours for Project A on a specific date.',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _hoursValidator,
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
                OutlinedButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Save daily entry'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _hoursValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Hours logged are required';
    }

    final hours = double.tryParse(value.trim());
    if (hours == null || hours <= 0) {
      return 'Enter a valid number greater than 0';
    }

    return null;
  }

  Future<void> _pickDateTime() async {
    final selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
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
          name: _nameController.text.trim(),
          type: _selectedType,
          description: _descriptionController.text.trim(),
          date: _selectedDate,
          responsible: _responsibleController.text.trim(),
          hours: double.parse(_hoursController.text.trim()),
          projectId: _selectedProjectId,
        );

    widget.onSaved?.call();
    Navigator.of(context).pop();
  }
}

class _ResponsiveFields extends StatelessWidget {
  const _ResponsiveFields({
    required this.isWide,
    required this.children,
    this.spacing = 12,
  });

  final bool isWide;
  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < children.length; index++) ...[
            Expanded(child: children[index]),
            if (index != children.length - 1) SizedBox(width: spacing),
          ],
        ],
      );
    }

    return Column(
      children: [
        for (var index = 0; index < children.length; index++) ...[
          children[index],
          if (index != children.length - 1) SizedBox(height: spacing),
        ],
      ],
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
          labelText: 'Entry date',
          helperText: 'Daily log date for this project entry.',
          suffixIcon: Icon(Icons.calendar_month_rounded),
        ),
        child: Text('$formatted • $time'),
      ),
    );
  }
}
