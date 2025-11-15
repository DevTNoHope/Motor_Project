class DiagnosisPart {
  final int id;
  final String name;
  final double price;
  final String unit;

  DiagnosisPart({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
  });

  factory DiagnosisPart.fromJson(Map<String, dynamic> json) {
    return DiagnosisPart(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      unit: json['unit'] as String? ?? '',
    );
  }
}

class DiagnosisRequiredPart {
  final int qty;
  final int partId;
  final DiagnosisPart? part; // <-- thêm

  DiagnosisRequiredPart({
    required this.qty,
    required this.partId,
    this.part,
  });

  factory DiagnosisRequiredPart.fromJson(Map<String, dynamic> json) {
    return DiagnosisRequiredPart(
      qty: json['qty'] as int,
      partId: json['partId'] as int,
      part: json['part'] != null
          ? DiagnosisPart.fromJson(json['part'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Diagnosis {
  final int id;
  final int bookingId;
  final String diagnosisNote;
  final int etaMin;
  final int laborEstMin;
  final List<DiagnosisRequiredPart> requiredParts;
  final DateTime createdAt;

  Diagnosis({
    required this.id,
    required this.bookingId,
    required this.diagnosisNote,
    required this.etaMin,
    required this.laborEstMin,
    required this.requiredParts,
    required this.createdAt,
  });

  factory Diagnosis.fromJson(Map<String, dynamic> json) {
    final partsJson = (json['required_parts'] as List? ?? []);
    final parts = partsJson
        .map((e) => DiagnosisRequiredPart.fromJson(
      e as Map<String, dynamic>,
    ))
        .toList();

    return Diagnosis(
      id: json['id'] as int,
      bookingId: json['booking_id'] as int,
      diagnosisNote: json['diagnosis_note'] as String? ?? '',
      etaMin: json['eta_min'] as int? ?? 0,
      laborEstMin: json['labor_est_min'] as int? ?? 0,
      requiredParts: parts,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get etaLabel {
    if (etaMin <= 0) return 'Không rõ';
    final h = etaMin ~/ 60;
    final m = etaMin % 60;
    if (h == 0) return '$m phút';
    if (m == 0) return '$h giờ';
    return '$h giờ $m phút';
  }

  String get laborLabel {
    if (laborEstMin <= 0) return 'Không rõ';
    final h = laborEstMin ~/ 60;
    final m = laborEstMin % 60;
    if (h == 0) return '$m phút';
    if (m == 0) return '$h giờ';
    return '$h giờ $m phút';
  }
}
