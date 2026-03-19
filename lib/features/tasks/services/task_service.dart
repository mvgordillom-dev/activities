import '../models/task_item.dart';

class TaskService {
  final List<TaskItem> _tasks = [
    TaskItem(
      name: 'Finalize sprint roadmap',
      type: TaskType.urgent,
      description: 'Align product scope, dependencies, and timeline for the next release.',
      date: DateTime.now().add(const Duration(hours: 3)),
      responsible: 'Alicia',
      completed: false,
    ),
    TaskItem(
      name: 'Prepare onboarding checklist',
      type: TaskType.normal,
      description: 'Create a welcome checklist for new team members joining next week.',
      date: DateTime.now().add(const Duration(days: 1, hours: 1)),
      responsible: 'Marcus',
      completed: false,
    ),
    TaskItem(
      name: 'Archive old design files',
      type: TaskType.noPriority,
      description: 'Clean outdated mockups and move relevant assets to shared storage.',
      date: DateTime.now().add(const Duration(days: 2, hours: 5)),
      responsible: 'Taylor',
      completed: false,
    ),
  ];

  List<TaskItem> fetchTasks() {
    return List.unmodifiable(_tasks);
  }

  void addTask(TaskItem task) {
    _tasks.add(task);
  }

  void completeTask(TaskItem task) {
    final index = _tasks.indexOf(task);
    if (index == -1) {
      return;
    }

    _tasks[index] = _tasks[index].copyWith(completed: true);
    _tasks.removeWhere((taskItem) => taskItem.completed);
  }
}
