import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/http_client.dart';

class MeService {
  final _dio = HttpClient.i();
  final _storage = const FlutterSecureStorage();

  /// Gọi API /api/v1/me để lấy thông tin account + profile
  Future<Map<String, dynamic>> getProfile() async {
    final token = await _storage.read(key: 'accessToken');
    final res = await _dio.get(
      '/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return res.data;
  }
  /// Cập nhật hồ sơ
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> payload) async {
    final token = await _storage.read(key: 'accessToken');
    final res = await _dio.patch(
      '/me',
      data: payload,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return res.data;
  }
}
