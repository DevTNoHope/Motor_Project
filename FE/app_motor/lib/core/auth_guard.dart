import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../models/role.dart';

/// Dùng để bọc 1 screen. Nếu role hiện tại không thuộc [allowed],
/// tự điều hướng sang [redirectWhenDenied].
class AuthGate extends StatelessWidget {
  final Set<AppRole> allowed;
  final String redirectWhenDenied;
  final Widget child;
  final bool blockAdminWithDialog;

  const AuthGate({
    super.key,
    required this.allowed,
    required this.redirectWhenDenied,
    required this.child,
    this.blockAdminWithDialog = true,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    if (!auth.ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Chưa đăng nhập -> về /login
    if (!auth.logged) {
      Future.microtask(() => context.go('/login'));
      return const SizedBox.shrink();
    }

    // Chặn admin trên app mobile
    if (auth.role == AppRole.admin && blockAdminWithDialog) {
      Future.microtask(() async {
        await showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('Không hỗ trợ'),
            content: Text('Tài khoản admin chỉ đăng nhập thông qua admin web.'),
          ),
        );
        if (context.mounted) {
          await context.read<AuthController>().logout();
          context.go('/login');
        }
      });
      return const SizedBox.shrink();
    }

    // Nếu role không thuộc danh sách cho phép -> chuyển hướng
    if (!allowed.contains(auth.role)) {
      Future.microtask(() => context.go(redirectWhenDenied));
      return const SizedBox.shrink();
    }

    return child;
  }
}
