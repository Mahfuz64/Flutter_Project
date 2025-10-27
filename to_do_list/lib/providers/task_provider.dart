import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart'; 

import '../models/task.dart';
import '../services/sqlite_service.dart'; 

final sqliteServiceProvider = Provider((ref) => SQLiteService());

class TaskListNotifier extends StateNotifier<List<Task>> {
  final SQLiteService _sqliteService;
  final Uuid _uuid = const Uuid();

  TaskListNotifier(this._sqliteService) : super([]) {
    loadTasks();
  }

  void loadTasks() async { 
    state = await _sqliteService.getAllTasks();
  }

  Future<void> addTask({
    required String title,
    DateTime? dueDate,
    int priority = 0,
  }) async {
    final newTask = Task(
      id: _uuid.v4(),
      title: title,
      dueDate: dueDate,
      priority: priority,
    );
    await _sqliteService.addTask(newTask); 
    loadTasks(); 
  }

  Future<void> editTask(Task task) async {
    await _sqliteService.updateTask(task); 
    loadTasks();
  }

  Future<void> toggleDone(Task task) async {
    task.isDone = !task.isDone;
    await _sqliteService.updateTask(task); 
    loadTasks(); 
  }

  Future<void> deleteTask(Task task) async {
    await _sqliteService.deleteTask(task); 
    loadTasks();
  }
}

final taskListProvider = StateNotifierProvider<TaskListNotifier, List<Task>>((ref) {
  final sqliteService = ref.watch(sqliteServiceProvider);
  return TaskListNotifier(sqliteService);
});