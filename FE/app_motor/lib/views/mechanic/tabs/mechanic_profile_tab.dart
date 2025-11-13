import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../controllers/auth_controller.dart';
import '../../../services/me_service.dart';

class MechanicProfileTab extends StatefulWidget {
  const MechanicProfileTab({super.key});

  @override
  State<MechanicProfileTab> createState() => _MechanicProfileTabState();
}

class _MechanicProfileTabState extends State<MechanicProfileTab> {
  final _meService = MeService();
  Map<String, dynamic>? _data;
  bool _loading = true;
  bool _editing = false;

  // form controllers
  final nameCtrl = TextEditingController();
  final skillCtrl = TextEditingController();
  final birthCtrl = TextEditingController();
  final avatarCtrl = TextEditingController();
  String? gender;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final data = await _meService.getProfile();
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Lỗi khi tải hồ sơ: $e');
      setState(() => _loading = false);
    }
  }

  void _fillForm() {
    if (_data == null) return;
    final acc = _data!['account'];
    final profile = _data!['profile'];

    nameCtrl.text = acc['name'] ?? '';
    skillCtrl.text = profile?['skill_tags'] ?? '';
    birthCtrl.text = acc['birth_year']?.toString() ?? '';
    avatarCtrl.text = acc['avatar_url'] ?? '';
    gender = acc['gender'];
  }

  Future<void> _saveProfile() async {
    // ✅ chỉ gửi những trường hợp lệ cho backend
    final payload = {
      'name': nameCtrl.text.trim(),
      'gender': gender,
      if (birthCtrl.text.trim().isNotEmpty)
        'birth_year': int.tryParse(birthCtrl.text.trim()),
      'avatar_url': avatarCtrl.text.trim(),
      'skill_tags': skillCtrl.text.trim(),
    };

    try {
      setState(() => _loading = true);
      final updated = await _meService.updateProfile(payload);
      setState(() {
        _data = updated;
        _editing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật hồ sơ thành công ✅')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thất bại: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_data == null) {
      return const Center(child: Text('Không tải được dữ liệu thợ.'));
    }

    final acc = _data!['account'];
    final role = _data!['role'];
    final profile = _data!['profile'];

    // 🔹 Nếu đang ở chế độ chỉnh sửa
    if (_editing) {

      return Scaffold(
        appBar: AppBar(
          title: const Text('Chỉnh sửa hồ sơ'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _editing = false),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Họ và tên'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: gender,
                decoration: const InputDecoration(labelText: 'Giới tính'),
                items: const [
                  DropdownMenuItem(value: 'M', child: Text('Nam')),
                  DropdownMenuItem(value: 'F', child: Text('Nữ')),
                  DropdownMenuItem(value: 'O', child: Text('Khác')),
                ],
                onChanged: (v) => setState(() => gender = v),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: birthCtrl,
                decoration: const InputDecoration(labelText: 'Năm sinh'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: skillCtrl,
                decoration: const InputDecoration(labelText: 'Kỹ năng'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: avatarCtrl,
                decoration: const InputDecoration(labelText: 'Avatar URL'),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Lưu thay đổi'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => setState(() => _editing = false),
                icon: const Icon(Icons.cancel),
                label: const Text('Hủy'),
              ),
            ],
          ),
        ),
      );
    }

    // 🔹 Giao diện cũ — chỉ hiển thị thông tin
    return RefreshIndicator(
      onRefresh: _fetchProfile,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: acc['avatar_url'] != null &&
                  acc['avatar_url'].toString().isNotEmpty
                  ? NetworkImage(acc['avatar_url'])
                  : const AssetImage('assets/mechanic.png') as ImageProvider,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              acc['name'] ?? 'Chưa có tên',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text('Vai trò: $role',
                style: const TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(acc['email'] ?? 'Không có email'),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(acc['phone'] ?? 'Không có số điện thoại'),
          ),
          if (profile != null && profile['skill_tags'] != null) ...[
            ListTile(
              leading: const Icon(Icons.handyman),
              title: Text('Kỹ năng: ${profile['skill_tags']}'),
            ),
          ],
          const SizedBox(height: 24),

          // 🔹 Nút mở form cập nhật
          ElevatedButton.icon(
            onPressed: () {
              _fillForm(); // ✅ chuyển lên đây
              setState(() => _editing = true);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Cập nhật hồ sơ'),
          ),

          const SizedBox(height: 16),
          const Divider(),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              minimumSize: const Size.fromHeight(45),
            ),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Xác nhận đăng xuất'),
                  content:
                  const Text('Bạn có chắc chắn muốn đăng xuất không?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Đăng xuất'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await auth.logout();
                if (context.mounted) context.go('/login');
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
