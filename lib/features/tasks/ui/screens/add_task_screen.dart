import 'package:flutter/material.dart';

import '../../../../core/widgets/section_card.dart';
import '../widgets/task_form_dialog.dart';

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: isWide ? 32 : 16,
            right: isWide ? 32 : 16,
            top: 20,
            bottom: 20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 840 : 720),
              child: const SectionCard(
                child: TaskFormView(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
