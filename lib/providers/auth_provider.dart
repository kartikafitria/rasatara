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

  Future<void> signInWithGoogle() async {
    final result = await _authService.signInWithGoogle();
    if (result != null) {
      _user = result.user;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}
