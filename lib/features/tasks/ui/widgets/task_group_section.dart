import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/task_item.dart';
import 'task_card.dart';

class TaskGroupSection extends StatelessWidget {
  const TaskGroupSection({
    super.key,
    required this.day,
    required this.tasks,
  });

  final DateTime day;
  final List<TaskItem> tasks;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final cards = tasks
        .map(
          (task) => SizedBox(
            width: isWide ? 380 : double.infinity,
            child: TaskCard(task: task),
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('EEEE, MMMM d, y').format(day),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${tasks.length} task${tasks.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        ),
        if (isWide)
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: cards,
          )
        else
          Column(
            children: [
              for (var index = 0; index < cards.length; index++) ...[
                cards[index],
                if (index != cards.length - 1) const SizedBox(height: 16),
              ],
            ],
          ),
      ],
    );
  }
}
