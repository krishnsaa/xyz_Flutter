import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? _userId;
  String? _token;
  bool _isLoading = true;

  String? get userId => _userId;
  String? get token => _token;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    _token = prefs.getString('token');
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setUserData(String id, String token) async {
    _userId = id;
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', id);
    await prefs.setString('token', token);
    notifyListeners();
  }

  Future<void> logout() async {
    _userId = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('token');
    notifyListeners();
  }
}
