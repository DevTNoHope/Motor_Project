import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../core/http_client.dart';

class MechanicBookingService {
  final _dio = HttpClient.i();

  /// Lấy danh sách booking của thợ theo ngày (mặc định hôm nay)
  Future<List<dynamic>> getBookingsByDate(DateTime date) async {
    final dateStr = date.toIso8601String().substring(0, 10); // yyyy-MM-dd
    try {
      final res = await _dio.get('/mechanic/bookings', queryParameters: {
        'date': dateStr,
      });

      // Nếu backend trả mảng rỗng -> không có lịch
      if (res.data is List) return res.data as List;
      return [];
    } on DioException catch (e) {
      // 🔹 Nếu bị 401 (chưa login hoặc token hết hạn)
      if (e.response?.statusCode == 401) {
        return []; // coi như không có lịch
      }

      // 🔹 Nếu backend lỗi 404 hoặc bất kỳ lỗi nào khác
      if (e.response?.statusCode == 404) {
        return [];
      }

      rethrow; // giữ nguyên cho debug nếu là lỗi khác
    }
  }
  Future<void> startBooking(int id) async {
    await _dio.patch('/mechanic/bookings/$id/start');
  }

  Future<void> completeBooking(int id) async {
    await _dio.patch('/mechanic/bookings/$id/complete');
  }
  Future<void> submitDiagnosis(
      int bookingId, {
        required String diagnosisNote,
        int? laborEstMin,
        int? etaMin,
        List<Map<String, dynamic>>? requiredParts,
      }) async {
    try {
      await _dio.patch(
        '/mechanic/bookings/$bookingId/diagnose',
        data: {
          'diagnosisNote': diagnosisNote,
          'laborEstMin': laborEstMin,
          'etaMin': etaMin,
          'requiredParts': requiredParts ?? [],
        },
      );
    } on DioException catch (e) {
      debugPrint('Lỗi khi gửi phiếu đánh giá: ${e.response?.data}');
      rethrow;
    }
  }
  /// ✅ Lấy danh sách tất cả phụ tùng có sẵn từ API
  Future<List<dynamic>> getAllParts() async {
    try {
      final res = await _dio.get('/mechanic/parts'); // ✅ dùng endpoint mới
      if (res.data is List) return res.data;
      return [];
    } catch (e) {
      debugPrint('Lỗi khi tải danh sách phụ tùng: $e');
      return [];
    }
  }




}
