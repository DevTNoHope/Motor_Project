import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/notification_controller.dart';
import '../../models/notification_item.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  IconData _iconForType(String type) {
    switch (type) {
      case 'BOOKING_CREATED':
        return Icons.add_circle_outline;
      case 'BOOKING_CANCELLED':
        return Icons.cancel_outlined;
      case 'BOOKING_APPROVED':
        return Icons.check_circle_outline;
      case 'BOOKING_REJECTED':
        return Icons.highlight_off_outlined;
      case 'BOOKING_IN_DIAGNOSIS':
        return Icons.search;
      case 'BOOKING_STARTED':
        return Icons.build_circle_outlined;
      case 'BOOKING_DONE':
        return Icons.done_all;
      case 'REVIEW_CREATED':
        return Icons.receipt_long;
      default:
        return Icons.notifications;
    }
  }

  Color _colorForType(String type, bool isRead) {
    if (isRead) return Colors.grey.shade400;

    switch (type) {
      case 'BOOKING_CREATED':
        return const Color(0xFF2196F3);
      case 'BOOKING_CANCELLED':
      case 'BOOKING_REJECTED':
        return const Color(0xFFFF3B30);
      case 'BOOKING_APPROVED':
      case 'BOOKING_DONE':
        return const Color(0xFF4CAF50);
      case 'BOOKING_IN_DIAGNOSIS':
        return const Color(0xFFFF9800);
      case 'BOOKING_STARTED':
        return const Color(0xFF2196F3);
      case 'REVIEW_CREATED':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF2196F3);
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Widget _buildNotificationCard(
      BuildContext context,
      NotificationItem n,
      NotificationController notiCtrl,
      ) {
    final iconColor = _colorForType(n.type, n.isRead);
    final timeLabel = _formatTime(n.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: n.isRead ? Colors.white : const Color(0xFF2196F3).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: n.isRead ? Colors.grey.shade200 : const Color(0xFF2196F3).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            if (!n.isRead) {
              await notiCtrl.markAsRead(n.id);
            }

            if (n.bookingId != null && context.mounted) {
              context.push('/booking-history/${n.bookingId}');
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _iconForType(n.type),
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              n.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: n.isRead ? FontWeight.w500 : FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (!n.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2196F3),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        n.body,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_outlined,
              size: 64,
              color: Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Chưa có thông báo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bạn sẽ nhận được thông báo về\nlịch hẹn và dịch vụ tại đây',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notiCtrl = context.watch<NotificationController>();
    final List<NotificationItem> items = notiCtrl.items;
    final unreadCount = items.where((item) => !item.isRead).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông báo',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (unreadCount > 0)
              Text(
                '$unreadCount chưa đọc',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          if (items.isNotEmpty)
            TextButton.icon(
              onPressed: unreadCount == 0
                  ? null
                  : () async {
                await notiCtrl.markAllAsRead();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Đã đánh dấu tất cả là đã đọc'),
                      backgroundColor: const Color(0xFF4CAF50),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              icon: Icon(
                Icons.done_all,
                size: 18,
                color: unreadCount == 0 ? Colors.grey.shade400 : const Color(0xFF2196F3),
              ),
              label: Text(
                'Đọc hết',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: unreadCount == 0 ? Colors.grey.shade400 : const Color(0xFF2196F3),
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF2196F3),
          onRefresh: () => notiCtrl.reload(),
          child: Builder(
            builder: (context) {
              if (notiCtrl.loading && items.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF2196F3),
                  ),
                );
              }

              if (items.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final n = items[index];
                  return _buildNotificationCard(context, n, notiCtrl);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}