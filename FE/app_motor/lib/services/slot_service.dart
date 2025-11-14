import '../core/http_client.dart';
import '../models/slot_item.dart';
import 'package:intl/intl.dart';

class SlotService {
  final _dio = HttpClient.i();

  Future<List<SlotItem>> getSlots({
    required DateTime date,
    int? mechanicId,
    required List<int> serviceIds,
  }) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    final res = await _dio.get('/slots', queryParameters: {
      'date': dateStr,
      'mechanicId': mechanicId?.toString(),
      'serviceIds': serviceIds.join(','),
    });

    final data = res.data as Map<String, dynamic>;
    final raw = data['slots'];
    if (raw == null || raw is! List) {
      return []; // không có slot thì trả list rỗng, không crash
    }
    final slots = raw.cast<Map<String, dynamic>>();
    return slots.map(SlotItem.fromJson).toList();
  }
}
