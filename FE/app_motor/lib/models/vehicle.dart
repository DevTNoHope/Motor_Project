class Vehicle {
  final int id;
  final String plateNo;
  final String? brand;
  final String? model;
  final int? year;
  final String? color;

  Vehicle({
    required this.id,
    required this.plateNo,
    this.brand,
    this.model,
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
}
