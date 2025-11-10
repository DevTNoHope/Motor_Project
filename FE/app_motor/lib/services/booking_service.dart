import '../core/http_client.dart';

class BookingService {
  final _dio = HttpClient.i();

  Future<Map<String, dynamic>> createBooking({
    required int vehicleId,
    required List<int> serviceIds,
    required DateTime start,
    int? mechanicId,
    String? notes,
  }) async {
    final res = await _dio.post('/bookings', data: {
      'vehicleId': vehicleId,
      'serviceIds': serviceIds,
      'start': start.toUtc().toIso8601String(),
      'mechanicId': mechanicId,      // null = thợ bất kỳ
      'notesUser': notes,            // BE sẽ ghi vào notes_user
    });
    return res.data as Map<String, dynamic>;
  }
}
