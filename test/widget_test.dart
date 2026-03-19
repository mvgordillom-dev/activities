import 'package:activities/features/tasks/providers/task_provider.dart';
import 'package:activities/features/tasks/services/task_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('completing a task removes it from the provider list', () {
    final provider = TaskProvider(TaskService())..loadInitialTasks();
    final initialTask = provider.tasks.first;

    provider.completeTask(initialTask);

    expect(provider.tasks.contains(initialTask), isFalse);
    expect(provider.tasks.length, 2);
  });
}
