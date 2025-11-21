import 'package:dio/dio.dart';
import '../core/http_client.dart';
import '../models/notification_item.dart';

class NotificationService {
  final Dio _dio = HttpClient.i();

  Future<List<NotificationItem>> getMyNotifications({
    int limit = 50,
    int offset = 0,
  }) async {
    final res = await _dio.get(
      '/notifications/me',
      queryParameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    final data = res.data as List;
    return data
        .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsRead(int id) async {
    await _dio.patch('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _dio.post('/notifications/mark-all-read');
  }
}
