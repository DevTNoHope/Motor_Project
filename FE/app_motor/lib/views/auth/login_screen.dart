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

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/login.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [

            /// TITLE "Welcome Back"
            Positioned(
              left: 35,
              top: 120,
              child: Text(
                'Welcome\nBack',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            /// FORM
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.45,
                ),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 35),
                        child: Column(
                          children: [

                            /// EMAIL
                            TextFormField(
                              controller: _email,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                hintText: "Email",
                                hintStyle: const TextStyle(color: Colors.black54),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (v) =>
                              v!.isEmpty ? 'Nhập email' : null,
                            ),
                            const SizedBox(height: 30),

                            /// PASSWORD
                            TextFormField(
                              controller: _pass,
                              obscureText: true,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                hintText: "Password",
                                hintStyle: const TextStyle(color: Colors.black54),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (v) =>
                              v!.isEmpty ? 'Nhập mật khẩu' : null,
                            ),
                            const SizedBox(height: 40),

                            /// SIGN IN TEXT + BUTTON
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: const Color(0xff4c505b),
                                  child: IconButton(
                                    color: Colors.white,
                                    icon: const Icon(Icons.arrow_forward),
                                    onPressed: () async {
                                      if (!_form.currentState!.validate()) return;

                                      final role = await auth.login(
                                        _email.text,
                                        _pass.text,
                                      );

                                      if (!mounted) return;

                                      if (role == AppRole.admin) {
                                        await showDialog(
                                          context: context,
                                          builder: (_) => const AlertDialog(
                                            title: Text('Không hỗ trợ'),
                                            content: Text(
                                              'Tài khoản admin chỉ đăng nhập thông qua admin web.',
                                            ),
                                          ),
                                        );
                                        await auth.logout();
                                      } else if (role == AppRole.mechanic) {
                                        context.go('/mechanic');
                                      } else {
                                        context.go('/');
                                      }
                                    },
                                  ),
                                )
                              ],
                            ),

                            const SizedBox(height: 40),

                            /// SIGN UP + FORGOT
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () => context.go('/register'),
                                  child: const Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xff4c505b),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    "Forgot Password",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xff4c505b),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
