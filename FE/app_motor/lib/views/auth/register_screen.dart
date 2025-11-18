import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;

  final _auth = AuthService();

  InputDecoration _input(String hint) {
    return InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black),
      ),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Future<void> _register() async {
    if (!_form.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await _auth.register(
        email: _email.text.trim(),
        password: _password.text.trim(),
        name: _name.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Thành công"),
          content: Text("Đăng ký thành công! Hãy đăng nhập."),
        ),
      );

      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Lỗi"),
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/register.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            // Title
            Container(
              padding: const EdgeInsets.only(left: 35, top: 30),
              child: const Text(
                'Create\nAccount',
                style: TextStyle(color: Colors.white, fontSize: 33),
              ),
            ),

            // Form
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.28,
                ),
                child: Form(
                  key: _form,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 35),
                        child: Column(
                          children: [
                            // NAME
                            TextFormField(
                              controller: _name,
                              style: const TextStyle(color: Colors.white),
                              decoration: _input("Name"),
                              validator: (v) =>
                              v!.isEmpty ? "Nhập tên" : null,
                            ),
                            const SizedBox(height: 30),

                            // EMAIL
                            TextFormField(
                              controller: _email,
                              style: const TextStyle(color: Colors.white),
                              decoration: _input("Email (tuỳ chọn)"),
                              validator: (v) {
                                if (v!.isEmpty && _phone.text.isEmpty) {
                                  return "Nhập email hoặc phone";
                                }
                                if (v.isNotEmpty && !v.contains("@")) {
                                  return "Email không hợp lệ";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),

                            // PHONE
                            TextFormField(
                              controller: _phone,
                              style: const TextStyle(color: Colors.white),
                              decoration: _input("Phone (tuỳ chọn)"),
                              validator: (v) {
                                if (v!.isEmpty && _email.text.isEmpty) {
                                  return "Nhập email hoặc phone";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),

                            // PASSWORD
                            TextFormField(
                              controller: _password,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: _input("Password"),
                              validator: (v) =>
                              v!.length < 6 ? "Mật khẩu phải >= 6 ký tự" : null,
                            ),
                            const SizedBox(height: 40),

                            // SIGN UP BUTTON
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 27,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: const Color(0xff4c505b),
                                  child: IconButton(
                                    color: Colors.white,
                                    icon: _loading
                                        ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                        : const Icon(Icons.arrow_forward),
                                    onPressed: _loading ? null : _register,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 40),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () => context.go('/login'),
                                  child: const Text(
                                    'Sign In',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
