class Vehicle {
  final int id;
  final String plateNo;
  final String? brand;
  final String model;
  final int? year;
  final String? color;

  Vehicle({
    required this.id,
    required this.plateNo,
    this.brand,
    required this.model,
    this.year,
    this.color,
  });

  factory Vehicle.fromJson(Map<String, dynamic> j) => Vehicle(
    id: j['id'],
    plateNo: j['plate_no'],
    brand: j['brand'],
    model: j['model'],
    year: j['year'],
    color: j['color'],
  );

  Map<String, dynamic> toCreatePayload() => {
    'plate_no': plateNo,                      // <-- dùng 'plate_no'
    if (brand != null) 'brand': brand,
    if (model != null) 'model': model,
    if (year != null) 'year': year,
    if (color != null) 'color': color,
  };

  Map<String, dynamic> toUpdatePayload() => {
    if (plateNo.isNotEmpty) 'plate_no': plateNo,
    if (brand != null) 'brand': brand,
    if (model != null) 'model': model,
    if (year != null) 'year': year,
    if (color != null) 'color': color,
  };
}
