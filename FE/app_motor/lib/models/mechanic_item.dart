class MechanicItem {
  final int id;
  final String name;
  final String? phone;
  final String? avatarUrl;
  final String? skillTags;

  MechanicItem({
    required this.id,
    required this.name,
    this.phone,
    this.avatarUrl,
    this.skillTags,
  });

  factory MechanicItem.fromJson(Map<String, dynamic> json) {
    final acc = json['Acc'] as Map<String, dynamic>;
    return MechanicItem(
      id: json['id'] as int,
      name: acc['name'] as String? ?? 'Thợ ${json['id']}',
      phone: acc['phone'] as String?,
      avatarUrl: acc['avatar_url'] as String?,
      skillTags: json['skill_tags'] as String?,
    );
  }
}
