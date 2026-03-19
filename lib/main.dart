import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/tasks/providers/task_provider.dart';
import 'features/tasks/services/task_service.dart';
import 'features/tasks/ui/screens/task_board_screen.dart';

void main() {
  runApp(const TaskManagementApp());
}

class TaskManagementApp extends StatelessWidget {
  const TaskManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(TaskService())..loadInitialTasks(),
      child: MaterialApp(
        title: 'Task Management',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const TaskBoardScreen(),
      ),
    );
  }
}
