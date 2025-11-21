class NotificationItem {
  final int id;
  final String type;
  final String title;
  final String body;
  final int? bookingId;
  final bool isRead;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.bookingId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> j) {
    return NotificationItem(
      id: j['id'] as int,
      type: j['type'] as String,
      title: j['title'] as String,
      body: j['body'] as String,
      bookingId: j['booking_id'] as int?,
      isRead: j['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(j['created_at'] as String),
    );
  }
}
