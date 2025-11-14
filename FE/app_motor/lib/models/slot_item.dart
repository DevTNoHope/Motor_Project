class SlotItem {
  final DateTime start;
  final DateTime end;
  final List<int> freeMechanicIds;
  final int? mechanicId;

  SlotItem({
    required this.start,
    required this.end,
    required this.freeMechanicIds,
    this.mechanicId,
  });

  factory SlotItem.fromJson(Map<String, dynamic> json) {
    final start = DateTime.parse(json['start'] as String);
    final end = DateTime.parse(json['end'] as String);
    // có thể là freeMechanics (thợ bất kỳ) hoặc mechanicId (thợ cụ thể)
    final fm = json['freeMechanics'];
    List<int> freeMechanics = [];
    if (fm is List) {
      freeMechanics = fm.map((e) => e as int).toList();
    }

    int? mechanicId;
    if (json['mechanicId'] != null) {
      mechanicId = json['mechanicId'] as int;
      // nếu BE chỉ trả mechanicId, ta cho luôn vào freeMechanics
      if (freeMechanics.isEmpty) {
        freeMechanics = [mechanicId];
      }
    }
    return SlotItem(
      start: start,
      end: end,
      freeMechanicIds: freeMechanics,
      mechanicId: mechanicId,
    );
  }

  String get timeRangeLabel =>
      '${_fmtTime(start.toLocal())} - ${_fmtTime(end.toLocal())}';

  static String _fmtTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
