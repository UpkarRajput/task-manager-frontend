import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'project_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<dynamic>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _refreshProjects();
  }

  void _refreshProjects() {
    setState(() {
      _projectsFuture = ApiService.getProjects();
    });
  }

  void _showCreateProjectDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Create New Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Project Name'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await ApiService.createProject(nameController.text, descController.text);
                Navigator.pop(context);
                _refreshProjects(); // Reload the list
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
       backgroundColor: Colors.white,
       appBar: AppBar(
        title: const Text('My Projects', selectionColor: Colors.purple, ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.logout(),
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _projectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No projects yet. Create one!'));
          }

          final projects = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return Card(
                color: Colors.white,
                elevation: 4,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectDetailScreen(
                          projectId: project['id'],
                          projectName: project['name'],
                          role: project['role'], // Admin or Member
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project['name'],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                       const SizedBox(height: 8),
Text(
  project['description'] ?? 'No description',
  style: TextStyle(color: Colors.grey[600]), // <-- Fixed here
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
),
                        const Spacer(),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Chip(
                            label: Text(project['role']),
                            backgroundColor: project['role'] == 'Admin' ? Colors.blue[100] : Colors.green[100],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _showCreateProjectDialog,
        tooltip: 'New Project',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}