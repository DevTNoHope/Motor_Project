import '../core/http_client.dart';

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
}
