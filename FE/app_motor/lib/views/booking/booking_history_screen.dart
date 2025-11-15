import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../models/booking.dart';
import '../../services/booking_service.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  final _service = BookingService();
  late Future<List<Booking>> _future;
  final _dateFmt = DateFormat('dd/MM/yyyy');
  final _timeFmt = DateFormat('HH:mm');

  String _statusFilter = 'ALL'; // ALL / PENDING / APPROVED / IN_PROGRESS / DONE / CANCELLED
  bool _isCancelling = false;
  int? _cancellingId;

  @override
  void initState() {
    super.initState();
    _future = _service.getMyBookings();
  }

  Future<void> _reload() async {
    setState(() {
      _future = _service.getMyBookings();
    });
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
      case 'CANCELED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool _canCancel(String status) {
    return status == 'PENDING' || status == 'APPROVED';
  }

  Future<void> _onCancelBooking(Booking b) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy lịch hẹn'),
        content: Text(
          'Bạn có chắc muốn hủy lịch #${b.id}?\n'
              'Thời gian: ${_dateFmt.format(b.startDt.toLocal())} '
              '${_timeFmt.format(b.startDt.toLocal())} - ${_timeFmt.format(b.endDt.toLocal())}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Không'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hủy lịch'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      setState(() {
        _isCancelling = true;
        _cancellingId = b.id;
      });
      await _service.cancelBooking(b.id);
      await _reload();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã hủy lịch #${b.id}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hủy lịch thất bại: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
          _cancellingId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử đặt lịch'),
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<Booking>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  Center(
                    child: Text(
                      'Lỗi tải lịch sử: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }
            final allItems = snapshot.data ?? [];

            // áp filter
            final items = _statusFilter == 'ALL'
                ? allItems
                : allItems.where((b) => b.status == _statusFilter).toList();

            return Column(
              children: [
                // Filter trạng thái
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('ALL', 'Tất cả'),
                        _buildFilterChip('PENDING', 'Chờ duyệt'),
                        _buildFilterChip('APPROVED', 'Đã duyệt'),
                        _buildFilterChip('IN_PROGRESS', 'Đang sửa'),
                        _buildFilterChip('DONE', 'Hoàn thành'),
                        _buildFilterChip('CANCELED', 'Đã hủy'),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: items.isEmpty
                      ? ListView(
                    children: const [
                      SizedBox(height: 80),
                      Center(
                          child:
                          Text('Không có lịch hẹn nào với bộ lọc này')),
                    ],
                  )
                      : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final b = items[index];
                      final dateStr =
                      _dateFmt.format(b.startDt.toLocal());
                      final startStr =
                      _timeFmt.format(b.startDt.toLocal());
                      final endStr =
                      _timeFmt.format(b.endDt.toLocal());

                      final statusLabel = _statusLabel(b.status);
                      final statusColor = _statusColor(b.status);

                      final serviceNames = b.servicesLabel;
                      final mechanicText = b.mechanicId == null
                          ? 'Thợ: Bất kỳ'
                          : 'Thợ ID: ${b.mechanicId}';

                      final isCancellingThis = _isCancelling &&
                          _cancellingId == b.id &&
                          _canCancel(b.status);

                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            // sang màn chi tiết
                            context.push(
                                '/booking-history/${b.id.toString()}');
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                // dòng trên: ngày + status chip
                                Row(
                                  children: [
                                    Text(
                                      '$dateStr  $startStr - $endStr',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                        statusColor.withOpacity(0.1),
                                        borderRadius:
                                        BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        statusLabel,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: statusColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  serviceNames,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  mechanicText,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                if (b.notesUser?.isNotEmpty == true) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ghi chú: ${b.notesUser}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                                if (b.totalAmount != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tổng tiền: ${b.totalAmount} đ',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                                // nút Hủy lịch
                                if (_canCancel(b.status)|| b.hasRepair) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.end,
                                    children: [
                                      // Nút xem phiếu đánh giá (nếu có dịch vụ REPAIR)
                                      if (b.hasRepair) ...[
                                        TextButton.icon(
                                          onPressed: () {
                                            context.push(
                                              '/booking-diagnosis',
                                              extra: b, // truyền cả Booking sang màn phiếu đánh giá
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.receipt_long_outlined,
                                            size: 18,
                                          ),
                                          label: const Text('Phiếu đánh giá'),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      // Nút hủy lịch
                                      if (_canCancel(b.status))
                                        TextButton.icon(
                                          onPressed: isCancellingThis
                                              ? null
                                              : () =>
                                              _onCancelBooking(b),
                                          icon: isCancellingThis
                                              ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child:
                                            CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                              : const Icon(
                                            Icons.cancel_outlined,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          label: Text(
                                            isCancellingThis
                                                ? 'Đang hủy...'
                                                : 'Hủy lịch',
                                            style: const TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final selected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() {
            _statusFilter = value;
          });
        },
      ),
    );
  }
}
