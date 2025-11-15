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
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Cập nhật hồ sơ thành công ✅'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Cập nhật thất bại: $e')),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
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

    if (_editing) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          title: const Text(
            'Chỉnh sửa hồ sơ',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => setState(() => _editing = false),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildEditCard(
                  icon: Icons.person,
                  title: 'Họ và tên',
                  child: TextField(
                    controller: nameCtrl,
                    style: const TextStyle(fontSize: 16),
                    decoration: _inputDecoration('Nhập họ tên...'),
                  ),
                ),
                const SizedBox(height: 16),
                _buildEditCard(
                  icon: Icons.wc,
                  title: 'Giới tính',
                  child: DropdownButtonFormField<String>(
                    value: gender,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    decoration: _inputDecoration('Chọn giới tính...'),
                    items: const [
                      DropdownMenuItem(value: 'M', child: Text('Nam')),
                      DropdownMenuItem(value: 'F', child: Text('Nữ')),
                      DropdownMenuItem(value: 'O', child: Text('Khác')),
                    ],
                    onChanged: (v) => setState(() => gender = v),
                  ),
                ),
                const SizedBox(height: 16),
                _buildEditCard(
                  icon: Icons.cake,
                  title: 'Năm sinh',
                  child: TextField(
                    controller: birthCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 16),
                    decoration: _inputDecoration('Nhập năm sinh...'),
                  ),
                ),
                const SizedBox(height: 16),
                _buildEditCard(
                  icon: Icons.handyman,
                  title: 'Kỹ năng',
                  child: TextField(
                    controller: skillCtrl,
                    style: const TextStyle(fontSize: 16),
                    decoration: _inputDecoration('Nhập kỹ năng...'),
                  ),
                ),
                const SizedBox(height: 16),
                _buildEditCard(
                  icon: Icons.image,
                  title: 'Avatar URL',
                  child: TextField(
                    controller: avatarCtrl,
                    style: const TextStyle(fontSize: 16),
                    decoration: _inputDecoration('Nhập URL ảnh đại diện...'),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: Colors.blue.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.save, size: 24),
                    label: const Text(
                      'Lưu thay đổi',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _editing = false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.cancel, size: 24),
                    label: const Text(
                      'Hủy',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchProfile,
      child: Container(
        color: Colors.grey.shade50,
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            // Header with gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Hero(
                    tag: 'avatar',
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: acc['avatar_url'] != null &&
                            acc['avatar_url'].toString().isNotEmpty
                            ? NetworkImage(acc['avatar_url'])
                            : const AssetImage('assets/mechanic.png') as ImageProvider,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    acc['name'] ?? 'Chưa có tên',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Vai trò: $role',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInfoCard(
                    icon: Icons.email_rounded,
                    title: 'Email',
                    value: acc['email'] ?? 'Không có email',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.phone_rounded,
                    title: 'Số điện thoại',
                    value: acc['phone'] ?? 'Không có số điện thoại',
                    color: Colors.green,
                  ),
                  if (profile != null && profile['skill_tags'] != null) ...[
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.handyman_rounded,
                      title: 'Kỹ năng',
                      value: profile['skill_tags'],
                      color: Colors.purple,
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _fillForm();
                        setState(() => _editing = true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: Colors.blue.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.edit_rounded, size: 24),
                      label: const Text(
                        'Cập nhật hồ sơ',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade500,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: Colors.red.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Row(
                              children: [
                                Icon(Icons.warning_rounded, color: Colors.orange, size: 28),
                                SizedBox(width: 12),
                                Text('Xác nhận đăng xuất'),
                              ],
                            ),
                            content: const Text(
                              'Bạn có chắc chắn muốn đăng xuất không?',
                              style: TextStyle(fontSize: 16),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  'Hủy',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade500,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Đăng xuất',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await auth.logout();
                          if (context.mounted) context.go('/login');
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, size: 24),
                      label: const Text(
                        'Đăng xuất',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.blue.shade600, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
    );
  }
}