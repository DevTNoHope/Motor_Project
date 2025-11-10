import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/http_client.dart';

class AuthService {
  final _dio = HttpClient.i();
  final _storage = const FlutterSecureStorage();

  Future<void> register({required String email, required String password, required String name, String? phone}) async {
    await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
    });
  }

  Future<void> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    final token = res.data['accessToken'] as String;
    await _storage.write(key: 'accessToken', value: token);
  }

  Future<void> logout() async {
    await _storage.delete(key: 'accessToken');
  }

  Future<bool> hasToken() async => (await _storage.read(key: 'accessToken'))?.isNotEmpty == true;
}
