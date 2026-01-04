import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobileapplication_project/models/task.dart';
import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'http://localhost/daily_planner_api/api.php';

  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static void clearToken() {
    _token = null;
  }

  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
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
        final userData = data['user'];
        return {
          'success': true,
          'user': User(
            id: userData['id'],
            username: userData['username'],
            email: userData['email'],
            fullName: userData['full_name'],
            token: userData['token'],
          ),
        };
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

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
        final userData = data['user'];
        return {
          'success': true,
          'user': User(
            id: userData['id'],
            username: userData['username'],
            email: userData['email'],
            fullName: userData['full_name'],
            token: userData['token'],
          ),
        };
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> createTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl?action=create&token=$_token'),
        headers: _getHeaders(),
        body: jsonEncode(task.toMap()),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<List<Task>> getAllTasks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?action=getAll&token=$_token'),
        headers: _getHeaders(),
      );
      final data = jsonDecode(response.body);

      if (data['success']) {
        return (data['data'] as List)
            .map((json) => Task.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  static Future<List<Task>> getTasksByDate(String date) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?action=getByDate&date=$date&token=$_token'),
        headers: _getHeaders(),
      );
      final data = jsonDecode(response.body);

      if (data['success']) {
        return (data['data'] as List)
            .map((json) => Task.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?action=stats&token=$_token'),
        headers: _getHeaders(),
      );
      final data = jsonDecode(response.body);
      return data['success'] ? data['data'] : null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> updateTask(Task task) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl?action=update&token=$_token'),
        headers: _getHeaders(),
        body: jsonEncode(task.toMap()),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> toggleTaskCompletion(
    int id,
    bool isCompleted,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl?action=toggleComplete&token=$_token'),
        headers: _getHeaders(),
        body: jsonEncode({'id': id, 'is_completed': isCompleted ? 1 : 0}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteTask(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl?action=delete&id=$id&token=$_token'),
        headers: _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
