import 'package:dio/dio.dart';
import '../core/http_client.dart';
import '../models/vehicle.dart';

class VehicleService {
  final _dio = HttpClient.i();

  // GET /api/v1/me/vehicles
  Future<List<Vehicle>> listMine() async {
    final res = await _dio.get('/me/vehicles');
    final data = (res.data as List).cast<Map<String, dynamic>>();
    return data.map(Vehicle.fromJson).toList();
  }

  // POST /api/v1/me/vehicles
  Future<Vehicle> create(Vehicle v) async {
    final res = await _dio.post('/me/vehicles', data: v.toCreatePayload());
    return Vehicle.fromJson(res.data as Map<String, dynamic>);
  }

  // PATCH /api/v1/me/vehicles/:id
  Future<Vehicle> update(int id, Vehicle v) async {
    final res = await _dio.patch('/me/vehicles/$id', data: v.toUpdatePayload());
    return Vehicle.fromJson(res.data as Map<String, dynamic>);
  }

  // DELETE /api/v1/me/vehicles/:id
  Future<void> remove(int id) async {
    await _dio.delete('/me/vehicles/$id');
  }
}
