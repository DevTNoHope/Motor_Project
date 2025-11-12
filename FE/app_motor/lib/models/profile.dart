class AccountProfile {
  int id;
  String email;
  String? phone;
  String name;
  String? gender; // 'M' | 'F' | 'O'
  int? birthYear;
  String? avatarUrl;

  String? address; // thuộc USER
  String? note;    // thuộc USER

  AccountProfile({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.gender,
    this.birthYear,
    this.avatarUrl,
    this.address,
    this.note,
  });

  factory AccountProfile.fromApi(Map<String, dynamic> json) {
    final acc = json['account'] as Map<String, dynamic>;
    final user = json['profile'] as Map<String, dynamic>?;
    return AccountProfile(
      id: acc['id'],
      email: acc['email'],
      phone: acc['phone'],
      name: acc['name'] ?? '',
      gender: acc['gender'],
      birthYear: acc['birth_year'],
      avatarUrl: acc['avatar_url'],
      address: user?['address'],
      note: user?['note'],
    );
  }

  Map<String, dynamic> toPatch() => {
    'email': email,
    'phone': phone,
    'name': name,
    'gender': gender,
    'birth_year': birthYear,
    'avatar_url': avatarUrl,
    'address': address,
    'note': note,
  }..removeWhere((k, v) => v == null);
}
