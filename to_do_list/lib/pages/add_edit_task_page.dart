import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class AddEditTaskPage extends ConsumerStatefulWidget {
  final Task? task; 
  const AddEditTaskPage({super.key, this.task});

  @override
  ConsumerState<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends ConsumerState<AddEditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late DateTime? _dueDate;
  late int _priority; 

  @override
  void initState() {
    super.initState();
    
    final task = widget.task;
    _title = task?.title ?? '';
    _description = task?.description ?? '';
    _dueDate = task?.dueDate;
    _priority = task?.priority ?? 0;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = ref.read(taskListProvider.notifier);

      if (widget.task == null) {
        provider.addTask(
          title: _title,
          dueDate: _dueDate,
          priority: _priority,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task added successfully!')),
        );
      } else {
        final updatedTask = widget.task!.copyWith(
          title: _title,
          description: _description,
          dueDate: _dueDate,
          priority: _priority,
        );
        provider.editTask(updatedTask);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task updated successfully!')),
        );
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'Add New Task'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: _description,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Details (Optional)',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _description = value ?? '',
              ),
              const SizedBox(height: 24),

              ListTile(
                title: const Text('Due Date'),
                subtitle: Text(
                  _dueDate == null
                      ? 'No due date set'
                      : DateFormat('EEEE, MMM d, y').format(_dueDate!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              if (_dueDate != null)
                TextButton.icon(
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Due Date'),
                  onPressed: () {
                    setState(() {
                      _dueDate = null;
                    });
                  },
                ),
              const Divider(),
              const SizedBox(height: 16),

              // --- Priority Dropdown ---
              const Text('Priority', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Column(
                children: [
                  RadioListTile<int>(
                    title: const Text('Low'),
                    value: 0,
                    groupValue: _priority,
                    onChanged: (int? value) => setState(() => _priority = value!),
                  ),
                  RadioListTile<int>(
                    title: const Text('Medium'),
                    value: 1,
                    groupValue: _priority,
                    onChanged: (int? value) => setState(() => _priority = value!),
                    activeColor: Colors.orange,
                  ),
                  RadioListTile<int>(
                    title: const Text('High'),
                    value: 2,
                    groupValue: _priority,
                    onChanged: (int? value) => setState(() => _priority = value!),
                    activeColor: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- Save Button ---
              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  isEditing ? 'Save Changes' : 'Add Task',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}