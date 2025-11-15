import '../core/http_client.dart';
import '../models/booking.dart';
class BookingService {
  final _dio = HttpClient.i();

  Future<Map<String, dynamic>> createBooking({
    required int vehicleId,
    required List<int> serviceIds,
    int? mechanicId,      // null = thợ bất kỳ
    required DateTime startUtc,
    String? notesUser,
  }) async {
    final body = <String, dynamic>{
      'vehicleId': vehicleId,
      'serviceIds': serviceIds,
      'start': startUtc.toIso8601String(),
      'notesUser': notesUser,
    };
    if (mechanicId != null) body['mechanicId'] = mechanicId;

    final res = await _dio.post('/bookings', data: body);
    return res.data as Map<String, dynamic>;
  }
  /// Lấy danh sách lịch hẹn của chính user
  Future<List<Booking>> getMyBookings() async {
    final res = await _dio.get('/bookings/me');
    final data = res.data as List;
    return data.map((e) => Booking.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Lấy chi tiết một booking theo id (nếu sau này cần)
  Future<Booking> getBookingDetail(int id) async {
    final res = await _dio.get('/bookings/$id');
    return Booking.fromJson(res.data as Map<String, dynamic>);
  }
  Future<void> cancelBooking(int id) async {
    await _dio.patch('/bookings/$id/cancel');
  }
}
