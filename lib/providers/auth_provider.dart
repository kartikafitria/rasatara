import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _checkUser();
  }

  void _checkUser() {
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }

  // 🔹 LOGIN DENGAN GOOGLE
  Future<void> signInWithGoogle() async {
    final result = await _authService.signInWithGoogle();
    if (result != null) {
      _user = result.user;
      notifyListeners();
    }
  }

  // 🔹 LOGIN DENGAN EMAIL & PASSWORD
  Future<void> signInWithEmail(String email, String password) async {
    try {
      final result = await _authService.signInWithEmailPassword(email, password);
      if (result != null) {
        _user = result.user;
        notifyListeners();
      }
    } catch (e) {
      throw e;
    }
  }

  // 🔹 REGISTER DENGAN EMAIL & PASSWORD
  Future<void> register(String email, String password) async {
    try {
      final result = await _authService.registerWithEmailPassword(email, password);
      if (result != null) {
        _user = result.user;
        notifyListeners();
      }
    } catch (e) {
      throw e;
    }
  }

  // 🔹 LOGOUT
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}
