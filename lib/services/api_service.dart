import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/task.dart';

class AuthService {
  static const String baseUrl = 'http://localhost/daily_planner_api/auth.php';

  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl?action=register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'full_name': fullName,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success']) {
        return {'success': true, 'user': User.fromJson(data['data'])};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl?action=login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (data['success']) {
        return {'success': true, 'user': User.fromJson(data['data'])};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?action=profile&token=$token'),
      );

      final data = jsonDecode(response.body);

      if (data['success']) {
        return {'success': true, 'user': data['data']};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}

class ApiService {
  static const String baseUrl = 'http://localhost/daily_planner_api/tasks.php';
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static void clearToken() {
    _token = null;
  }

  static Future<List<Task>> getAllTasks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl?action=get_all'));

      final data = jsonDecode(response.body);

      if (data['success']) {
        return (data['data'] as List)
            .map((task) => Task.fromJson(task))
            .toList();
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      throw Exception('Error loading tasks: $e');
    }
  }

  static Future<List<Task>> getTasksByDate(String date) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?action=get_by_date&date=$date'),
      );

      final data = jsonDecode(response.body);

      if (data['success']) {
        return (data['data'] as List)
            .map((task) => Task.fromJson(task))
            .toList();
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      throw Exception('Error loading tasks by date: $e');
    }
  }

  static Future<Map<String, dynamic>> createTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl?action=create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(task.toJson()),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl?action=update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(task.toJson()),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteTask(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl?action=delete&id=$id'),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> toggleTaskCompletion(
    int id,
    bool isCompleted,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl?action=toggle_completion&id=$id&completed=${isCompleted ? 1 : 0}',
        ),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl?action=statistics'));

      final data = jsonDecode(response.body);

      if (data['success']) {
        return data['data'];
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      throw Exception('Error loading statistics: $e');
    }
  }
}
