class BookingItemService {
  final int id;
  final int serviceId;
  final int qty;
  final num? priceSnapshot;
  final int? durationSnapshotMin;
  final String? name; // từ include Service

  BookingItemService({
    required this.id,
    required this.serviceId,
    required this.qty,
    this.priceSnapshot,
    this.durationSnapshotMin,
    this.name,
  });

  factory BookingItemService.fromJson(Map<String, dynamic> j) => BookingItemService(
    id: j['id'],
    serviceId: j['service_id'],
    qty: j['qty'] ?? 1,
    priceSnapshot: j['price_snapshot'],
    durationSnapshotMin: j['duration_snapshot_min'],
    name: (j['Service'] is Map) ? j['Service']['name'] as String? : null,
  );
}

class Booking {
  final int id;
  final String status;               // PENDING|APPROVED|IN_DIAGNOSIS|IN_PROGRESS|DONE|CANCELED
  final DateTime startDt;
  final DateTime? endDt;
  final int? userId;
  final int? mechanicId;
  final int? vehicleId;
  final String? notesUser;
  final String? notesMechanic;
  final num? totalServiceAmount;
  final num? totalPartsAmount;
  final num? totalAmount;
  final List<BookingItemService> items;

  Booking({
    required this.id,
    required this.status,
    required this.startDt,
    this.endDt,
    this.userId,
    this.mechanicId,
    this.vehicleId,
    this.notesUser,
    this.notesMechanic,
    this.totalServiceAmount,
    this.totalPartsAmount,
    this.totalAmount,
    this.items = const [],
  });

  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
    id: j['id'],
    status: j['status'],
    startDt: DateTime.parse(j['start_dt']),
    endDt: j['end_dt'] != null ? DateTime.parse(j['end_dt']) : null,
    userId: j['user_id'],
    mechanicId: j['mechanic_id'],
    vehicleId: j['vehicle_id'],
    notesUser: j['notes_user'],
    notesMechanic: j['notes_mechanic'],
    totalServiceAmount: j['total_service_amount'],
    totalPartsAmount: j['total_parts_amount'],
    totalAmount: j['total_amount'],
    items: (j['BookingServices'] is List)
        ? (j['BookingServices'] as List)
        .cast<Map<String, dynamic>>()
        .map(BookingItemService.fromJson)
        .toList()
        : const [],
  );
}
