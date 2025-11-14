import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../models/role.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
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
    if (auth.role == AppRole.mechanic) {
      Future.microtask(() => context.go('/mechanic'));
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Hồ sơ cá nhân'),
            onTap: () => context.push('/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.motorcycle),
            title: const Text('Xe của tôi'),
            onTap: () => context.push('/vehicles'),
          ),
          ListTile(
            leading: const Icon(Icons.miscellaneous_services),
            title: const Text('Đặt lịch dịch vụ'),
            onTap: () => context.push('/booking')
            ,
          ),
        ],
      ),
    );
  }
}
