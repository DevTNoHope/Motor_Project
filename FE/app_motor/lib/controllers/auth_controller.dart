import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/env.dart';
import '../services/auth_service.dart';
import '../models/role.dart';
import '../services/notification_socket_service.dart';

class AuthController extends ChangeNotifier {
  final _auth = AuthService();
  bool _ready = false;
  bool _logged = false;
  AppRole _role = AppRole.unknown;
  String? _name;
  int? _userId;

  bool get ready => _ready;
  bool get logged => _logged;
  AppRole get role => _role;
  String? get name => _name;

  // GoogleSignIn instance
  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId: Env.googleWebClientId,
  );

  Future<void> init() async {
    _logged = await _auth.hasToken();
    if (_logged) {
      _role = await _auth.currentRole();
      _name = await _auth.currentName();
      _userId = await _auth.currentUserId();
      if (_userId != null) {
        NotificationSocketService.I.connect(userId: _userId!);
      }
    } else {
      _role = AppRole.unknown;
      _name = null;
    }
    _ready = true;
    notifyListeners();
  }

  Future<AppRole> login(String email, String pass) async {
    final r = await _auth.login(email, pass);
    _logged = true;
    _role = r;
    _name = await _auth.currentName();

    _userId = await _auth.currentUserId();
    if (_userId != null) {
      NotificationSocketService.I.connect(userId: _userId!);
    }

    notifyListeners();
    return r;
  }

  /// 🔹 Login bằng Google
  /// - Trả về AppRole khi login thành công
  /// - Trả về null nếu user bấm hủy chọn tài khoản
  Future<AppRole?> loginWithGoogle() async {
    // 1. Mở màn chọn tài khoản Google
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // user hủy
      return null;
    }

    // 2. Lấy idToken
    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) {
      throw Exception('Không lấy được idToken từ Google');
    }

    // 3. Gọi BE để lấy accessToken và role
    final r = await _auth.loginWithGoogle(idToken);

    _logged = true;
    _role = r;
    _name = await _auth.currentName();

    _userId = await _auth.currentUserId();
    if (_userId != null) {
      NotificationSocketService.I.connect(userId: _userId!);
    }

    notifyListeners();
    return r;
  }

  Future<void> logout() async {
    await _auth.logout();
    await _googleSignIn.signOut();
    _logged = false;
    _role = AppRole.unknown;

    _userId = null;

    // ngắt socket khi logout
    NotificationSocketService.I.disconnect();

    notifyListeners();
  }
}
