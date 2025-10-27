import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';
import 'add_edit_task_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final tasks = ref.watch(taskListProvider);

    final pendingTasks = tasks.where((task) => !task.isDone).toList();
    final completedTasks = tasks.where((task) => task.isDone).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📝To-Do'),
        backgroundColor: const Color.fromARGB(255, 15, 205, 44),
      ),
      body: tasks.isEmpty
          ? const Center(
              child: Text(
                'No tasks yet! Add one below.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView(
              children: [
                if (pendingTasks.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Pending Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ...pendingTasks.map((task) => TaskTile(task: task)).toList(),
                ],

                if (completedTasks.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0, bottom: 8.0),
                    child: Text('Completed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                  ),
                  ...completedTasks.map((task) => TaskTile(task: task)).toList(),
                ],
              ],
            ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditTaskPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}