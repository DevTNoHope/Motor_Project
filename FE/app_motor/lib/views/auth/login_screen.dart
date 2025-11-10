import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'user1@demo.local'); // test nhanh
  final _pass = TextEditingController(text: '123456');

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Form(
        key: _form,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => v!.isEmpty ? 'Nhập email' : null),
            TextFormField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu'), validator: (v) => v!.isEmpty ? 'Nhập mật khẩu' : null),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                if (_form.currentState!.validate()) {
                  await auth.login(_email.text, _pass.text);
                  if (mounted) context.go('/');
                }
              },
              child: const Text('Đăng nhập'),
            )
          ]),
        ),
      ),
    );
  }
}
