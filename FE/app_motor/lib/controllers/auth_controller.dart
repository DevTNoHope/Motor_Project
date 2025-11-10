import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final _auth = AuthService();
  bool _ready = false;
  bool _logged = false;

  bool get ready => _ready;
  bool get logged => _logged;

  Future<void> init() async {
    _logged = await _auth.hasToken();
    _ready = true;
    notifyListeners();
  }

  Future<void> login(String email, String pass) async {
    await _auth.login(email, pass);
    _logged = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.logout();
    _logged = false;
    notifyListeners();
  }
}
