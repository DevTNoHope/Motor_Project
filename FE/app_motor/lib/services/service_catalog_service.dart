import '../core/http_client.dart';
import '../models/service_item.dart';

class ServiceCatalogService {
  final _dio = HttpClient.i();

  Future<List<ServiceItem>> getServices() async {
    final res = await _dio.get('/services');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map(ServiceItem.fromJson).toList();
  }
}
