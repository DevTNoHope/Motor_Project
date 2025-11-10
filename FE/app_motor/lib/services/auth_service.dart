import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../core/http_client.dart';
import '../models/role.dart';

class AuthService {
  final _dio = HttpClient.i();
  final _storage = const FlutterSecureStorage();

  Future<void> register({
    required String email, required String password, required String name, String? phone,
  }) async {
    await _dio.post('/auth/register', data: {
      'email': email, 'password': password, 'name': name, 'phone': phone,
    });
  }

  Future<AppRole> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    final token = res.data['accessToken'] as String;
    await _storage.write(key: 'accessToken', value: token);

    final payload = JwtDecoder.decode(token);
    return parseRole(payload['roleCode'] as String?);
  }

  Future<void> logout() async {
    await _storage.delete(key: 'accessToken');
  }

  Future<bool> hasToken() async => (await _storage.read(key: 'accessToken'))?.isNotEmpty == true;

  Future<AppRole> currentRole() async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null || token.isEmpty) return AppRole.unknown;
    return parseRole(JwtDecoder.decode(token)['roleCode'] as String?);
  }
}
