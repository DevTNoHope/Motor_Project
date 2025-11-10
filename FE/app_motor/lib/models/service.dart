class ServiceItem {
  final int id;
  final String name;
  final String type; // QUICK | REPAIR
  final int? defaultDurationMin;
  final num? basePrice;

  ServiceItem({
    required this.id,
    required this.name,
    required this.type,
    this.defaultDurationMin,
    this.basePrice,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> j) => ServiceItem(
    id: j['id'],
    name: j['name'],
    type: j['type'],
    defaultDurationMin: j['default_duration_min'],
    basePrice: j['base_price'],
  );
}
