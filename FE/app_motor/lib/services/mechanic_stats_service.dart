import 'package:dio/dio.dart';
import '../core/http_client.dart';

class MechanicStatsService {
  final _dio = HttpClient.i();

  /// Lấy thống kê tổng hợp của thợ
  Future<Map<String, dynamic>> getStats({
    required DateTime from,
    required DateTime to,
    String groupBy = 'month',
  }) async {
    final res = await _dio.get(
      '/mechanic/stats',
      queryParameters: {
        'from': from.toIso8601String().substring(0, 10),
        'to': to.toIso8601String().substring(0, 10),
        'groupBy': groupBy,
      },
    );
    return res.data as Map<String, dynamic>;
  }
}
