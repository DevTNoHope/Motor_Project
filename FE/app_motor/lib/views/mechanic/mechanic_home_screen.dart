import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../models/role.dart';
class MechanicHomeScreen extends StatelessWidget {
  const MechanicHomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (!auth.ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!auth.logged) {
      Future.microtask(() => context.go('/login'));
      return const SizedBox();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        actions: [
          IconButton(
            onPressed: () async {
              await context.read<AuthController>().logout();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Center(child: Text('Trang thợ sửa (WIP)')),
    );
  }
}
