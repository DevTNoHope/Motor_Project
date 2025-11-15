import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/booking.dart';
import '../../models/diagnosis.dart';
import '../../services/diagnosis_service.dart';
import '../../utils/formatters.dart';

class BookingDiagnosisScreen extends StatefulWidget {
  final Booking booking; // truyền luôn Booking vào cho tiện hiển thị

  const BookingDiagnosisScreen({
    super.key,
    required this.booking,
  });

  @override
  State<BookingDiagnosisScreen> createState() => _BookingDiagnosisScreenState();
}

class _BookingDiagnosisScreenState extends State<BookingDiagnosisScreen> {
  final _service = DiagnosisService();
  late Future<Diagnosis> _future;

  final _dateFmt = DateFormat('dd/MM/yyyy');
  final _timeFmt = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    _future = _service.getDiagnosisByBooking(widget.booking.id);
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final dateStr = _dateFmt.format(b.startDt.toLocal());
    final startStr = _timeFmt.format(b.startDt.toLocal());
    final endStr = _timeFmt.format(b.endDt.toLocal());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phiếu đánh giá sửa chữa'),
      ),
      body: FutureBuilder<Diagnosis>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            // Nếu backend trả 404 (chưa có phiếu) thì thường là DioError
            final errMsg = snap.error.toString();
            final notFound = errMsg.contains('404') || errMsg.contains('NOT_FOUND');

            if (notFound) {
              return _buildMessage(
                icon: Icons.receipt_long_outlined,
                title: 'Chưa có phiếu đánh giá',
                subtitle:
                'Garage đang lập phiếu đánh giá cho booking #${b.id}. Vui lòng quay lại sau.',
              );
            }

            return _buildMessage(
              icon: Icons.error_outline,
              title: 'Lỗi tải phiếu đánh giá',
              subtitle: snap.error.toString(),
            );
          }

          final diagnosis = snap.data!;
          return _buildContent(b, diagnosis);
        },
      ),
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Booking b, Diagnosis d) {
    final dateStr = _dateFmt.format(b.startDt.toLocal());
    final startStr = _timeFmt.format(b.startDt.toLocal());
    final endStr = _timeFmt.format(b.endDt.toLocal());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thông tin booking
          Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking #${b.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$dateStr  $startStr - $endStr',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    b.servicesLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    b.mechanicId == null
                        ? 'Thợ: Bất kỳ'
                        : 'Thợ ID: ${b.mechanicId}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Nội dung chẩn đoán
          Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nội dung chẩn đoán',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    d.diagnosisNote.isEmpty
                        ? 'Garage chưa ghi chú nội dung chi tiết.'
                        : d.diagnosisNote,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Thời gian dự kiến
          Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thời gian dự kiến',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Tổng thời gian: ${d.etaLabel}',
                      style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('Thời gian công: ${d.laborLabel}',
                      style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Phụ tùng
          Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phụ tùng dự kiến thay',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (d.requiredParts.isEmpty)
                    const Text(
                      'Không có phụ tùng cụ thể.',
                      style: TextStyle(fontSize: 13),
                    )
                  else
                    Column(
                      children: d.requiredParts.map((p) {
                        final part = p.part;
                        final name = part?.name ?? 'Mã phụ tùng #${p.partId}';
                        final unit = part?.unit;
                        final price = part?.price ?? 0;

                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.build_outlined,
                            size: 18,
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(fontSize: 13),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Số lượng: ${p.qty}'
                                    '${unit != null && unit.isNotEmpty ? ' ($unit)' : ''}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              if (price > 0) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Đơn giá tham khảo: ${formatCurrency(price)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            '* Phiếu đánh giá chỉ mang tính ước lượng, chi phí thực tế có thể thay đổi sau khi kiểm tra chi tiết.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
