class ServiceItem {
  final int id;
  final String name;
  final String type; // QUICK | REPAIR
  final String? description;
  final int? defaultDurationMin;
  final double? basePrice;

  bool get isQuick => type == 'QUICK';
  bool get isRepair => type == 'REPAIR';

  ServiceItem({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.defaultDurationMin,
    this.basePrice,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      defaultDurationMin: json['default_duration_min'] as int?,
      basePrice: json['base_price'] != null
          ? double.tryParse(json['base_price'].toString())
          : null,
    );
  }
}
