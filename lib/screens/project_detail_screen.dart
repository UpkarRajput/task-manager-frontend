import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProjectDetailScreen extends StatefulWidget {
  final int projectId;
  final String projectName;
  final String role; // 'Admin' or 'Member'

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.role,
  });

  @override
  _ProjectDetailScreenState createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late Future<List<dynamic>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  void _refreshTasks() {
    setState(() {
      _tasksFuture = ApiService.getTasks(widget.projectId);
    });
  }

  // --- DIALOG: CREATE TASK (Admin Only) ---
  void _showCreateTaskDialog() {
    final titleController = TextEditingController();

    // Default to tomorrow's date for simplicity
    String dueDate = DateTime.now()
        .add(const Duration(days: 1))
        .toIso8601String()
        .split('T')[0];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('New Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                  labelText: 'Task Title (e.g. Design UI)'),
            ),
            const SizedBox(height: 10),
            Text('Due Date: $dueDate',
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                await ApiService.createTask(
                    widget.projectId, titleController.text, dueDate);
                Navigator.pop(context);
                _refreshTasks(); // Reload the task list
              }
            },
            child: const Text('Create Task'),
          ),
        ],
      ),
    );
  }

  // --- DIALOG: UPDATE STATUS (All Members) ---
  void _showUpdateStatusDialog(int taskId, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('To Do'),
              leading: Radio<String>(
                value: 'To Do',
                groupValue: currentStatus,
                onChanged: (value) async {
                  await ApiService.updateTaskStatus(taskId, value!);
                  Navigator.pop(context);
                  _refreshTasks();
                },
              ),
            ),
            ListTile(
              title: const Text('In Progress'),
              leading: Radio<String>(
                value: 'In Progress',
                groupValue: currentStatus,
                onChanged: (value) async {
                  await ApiService.updateTaskStatus(taskId, value!);
                  Navigator.pop(context);
                  _refreshTasks();
                },
              ),
            ),
            ListTile(
              title: const Text('Done'),
              leading: Radio<String>(
                value: 'Done',
                groupValue: currentStatus,
                onChanged: (value) async {
                  await ApiService.updateTaskStatus(taskId, value!);
                  Navigator.pop(context);
                  _refreshTasks();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${widget.projectName} Tasks'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tasks in this project.'));
          }

          final tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];

              // Color code based on status
              Color statusColor = Colors.grey;
              if (task['status'] == 'In Progress') statusColor = Colors.orange;
              if (task['status'] == 'Done') statusColor = Colors.green;

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(task['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Due: ${task['due_date'].toString().substring(0, 10)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        label: Text(task['status'],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                        backgroundColor: statusColor,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            _showUpdateStatusDialog(task['id'], task['status']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // ROLE-BASED ACCESS: Only show the "Add Task" button if the user is an Admin
      floatingActionButton: widget.role == 'Admin'
          ? FloatingActionButton.extended(
            backgroundColor: Colors.blue,
              onPressed: _showCreateTaskDialog,
              icon: const Icon(Icons.add_task, color: Colors.white),
              label: const Text('New Task', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }
}
