import 'service_item.dart'; // đã có từ trước (model Service)
import 'part_model.dart';

class BookingServiceItem {
  final int id;
  final int bookingId;
  final int serviceId;
  final int qty;
  final String? priceSnapshot;
  final int? durationSnapshotMin;
  final ServiceItem? service; // Service trong BookingServices.Service

  BookingServiceItem({
    required this.id,
    required this.bookingId,
    required this.serviceId,
    required this.qty,
    this.priceSnapshot,
    this.durationSnapshotMin,
    this.service,
  });

  factory BookingServiceItem.fromJson(Map<String, dynamic> json) {
    return BookingServiceItem(
      id: json['id'] as int,
      bookingId: json['booking_id'] as int,
      serviceId: json['service_id'] as int,
      qty: json['qty'] as int,
      priceSnapshot: json['price_snapshot'] as String?,
      durationSnapshotMin: json['duration_snapshot_min'] as int?,
      service: json['Service'] != null
          ? ServiceItem.fromJson(json['Service'] as Map<String, dynamic>)
          : null,
    );
  }
}
class BookingPartModel {
  final int id;
  final int partId;
  final int qty;
  final double priceSnapshot;
  final PartModel? part; // name, unit, price gốc

  BookingPartModel({
    required this.id,
    required this.partId,
    required this.qty,
    required this.priceSnapshot,
    this.part,
  });

  factory BookingPartModel.fromJson(Map<String, dynamic> json) {
    return BookingPartModel(
      id: json['id'] as int,
      partId: json['part_id'] as int,
      qty: json['qty'] as int,
      priceSnapshot:
      double.tryParse(json['price_snapshot']?.toString() ?? '0') ?? 0,
      part: json['Part'] != null
          ? PartModel.fromJson(json['Part'] as Map<String, dynamic>)
          : null,
    );
  }

  double get lineTotal => priceSnapshot * qty;
}

class Booking {
  final int id;
  final int userId;
  final int? mechanicId;
  final int vehicleId;
  final DateTime startDt;
  final DateTime endDt;
  final String status;
  final String? notesUser;
  final String? notesMechanic;
  final String? totalServiceAmount;
  final String? totalPartsAmount;
  final String? totalAmount;
  final bool stockDeducted;
  final DateTime createdAt;
  final List<BookingServiceItem> services;
  final List<BookingPartModel> parts;

  Booking({
    required this.id,
    required this.userId,
    required this.mechanicId,
    required this.vehicleId,
    required this.startDt,
    required this.endDt,
    required this.status,
    required this.notesUser,
    required this.notesMechanic,
    required this.totalServiceAmount,
    required this.totalPartsAmount,
    required this.totalAmount,
    required this.stockDeducted,
    required this.createdAt,
    required this.services,
    this.parts = const [],
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final list = (json['BookingServices'] as List? ?? [])
        .map((e) => BookingServiceItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final partsJson = json['BookingParts'] as List? ?? [];

    return Booking(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      mechanicId: json['mechanic_id'] as int?,
      vehicleId: json['vehicle_id'] as int,
      startDt: DateTime.parse(json['start_dt'] as String),
      endDt: DateTime.parse(json['end_dt'] as String),
      status: json['status'] as String,
      notesUser: json['notes_user'] as String?,
      notesMechanic: json['notes_mechanic'] as String?,
      totalServiceAmount: json['total_service_amount'] as String?,
      totalPartsAmount: json['total_parts_amount'] as String?,
      totalAmount: json['total_amount'] as String?,
      stockDeducted: json['stock_deducted'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      services: list,
      parts: partsJson
          .map((e) => BookingPartModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Một số helper cho UI
  bool get hasRepair =>
      services.any((s) => s.service?.type == 'REPAIR');

  String get servicesLabel =>
      services.map((s) => s.service?.name ?? 'Dịch vụ #${s.serviceId}').join(', ');
}
