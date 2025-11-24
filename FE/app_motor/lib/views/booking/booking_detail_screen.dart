import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/booking.dart';
import '../../services/booking_service.dart';
import '../../utils/formatters.dart';

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;

  const BookingDetailScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final _service = BookingService();
  late Future<Booking> _future;
  final _dateFmt = DateFormat('dd/MM/yyyy');
  final _timeFmt = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    _future = _service.getBookingDetail(widget.bookingId);
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'PENDING':
        return 'Chờ duyệt';
      case 'APPROVED':
        return 'Đã duyệt';
      case 'IN_DIAGNOSIS':
        return 'Đang chẩn đoán';
      case 'IN_PROGRESS':
        return 'Đang sửa';
      case 'DONE':
        return 'Hoàn thành';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
      case 'IN_DIAGNOSIS':
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'DONE':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết lịch #${widget.bookingId}'),
      ),
      body: FutureBuilder<Booking>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Lỗi tải chi tiết: ${snap.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final b = snap.data!;
          final startLocal = b.startDt;
          final endLocal = b.endDt;

          final dateStr = _dateFmt.format(startLocal);
          final timeRange =
              '${_timeFmt.format(startLocal)} - ${_timeFmt.format(endLocal)}';

          final statusLabel = _statusLabel(b.status);
          final statusColor = _statusColor(b.status);

          final serviceItems = b.services;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thông tin chung
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Lịch hẹn #${b.id}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.event, size: 18),
                            const SizedBox(width: 6),
                            Text('$dateStr  $timeRange'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.two_wheeler, size: 18),
                            const SizedBox(width: 6),
                            Text('Xe ID: ${b.vehicleId}'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.engineering, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              b.mechanicId == null
                                  ? 'Thợ: Bất kỳ'
                                  : 'Thợ ID: ${b.mechanicId}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Tạo lúc: ${_dateFmt.format(b.createdAt)} ${_timeFmt.format(b.createdAt)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        if (b.notesUser?.isNotEmpty == true) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Ghi chú của bạn',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(b.notesUser!),
                        ],
                        if (b.notesMechanic?.isNotEmpty == true) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Ghi chú của thợ',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(b.notesMechanic!),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Danh sách dịch vụ
                const Text(
                  'Dịch vụ trong lịch hẹn',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...serviceItems.map((s) {
                  final name = s.service?.name ?? 'Dịch vụ #${s.serviceId}';
                  final type = s.service?.type;
                  final isRepair = type == 'REPAIR';
                  final price = s.priceSnapshot;
                  final duration = s.durationSnapshotMin;

                  return Card(
                    child: ListTile(
                      leading: Icon(
                        isRepair ? Icons.build : Icons.miscellaneous_services,
                      ),
                      title: Text(name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (type != null)
                            Text(
                              type == 'REPAIR'
                                  ? 'Loại: Sửa chữa'
                                  : 'Loại: Dịch vụ nhanh',
                              style: const TextStyle(fontSize: 12),
                            ),
                          if (price != null)
                            Text(
                              'Đơn giá: ${formatCurrency(price)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          if (duration != null)
                            Text(
                              'Thời lượng dự kiến: $duration phút',
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                      trailing: Text('x${s.qty}'),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Tổng tiền
                const Text(
                  'Thanh toán',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (b.parts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Chi tiết phụ tùng',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: b.parts.map((bp) {
                          final name = bp.part?.name ?? 'Mã phụ tùng #${bp.partId}';
                          final unit = bp.part?.unit;
                          final price = bp.priceSnapshot;
                          final total = bp.lineTotal;

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            leading: const Icon(Icons.build_outlined, size: 18),
                            title: Text(name, style: const TextStyle(fontSize: 13)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Số lượng: ${bp.qty}'
                                      '${unit != null && unit.isNotEmpty ? " ($unit)" : ""}',
                                  style:
                                  const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  'Đơn giá: ${formatCurrency(price)}',
                                  style:
                                  const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  'Thành tiền: ${formatCurrency(total)}',
                                  style:
                                  const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAmountRow(
                          'Tiền công dịch vụ',
                          b.totalServiceAmount,
                        ),
                        _buildAmountRow(
                          'Tiền phụ tùng',
                          b.totalPartsAmount,
                        ),
                        const Divider(),
                        _buildAmountRow(
                          'Tổng cộng',
                          b.totalAmount,
                          isBold: true,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          b.totalAmount == null
                              ? 'Chưa có hoá đơn (chờ thợ sửa xong & cập nhật)'
                              : (b.stockDeducted
                              ? 'Đã trừ kho phụ tùng'
                              : 'Chưa trừ kho'),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),

                // Sau này nếu muốn thêm nút hủy / đánh giá… thì thêm phía dưới
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAmountRow(String label, num? value, {bool isBold = false}) {
    final textStyle = TextStyle(
      fontSize: 13,
      fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: textStyle),
          const Spacer(),
          Text(
            value != null ? formatCurrency(value) : '-',
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
