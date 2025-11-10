import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'env.dart';

class HttpClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: Env.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));

  static final _storage = const FlutterSecureStorage();

  static Dio i() {
    // attach interceptors once
    if (_dio.interceptors.isEmpty) {
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'accessToken');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            // token hết hạn -> xoá token & báo cho UI (ở đây đơn giản là throw)
            await _storage.delete(key: 'accessToken');
          }
          handler.next(e);
        },
      ));
    }
    return _dio;
  }
}
