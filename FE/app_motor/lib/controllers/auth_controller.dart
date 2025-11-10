import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/role.dart';

class AuthController extends ChangeNotifier {
  final _auth = AuthService();
  bool _ready = false;
  bool _logged = false;
  AppRole _role = AppRole.unknown;

  bool get ready => _ready;
  bool get logged => _logged;
  AppRole get role => _role;

  Future<void> init() async {
    _logged = await _auth.hasToken();
    _role = _logged ? await _auth.currentRole() : AppRole.unknown;
    _ready = true;
    notifyListeners();
  }

  Future<AppRole> login(String email, String pass) async {
    final r = await _auth.login(email, pass);
    _logged = true;
    _role = r;
    notifyListeners();
    return r;
  }

  Future<void> logout() async {
    await _auth.logout();
    _logged = false;
    _role = AppRole.unknown;
    notifyListeners();
  }
}
