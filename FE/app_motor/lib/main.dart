import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/app_router.dart';
import 'controllers/auth_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthController()..init())],
      child: MaterialApp.router(
        title: 'Sửa Xe - Khách hàng',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      ),
    );
  }
}
