import '../core/http_client.dart';
import '../models/mechanic_item.dart';

class MechanicService {
  final _dio = HttpClient.i();

  Future<List<MechanicItem>> getMechanics() async {
    final res = await _dio.get('/employees');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map(MechanicItem.fromJson).toList();
  }
}
