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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notiCtrl = context.watch<NotificationController>();
    final List<NotificationItem> items = notiCtrl.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          IconButton(
            tooltip: 'Đánh dấu đã đọc hết',
            onPressed: items.isEmpty
                ? null
                : () async {
              await notiCtrl.markAllAsRead();
            },
            icon: const Icon(Icons.done_all),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notiCtrl.reload(),
        child: Builder(
          builder: (context) {
            if (notiCtrl.loading && items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (items.isEmpty) {
              return const Center(child: Text('Chưa có thông báo nào.'));
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (context, index) {
                final n = items[index];
                final subtitle = n.body;
                final timeLabel =
                    '${n.createdAt.hour.toString().padLeft(2, '0')}:${n.createdAt.minute.toString().padLeft(2, '0')} '
                    '${n.createdAt.day}/${n.createdAt.month}';

                return ListTile(
                  leading: Icon(
                    _iconForType(n.type),
                    color: n.isRead
                        ? theme.colorScheme.outline
                        : theme.colorScheme.primary,
                  ),
                  title: Text(
                    n.title,
                    style: n.isRead
                        ? null
                        : theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('$subtitle\n$timeLabel'),
                  isThreeLine: true,
                  trailing:
                  n.isRead ? null : const Icon(Icons.circle, size: 10),
                  onTap: () async {
                    // đánh dấu đã đọc nếu chưa
                    if (!n.isRead) {
                      await notiCtrl.markAsRead(n.id);
                    }

                    // nếu là thông báo liên quan booking -> mở chi tiết
                    if (n.bookingId != null && context.mounted) {
                      context.push('/booking-history/${n.bookingId}');
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
