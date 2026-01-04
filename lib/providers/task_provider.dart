import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> _todayTasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Task> get tasks => _tasks;
  List<Task> get todayTasks => _todayTasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get todayDate => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await ApiService.getAllTasks();
      _todayTasks = await ApiService.getTasksByDate(todayDate);
      print('Loaded ${_tasks.length} tasks from API');
    } catch (e) {
      _errorMessage = 'Error loading tasks: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTask(Task task) async {
    try {
      final response = await ApiService.createTask(task);

      if (response['success']) {
        await loadTasks();
        return true;
      } else {
        _errorMessage = response['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error adding task: $e';
      print(_errorMessage);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(Task task) async {
    try {
      final response = await ApiService.updateTask(task);

      if (response['success']) {
        await loadTasks();
        return true;
      } else {
        _errorMessage = response['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error updating task: $e';
      print(_errorMessage);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      final response = await ApiService.deleteTask(id);

      if (response['success']) {
        await loadTasks();
        return true;
      } else {
        _errorMessage = response['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error deleting task: $e';
      print(_errorMessage);
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleTaskCompletion(int id, bool isCompleted) async {
    try {
      final response = await ApiService.toggleTaskCompletion(id, isCompleted);

      if (response['success']) {
        await loadTasks();
        return true;
      } else {
        _errorMessage = response['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error toggling task: $e';
      print(_errorMessage);
      notifyListeners();
      return false;
    }
  }

  Future<List<Task>> getTasksByDate(String date) async {
    try {
      return await ApiService.getTasksByDate(date);
    } catch (e) {
      _errorMessage = 'Error getting tasks by date: $e';
      print(_errorMessage);
      notifyListeners();
      return [];
    }
  }

  int getTaskCount() {
    return _tasks.length;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
