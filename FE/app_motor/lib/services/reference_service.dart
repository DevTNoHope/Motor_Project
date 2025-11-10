import '../core/http_client.dart';
import 'package:dio/dio.dart';
import '../models/service.dart';
import '../models/vehicle.dart';

class ReferenceService {
  final _dio = HttpClient.i();

  Future<List<ServiceItem>> listServices({String? type}) async {
    final res = await _dio.get('/services', queryParameters: {
      if (type != null && type.isNotEmpty) 'type': type,
    });
    return (res.data as List).map((e) => ServiceItem.fromJson(e)).toList();
  }

  Future<List<Vehicle>> listVehicles() async {
    final res = await _dio.get('/vehicles/me');
    return (res.data as List).map((e) => Vehicle.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getSlots({
    int? mechanicId,
    required DateTime date,
    required List<int> serviceIds,
  }) async {
    final res = await _dio.get('/slots', queryParameters: {
      'mechanicId': mechanicId, // null = any
      'date': date.toIso8601String().substring(0, 10), // YYYY-MM-DD
      'serviceIds': serviceIds.join(','),              // khớp BE
    });
    return res.data as Map<String, dynamic>;
  }
}
