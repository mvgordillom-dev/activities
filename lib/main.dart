import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/navigation/app_shell.dart';
import 'core/theme/app_theme.dart';
import 'features/projects/providers/project_provider.dart';
import 'features/projects/services/project_service.dart';
import 'features/tasks/providers/task_provider.dart';
import 'features/tasks/services/task_service.dart';
import 'features/tasks/services/task_signalr_service.dart';

void main() {
  runApp(const TaskManagementApp());
}

class TaskManagementApp extends StatelessWidget {
  const TaskManagementApp({super.key});

  static const _taskHubUrl = String.fromEnvironment(
    'TASK_HUB_URL',
    defaultValue: 'http://localhost:5000/hubs/tasks',
  );

  @override
  Widget build(BuildContext context) {
    final taskService = TaskService(
      realtimeService: TaskSignalRService(hubUrl: _taskHubUrl),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProjectProvider(ProjectService())..loadInitialProjects(),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(taskService)..loadInitialTasks(),
        ),
      ],
      child: MaterialApp(
        title: 'Activities Dashboard',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AppShell(),
      ),
    );
  }
}
