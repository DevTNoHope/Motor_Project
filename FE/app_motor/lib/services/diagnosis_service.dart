import '../core/http_client.dart';
import '../models/diagnosis.dart';

class DiagnosisService {
  final _dio = HttpClient.i();

  Future<Diagnosis> getDiagnosisByBooking(int bookingId) async {
    final res = await _dio.get('/diagnosis/by-booking/$bookingId');
    return Diagnosis.fromJson(res.data as Map<String, dynamic>);
  }
}
