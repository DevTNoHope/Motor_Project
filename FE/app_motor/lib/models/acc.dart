class Acc {
  final int id;
  final String name;
  final String? phone;

  Acc({required this.id, required this.name, this.phone});

  factory Acc.fromJson(Map<String, dynamic> j) =>
      Acc(id: j['id'], name: j['name'], phone: j['phone']);
}
