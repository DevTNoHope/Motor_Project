import 'package:flutter/foundation.dart';
import '../models/notification_item.dart';
import '../services/notification_service.dart';
import '../services/notification_socket_service.dart';

class NotificationController extends ChangeNotifier {
  final _service = NotificationService();

  List<NotificationItem> _items = [];
  bool _loading = false;
  bool _initialized = false;

  List<NotificationItem> get items => _items;
  bool get loading => _loading;
  int get unreadCount => _items.where((e) => !e.isRead).length;

  NotificationController() {
    _setupSocketListener();
  }

  void _setupSocketListener() {
    // mỗi lần có notification realtime từ BE
    NotificationSocketService.I.onNotification = (data) {
      try {
        final noti = NotificationItem.fromJson(
          Map<String, dynamic>.from(data),
        );
        // chèn noti mới lên đầu list
        _items = [noti, ..._items];
        notifyListeners();
      } catch (e) {
        if (kDebugMode) {
          print('Parse notification socket error: $e');
        }
      }
    };
  }

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await reload();
  }

  Future<void> reload() async {
    _loading = true;
    notifyListeners();
    try {
      _items = await _service.getMyNotifications(limit: 50, offset: 0);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    await _service.markAsRead(id);
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final old = _items[idx];
      _items[idx] = NotificationItem(
        id: old.id,
        type: old.type,
        title: old.title,
        body: old.body,
        bookingId: old.bookingId,
        isRead: true,
        createdAt: old.createdAt,
      );
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    await _service.markAllAsRead();
    _items = _items
        .map(
          (e) => NotificationItem(
        id: e.id,
        type: e.type,
        title: e.title,
        body: e.body,
        bookingId: e.bookingId,
        isRead: true,
        createdAt: e.createdAt,
      ),
    )
        .toList();
    notifyListeners();
  }

  void clear() {
    _items = [];
    _initialized = false;
    notifyListeners();
  }
}
