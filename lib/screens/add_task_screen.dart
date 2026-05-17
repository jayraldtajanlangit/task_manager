import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'add_task_form');
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  Priority _priority = Priority.medium;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<TaskProvider>().addTask(
      Task(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // ── Title ──────────────────────────────────────────────
              TextFormField(
                key: const Key('title_field'),
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  hintText: 'Enter task title',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(height: 16),
              // ── Description ────────────────────────────────────────
              TextFormField(
                key: const Key('desc_field'),
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Optional details',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // ── Priority ───────────────────────────────────────────
              DropdownButtonFormField<Priority>(
                key: const Key('priority_dropdown'),
                initialValue: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: Priority.values
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _priority = v!),
              ),
              const SizedBox(height: 16),
              // ── Due Date ───────────────────────────────────────────
              ListTile(
                key: const Key('due_date_tile'),
                contentPadding: EdgeInsets.zero,
                title: const Text('Due Date'),
                subtitle: Text(
                  '${_dueDate.year}-${_dueDate.month.toString().padLeft(2, '0')}-${_dueDate.day.toString().padLeft(2, '0')}',
                  key: const Key('due_date_label'),
                ),
                trailing: TextButton(
                  key: const Key('pick_date_btn'),
                  onPressed: _pickDate,
                  child: const Text('Change'),
                ),
              ),
              const SizedBox(height: 24),
              // ── Submit ─────────────────────────────────────────────
              ElevatedButton(
                key: const Key('submit_btn'),
                onPressed: _submit,
                child: const Text('Add Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
