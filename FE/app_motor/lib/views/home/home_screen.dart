import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (!auth.ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!auth.logged) {
      // chưa đăng nhập -> đi Login
      Future.microtask(() => context.go('/login'));
      return const SizedBox();
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Trang chủ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.motorcycle),
            title: const Text('Xe của tôi'),
            onTap: () => context.push('/vehicles'),
          ),
          ListTile(
            leading: const Icon(Icons.miscellaneous_services),
            title: const Text('Đặt lịch dịch vụ'),
            onTap: () => context.push('/booking'),
          ),
        ],
      ),
    );
  }
}
