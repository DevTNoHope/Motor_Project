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
        return const Color(0xFFFF9800);
      case 'APPROVED':
        return const Color(0xFF2196F3);
      case 'IN_DIAGNOSIS':
        return const Color(0xFF9C27B0);
      case 'IN_PROGRESS':
        return const Color(0xFF2196F3);
      case 'DONE':
        return const Color(0xFF4CAF50);
      case 'CANCELLED':
        return const Color(0xFFFF3B30);
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'PENDING':
        return Icons.schedule_outlined;
      case 'APPROVED':
        return Icons.check_circle_outline;
      case 'IN_DIAGNOSIS':
        return Icons.search;
      case 'IN_PROGRESS':
        return Icons.build_outlined;
      case 'DONE':
        return Icons.done_all;
      case 'CANCELLED':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Chi tiết lịch #${widget.bookingId}',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: FutureBuilder<Booking>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2196F3),
              ),
            );
          }
          if (snap.hasError) {
            return _buildErrorState(snap.error.toString());
          }
          final b = snap.data!;
          return _buildContent(b);
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B30).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFFFF3B30),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Lỗi tải chi tiết',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _future = _service.getBookingDetail(widget.bookingId);
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Booking b) {
    final startLocal = b.startDt;
    final endLocal = b.endDt;
    final dateStr = _dateFmt.format(startLocal);
    final timeRange = '${_timeFmt.format(startLocal)} - ${_timeFmt.format(endLocal)}';
    final statusLabel = _statusLabel(b.status);
    final statusColor = _statusColor(b.status);
    final statusIcon = _statusIcon(b.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER CARD - Gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2196F3).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.event_note,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lịch hẹn #${b.id}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  statusIcon,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  statusLabel,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildHeaderInfoRow(
                  Icons.calendar_today_outlined,
                  dateStr,
                ),
                const SizedBox(height: 8),
                _buildHeaderInfoRow(
                  Icons.access_time,
                  timeRange,
                ),
                const SizedBox(height: 8),
                _buildHeaderInfoRow(
                  Icons.motorcycle_outlined,
                  'Xe ID: ${b.vehicleId}',
                ),
                const SizedBox(height: 8),
                _buildHeaderInfoRow(
                  Icons.person_outline,
                  b.mechanicId == null ? 'Thợ: Bất kỳ' : 'Thợ ID: ${b.mechanicId}',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // SECTION: Dịch vụ
          _buildSectionTitle('Dịch vụ trong lịch hẹn', Icons.miscellaneous_services_outlined),
          const SizedBox(height: 12),
          _buildServicesSection(b.services),

          const SizedBox(height: 24),

          // SECTION: Phụ tùng (nếu có)
          if (b.parts.isNotEmpty) ...[
            _buildSectionTitle('Chi tiết phụ tùng', Icons.build_circle_outlined),
            const SizedBox(height: 12),
            _buildPartsSection(b.parts),
            const SizedBox(height: 24),
          ],

          // SECTION: Thanh toán
          _buildSectionTitle('Thanh toán', Icons.payments_outlined),
          const SizedBox(height: 12),
          _buildPaymentSection(b),

          const SizedBox(height: 24),

          // SECTION: Ghi chú
          if (b.notesUser?.isNotEmpty == true || b.notesMechanic?.isNotEmpty == true) ...[
            _buildSectionTitle('Ghi chú', Icons.note_outlined),
            const SizedBox(height: 12),
            if (b.notesUser?.isNotEmpty == true)
              _buildNoteCard(
                'Ghi chú của bạn',
                b.notesUser!,
                Icons.person_outline,
                const Color(0xFF2196F3),
              ),
            if (b.notesMechanic?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              _buildNoteCard(
                'Ghi chú của thợ',
                b.notesMechanic!,
                Icons.engineering_outlined,
                const Color(0xFF4CAF50),
              ),
            ],
            const SizedBox(height: 24),
          ],

          // Thông tin tạo lịch
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tạo lúc: ${_dateFmt.format(b.createdAt)} ${_timeFmt.format(b.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeaderInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.white.withOpacity(0.9),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF2196F3),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection(List<dynamic> services) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: services.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          final s = services[index];
          final name = s.service?.name ?? 'Dịch vụ #${s.serviceId}';
          final type = s.service?.type;
          final isRepair = type == 'REPAIR';
          final price = s.priceSnapshot;
          final duration = s.durationSnapshotMin;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isRepair ? const Color(0xFF2196F3) : const Color(0xFF4CAF50))
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isRepair ? Icons.build : Icons.miscellaneous_services,
                    color: isRepair ? const Color(0xFF2196F3) : const Color(0xFF4CAF50),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (type != null)
                        _buildServiceInfo(
                          Icons.category_outlined,
                          type == 'REPAIR' ? 'Sửa chữa' : 'Dịch vụ nhanh',
                        ),
                      if (price != null) ...[
                        const SizedBox(height: 4),
                        _buildServiceInfo(
                          Icons.attach_money,
                          formatCurrency(price),
                        ),
                      ],
                      if (duration != null) ...[
                        const SizedBox(height: 4),
                        _buildServiceInfo(
                          Icons.timer_outlined,
                          '$duration phút',
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'x${s.qty}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildPartsSection(List<dynamic> parts) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: parts.asMap().entries.map((entry) {
          final index = entry.key;
          final bp = entry.value;
          final name = bp.part?.name ?? 'Mã phụ tùng #${bp.partId}';
          final unit = bp.part?.unit;
          final price = bp.priceSnapshot;
          final total = bp.lineTotal;

          return Container(
            margin: EdgeInsets.only(top: index > 0 ? 12 : 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.build_outlined,
                    size: 20,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildServiceInfo(
                        Icons.inventory_2_outlined,
                        'SL: ${bp.qty}${unit != null && unit.isNotEmpty ? " ($unit)" : ""}',
                      ),
                      const SizedBox(height: 4),
                      _buildServiceInfo(
                        Icons.attach_money,
                        'Đơn giá: ${formatCurrency(price)}',
                      ),
                      const SizedBox(height: 4),
                      _buildServiceInfo(
                        Icons.calculate_outlined,
                        'Thành tiền: ${formatCurrency(total)}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentSection(Booking b) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAmountRow(
            'Tiền công dịch vụ',
            b.totalServiceAmount,
            Icons.miscellaneous_services_outlined,
          ),
          const SizedBox(height: 12),
          _buildAmountRow(
            'Tiền phụ tùng',
            b.totalPartsAmount,
            Icons.build_outlined,
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 12),
          _buildAmountRow(
            'Tổng cộng',
            b.totalAmount,
            Icons.payments_outlined,
            isBold: true,
            isTotal: true,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (b.totalAmount != null
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFFF9800))
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  b.totalAmount != null ? Icons.check_circle_outline : Icons.info_outline,
                  size: 16,
                  color: b.totalAmount != null
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF9800),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    b.totalAmount == null
                        ? 'Chưa có hóa đơn (chờ thợ sửa xong & cập nhật)'
                        : (b.stockDeducted ? 'Đã trừ kho phụ tùng' : 'Chưa trừ kho'),
                    style: TextStyle(
                      fontSize: 12,
                      color: b.totalAmount != null
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF9800),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
      String label,
      num? value,
      IconData icon, {
        bool isBold = false,
        bool isTotal = false,
      }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isTotal ? const Color(0xFF2196F3) : Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? const Color(0xFF2196F3) : Colors.black87,
          ),
        ),
        const Spacer(),
        Text(
          value != null ? formatCurrency(value) : '-',
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? const Color(0xFF2196F3) : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildNoteCard(String title, String content, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}