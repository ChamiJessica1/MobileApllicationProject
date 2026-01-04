import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart' as auth_service;
import '../services/api_service.dart' as api_service;

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      final id = prefs.getInt('user_id') ?? 0;
      final username = prefs.getString('username') ?? '';
      final email = prefs.getString('email') ?? '';
      final fullName = prefs.getString('full_name');

      _user = User(
        id: id,
        username: username,
        email: email,
        fullName: fullName,
        token: token,
      );

      api_service.ApiService.setToken(token);
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await auth_service.AuthService.login(
        username: username,
        password: password,
      );

      if (result['success']) {
        _user = result['user'];
        await _saveUserData(_user!);

        api_service.ApiService.setToken(_user!.token);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await auth_service.AuthService.register(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
      );

      if (result['success']) {
        _user = result['user'];
        await _saveUserData(_user!);
        api_service.ApiService.setToken(_user!.token);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    api_service.ApiService.clearToken();
    _user = null;
    notifyListeners();
  }

  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user.id);
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
    if (user.fullName != null) {
      await prefs.setString('full_name', user.fullName!);
    }
    await prefs.setString('token', user.token);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
