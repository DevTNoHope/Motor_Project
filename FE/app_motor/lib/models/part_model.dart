class PartModel {
  final int id;
  final String name;
  final double price;
  final String unit;
  final String? description;
  final bool? isActive;

  PartModel({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    this.description,
    this.isActive,
  });

  factory PartModel.fromJson(Map<String, dynamic> json) {
    return PartModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      unit: json['unit'] as String? ?? '',
      description: json['description'] as String?,
      isActive: json['is_active'] as bool?,
    );
  }
}
