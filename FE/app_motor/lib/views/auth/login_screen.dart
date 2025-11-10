import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/auth_controller.dart';
import '../../models/role.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'user1@demo.local');
  final _pass  = TextEditingController(text: '123456');

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email'), validator: (v)=> v!.isEmpty?'Nhập email':null),
              TextFormField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu'), validator: (v)=> v!.isEmpty?'Nhập mật khẩu':null),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  if (!_form.currentState!.validate()) return;
                  final role = await auth.login(_email.text, _pass.text);
                  if (!mounted) return;

                  if (role == AppRole.admin) {
                    await showDialog(context: context, builder: (_) => const AlertDialog(
                      title: Text('Không hỗ trợ'),
                      content: Text('Tài khoản admin chỉ đăng nhập thông qua admin web.'),
                    ));
                    await auth.logout();
                  } else if (role == AppRole.mechanic) {
                    context.go('/mechanic');
                  } else {
                    context.go('/');
                  }
                },
                child: const Text('Đăng nhập'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
