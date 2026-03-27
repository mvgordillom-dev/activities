import 'package:flutter/material.dart';

import '../../features/projects/ui/screens/project_management_screen.dart';
import '../../features/reports/ui/screens/reports_screen.dart';
import '../../features/tasks/ui/screens/task_board_screen.dart';
import '../../features/tasks/ui/screens/add_task_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final screens = [
      TaskBoardScreen(onCreateTask: _openTaskDialog),
      const ProjectManagementScreen(),
      const ReportsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities Dashboard'),
      ),
      body: isWide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _onDestinationSelected,
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.checklist_rounded),
                      label: Text('Tasks'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.folder_copy_rounded),
                      label: Text('Projects'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.assessment_rounded),
                      label: Text('Reports'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: screens[_currentIndex]),
              ],
            )
          : screens[_currentIndex],
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onDestinationSelected,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.checklist_rounded),
                  label: 'Tasks',
                ),
                NavigationDestination(
                  icon: Icon(Icons.folder_copy_rounded),
                  label: 'Projects',
                ),
                NavigationDestination(
                  icon: Icon(Icons.assessment_rounded),
                  label: 'Reports',
                ),
              ],
            ),
      floatingActionButton: _currentIndex == 0 && !isWide
          ? FloatingActionButton.extended(
              onPressed: _openTaskDialog,
              icon: const Icon(Icons.add_task_rounded),
              label: const Text('New Entry'),
            )
          : null,
    );
  }

  void _onDestinationSelected(int value) {
    setState(() {
      _currentIndex = value;
    });
  }

  void _openTaskDialog() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AddTaskScreen(),
      ),
    );
  }
}
