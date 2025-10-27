import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../pages/add_edit_task_page.dart';

class TaskTile extends ConsumerWidget {
  final Task task;
  const TaskTile({super.key, required this.task});

  // Helper to get priority color
  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 2:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 0:
      default:
        return Colors.grey;
    }
  }

  // Helper to get priority text
  String _getPriorityText(int priority) {
    switch (priority) {
      case 2:
        return 'High';
      case 1:
        return 'Medium';
      case 0:
      default:
        return 'Low';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(task.id), 
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) {
        ref.read(taskListProvider.notifier).deleteTask(task);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task "${task.title}" deleted')),
        );
      },
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEditTaskPage(task: task),
            ),
          );
        },
        leading: Checkbox(
          value: task.isDone,
          onChanged: (value) {
            ref.read(taskListProvider.notifier).toggleDone(task);
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: task.dueDate != null || task.priority > 0
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.dueDate != null)
                    Text(
                      'Due: ${DateFormat('MMM d, y').format(task.dueDate!)}',
                      style: TextStyle(
                        color: task.isDone
                            ? Colors.grey
                            : (task.dueDate!.isBefore(DateTime.now())
                                ? Colors.red
                                : Colors.blueGrey),
                        fontSize: 12,
                      ),
                    ),
                  Text(
                    'Priority: ${_getPriorityText(task.priority)}',
                    style: TextStyle(
                      color: _getPriorityColor(task.priority),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}