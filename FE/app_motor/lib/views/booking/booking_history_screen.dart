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
        return const Color(0xFFFF9800); // Orange
      case 'APPROVED':
        return const Color(0xFF2196F3); // Blue
      case 'IN_DIAGNOSIS':
        return const Color(0xFF9C27B0); // Purple
      case 'IN_PROGRESS':
        return const Color(0xFF2196F3); // Blue
      case 'DONE':
        return const Color(0xFF4CAF50); // Green
      case 'CANCELED':
      case 'CANCELLED':
        return const Color(0xFFFF3B30); // Red
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
      case 'CANCELED':
      case 'CANCELLED':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  bool _canCancel(String status) {
    return status == 'PENDING' || status == 'APPROVED';
  }

  Future<void> _onCancelBooking(Booking b) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hủy lịch hẹn',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bạn có chắc muốn hủy lịch #${b.id}?\n\n'
              'Thời gian: ${_dateFmt.format(b.startDt)} '
              '${_timeFmt.format(b.startDt)} - ${_timeFmt.format(b.endDt)}',
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
            ),
            child: const Text('Không'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF3B30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
          SnackBar(
            content: Text('Đã hủy lịch #${b.id}'),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hủy lịch thất bại: $e'),
            backgroundColor: const Color(0xFFFF3B30),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
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
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Lịch hẹn của tôi',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: Colors.white,
              child: const TabBar(
                indicatorColor: Color(0xFF2196F3),
                indicatorWeight: 3,
                labelColor: Color(0xFF2196F3),
                unselectedLabelColor: Colors.grey,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(text: 'Đang & chờ'),
                  Tab(text: 'Đã xong'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabContent(isHistory: false),
            _buildTabContent(isHistory: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent({required bool isHistory}) {
    return RefreshIndicator(
      color: const Color(0xFF2196F3),
      onRefresh: _reload,
      child: FutureBuilder<List<Booking>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2196F3),
              ),
            );
          }
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final allItems = snapshot.data ?? [];
          final items = allItems.where((b) {
            final s = b.status;
            if (isHistory) {
              return s == 'DONE' || s == 'CANCELED' || s == 'CANCELLED';
            } else {
              return s == 'PENDING' ||
                  s == 'APPROVED' ||
                  s == 'IN_DIAGNOSIS' ||
                  s == 'IN_PROGRESS';
            }
          }).toList();

          if (items.isEmpty) {
            return _buildEmptyState(isHistory);
          }

          items.sort((a, b) => a.startDt.compareTo(b.startDt));

          int? highlightedId;
          if (!isHistory) {
            final now = DateTime.now();
            final upcoming = items
                .where((b) =>
            b.startDt.isAfter(now) || b.startDt.isAtSameMomentAs(now))
                .toList();

            if (upcoming.isNotEmpty) {
              highlightedId = upcoming.first.id;
            } else if (items.isNotEmpty) {
              highlightedId = items.first.id;
            }
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final b = items[index];
              final isHighlighted =
                  !isHistory && highlightedId != null && b.id == highlightedId;
              return _buildBookingCard(b, isHighlighted);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(Booking b, bool isHighlighted) {
    final dateStr = _dateFmt.format(b.startDt);
    final startStr = _timeFmt.format(b.startDt);
    final endStr = _timeFmt.format(b.endDt);

    final statusLabel = _statusLabel(b.status);
    final statusColor = _statusColor(b.status);
    final statusIcon = _statusIcon(b.status);

    final serviceNames = b.servicesLabel;
    final mechanicText =
    b.mechanicId == null ? 'Thợ: Bất kỳ' : 'Thợ ID: ${b.mechanicId}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isHighlighted
            ? Border.all(color: const Color(0xFF2196F3), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isHighlighted ? 0.1 : 0.06),
            blurRadius: isHighlighted ? 20 : 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.push('/booking-history/${b.id}');
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER: Highlighted badge + Status
                Row(
                  children: [
                    if (isHighlighted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Color(0xFF2196F3),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Lịch gần nhất',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2196F3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // DATE & TIME
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$startStr - $endStr',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // SERVICES
                _buildInfoRow(
                  Icons.miscellaneous_services_outlined,
                  'Dịch vụ',
                  serviceNames,
                ),
                const SizedBox(height: 8),

                // MECHANIC
                _buildInfoRow(
                  Icons.person_outline,
                  'Thợ',
                  b.mechanicId == null ? 'Bất kỳ' : 'ID: ${b.mechanicId}',
                ),

                // NOTES
                if (b.notesUser != null && b.notesUser!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.note_outlined,
                    'Ghi chú',
                    b.notesUser!,
                  ),
                ],

                // TOTAL AMOUNT
                if (b.totalAmount != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.payments_outlined,
                          size: 20,
                          color: Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Tổng tiền:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          formatCurrency(b.totalAmount),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ACTIONS
                if (_canCancel(b.status) || b.hasRepair) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (b.hasRepair) ...[
                        OutlinedButton.icon(
                          onPressed: () {
                            context.push('/booking-diagnosis', extra: b);
                          },
                          icon: const Icon(
                            Icons.receipt_long_outlined,
                            size: 18,
                          ),
                          label: const Text('Phiếu đánh giá'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2196F3),
                            side: const BorderSide(
                              color: Color(0xFF2196F3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (_canCancel(b.status)) ...[
                        ElevatedButton.icon(
                          onPressed: _isCancelling && _cancellingId == b.id
                              ? null
                              : () => _onCancelBooking(b),
                          icon: _isCancelling && _cancellingId == b.id
                              ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Icon(Icons.cancel_outlined, size: 18),
                          label: const Text('Hủy lịch'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF3B30),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isHistory) {
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
                color: const Color(0xFF2196F3).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isHistory ? Icons.history : Icons.event_busy_outlined,
                size: 64,
                color: const Color(0xFF2196F3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isHistory ? 'Chưa có lịch sử' : 'Chưa có lịch hẹn',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isHistory
                  ? 'Lịch hẹn đã hoàn thành hoặc đã hủy\nsẽ được hiển thị tại đây'
                  : 'Bạn chưa có lịch hẹn nào đang\nhoặc chờ thực hiện',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
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
              'Có lỗi xảy ra',
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
              onPressed: _reload,
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
}