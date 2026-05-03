import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  bool get isAuthenticated => _token != null;

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    notifyListeners();
  }
  Future<String?> signup(String name, String email, String password) async {
    try {
      await ApiService.signup(name, email, password);
      // If signup is successful, log them in automatically
      final success = await login(email, password);
      if (success) return null; // null means no error
      return "Signup successful, but auto-login failed.";
    } catch (e) {
      // Return the error message to show in the UI
      return e.toString().replaceAll('Exception: Signup failed: ', '');
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final data = await ApiService.login(email, password);
      if (data.containsKey('token')) {
        _token = data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    notifyListeners();
  }
}