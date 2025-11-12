import 'package:dio/dio.dart';
import '../core/http_client.dart';
import 'dart:io';
class ProfileService {
  final _dio = HttpClient.i();

  Future<Map<String, dynamic>> getMe() async {
    final res = await _dio.get('/me');
    return res.data as Map<String, dynamic>;
  }

  /// patch các field tùy có trong payload (email, phone, name, gender, birth_year,
  /// avatar_url, address, note ...)
  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> payload) async {
    final res = await _dio.patch('/me', data: payload);
    return res.data as Map<String, dynamic>;
  }

  Future<String> uploadAvatar(File file) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
    });
    final res = await _dio.post('/upload/avatar', data: form);
    return (res.data as Map<String, dynamic>)['url'] as String;
  }
}
