import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../models/booking.dart';
import '../../services/booking_service.dart';
import '../../utils/formatters.dart';

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
      case 'CANCELED':
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
      case 'CANCELLED':
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
              'Thời gian: ${_dateFmt.format(b.startDt)} '
              '${_timeFmt.format(b.startDt)} - ${_timeFmt.format(b.endDt)}',
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lịch hẹn của tôi'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Đang & chờ'),
              Tab(text: 'Đã xong'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Đang & chờ thực hiện
            _buildTabContent(isHistory: false),
            // Tab 2: Lịch sử (đã hoàn thành / đã hủy)
            _buildTabContent(isHistory: true),
          ],
        ),
      ),
    );
  }

  /// Nội dung mỗi tab – dùng chung UI, chỉ khác cách lọc status
  Widget _buildTabContent({required bool isHistory}) {
    return RefreshIndicator(
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
                    'Lỗi tải lịch hẹn: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          }

          final allItems = snapshot.data ?? [];

          // Lọc theo tab
          final items = allItems.where((b) {
            final s = b.status;
            if (isHistory) {
              // Lịch sử: đã hoàn thành / đã hủy
              return s == 'DONE' || s == 'CANCELED' || s == 'CANCELLED';
            } else {
              // Đang & chờ thực hiện
              return s == 'PENDING' ||
                  s == 'APPROVED' ||
                  s == 'IN_DIAGNOSIS' ||
                  s == 'IN_PROGRESS';
            }
          }).toList();

          if (items.isEmpty) {
            return ListView(
              children: [
                const SizedBox(height: 80),
                Center(
                  child: Text(
                    isHistory
                        ? 'Chưa có lịch hẹn đã hoàn thành hoặc đã hủy.'
                        : 'Hiện không có lịch hẹn đang hoặc chờ thực hiện.',
                  ),
                ),
              ],
            );
          }

          // Sắp xếp theo thời gian bắt đầu
          items.sort((a, b) => a.startDt.compareTo(b.startDt));

          // Xác định booking "gần nhất" cho tab Đang & chờ
          int? highlightedId;
          if (!isHistory) {
            final now = DateTime.now();
            final upcoming = items
                .where((b) =>
            b.startDt.isAfter(now) ||
                b.startDt.isAtSameMomentAs(now))
                .toList();

            if (upcoming.isNotEmpty) {
              highlightedId = upcoming.first.id;
            } else {
              // nếu tất cả đều ở quá khứ thì lấy booking đầu tiên
              highlightedId = items.first.id;
            }
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final b = items[index];
              final theme = Theme.of(context);

              final dateStr = _dateFmt.format(b.startDt);
              final startStr = _timeFmt.format(b.startDt);
              final endStr = _timeFmt.format(b.endDt);

              final statusLabel = _statusLabel(b.status);
              final statusColor = _statusColor(b.status);

              final serviceNames = b.servicesLabel;
              final mechanicText = b.mechanicId == null
                  ? 'Thợ: Bất kỳ'
                  : 'Thợ ID: ${b.mechanicId}';

              final bool isHighlighted =
                  !isHistory && highlightedId != null && b.id == highlightedId;

              return Card(
                elevation: isHighlighted ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isHighlighted
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    width: isHighlighted ? 2 : 0.5,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    // sang màn chi tiết
                    context.push('/booking-history/${b.id}');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isHighlighted) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color:
                              theme.colorScheme.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Lịch gần nhất',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
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
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dịch vụ: $serviceNames',
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mechanicText,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        if (b.notesUser != null &&
                            b.notesUser!.trim().isNotEmpty) ...[
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
                            'Tổng tiền: ${formatCurrency(b.totalAmount)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        // nút Hủy lịch + Phiếu đánh giá
                        // - Hủy lịch: chỉ hiển thị với các booking còn có thể hủy
                        // - Phiếu đánh giá: hiển thị với mọi booking có REPAIR
                        if (_canCancel(b.status) || b.hasRepair) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (b.hasRepair) ...[
                                TextButton.icon(
                                  onPressed: () {
                                    context
                                        .push('/booking-diagnosis',extra: b);
                                  },
                                  icon: const Icon(Icons.receipt_long),
                                  label: const Text('Phiếu đánh giá'),
                                ),
                                const SizedBox(width: 8),
                              ],
                              if (_canCancel(b.status)) ...[
                                FilledButton.icon(
                                  onPressed: _isCancelling &&
                                      _cancellingId == b.id
                                      ? null
                                      : () => _onCancelBooking(b),
                                  icon: _isCancelling &&
                                      _cancellingId == b.id
                                      ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                      : const Icon(Icons.cancel_outlined),
                                  label: const Text('Hủy lịch'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
