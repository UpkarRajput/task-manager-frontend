import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // IMPORTANT: For local testing, use localhost. 
  // When you deploy to Railway, you will change this to your Railway Node.js URL.
static const String baseUrl = 'https://task-manager-deployment-production-96b5.up.railway.app/api';

  // Helper to get headers with JWT token
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  static Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      // If email already exists, the backend sends a 400 error
      throw Exception('Signup failed: ${jsonDecode(response.body)['error']}');
    }
  }

  // --- AUTHENTICATION ---
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }
  

  // --- PROJECTS ---
  static Future<List<dynamic>> getProjects() async {
    final response = await http.get(
      Uri.parse('$baseUrl/projects'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load projects');
  }

  static Future<void> createProject(String name, String description) async {
    final response = await http.post(
      Uri.parse('$baseUrl/projects'),
      headers: await _getHeaders(),
      body: jsonEncode({'name': name, 'description': description}),
    );
    if (response.statusCode != 201) throw Exception('Failed to create project');
  }

  static Future<void> createTask(int projectId, String title, String dueDate) async {
    final response = await http.post(
      Uri.parse('$baseUrl/projects/$projectId/tasks'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'title': title,
        'due_date': dueDate,
        // We leave 'assigned_to' null for now to keep the UI simple
      }),
    );
    if (response.statusCode != 201) throw Exception('Failed to create task');
  }

  // --- TASKS ---
  static Future<List<dynamic>> getTasks(int projectId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/projects/$projectId/tasks'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load tasks');
  }

  static Future<void> updateTaskStatus(int taskId, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/projects/tasks/$taskId/status'),
      headers: await _getHeaders(),
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode != 200) throw Exception('Failed to update task');
  }
}