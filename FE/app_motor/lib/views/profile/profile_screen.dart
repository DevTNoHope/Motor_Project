import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../core/env.dart';
import '../../models/profile.dart';
import '../../services/profile_service.dart';
import '../../controllers/auth_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _svc = ProfileService();
  final _form = GlobalKey<FormState>();
  AccountProfile? _data;
  bool _loading = true;
  bool _saving = false;
  File? _avatarFile;

  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _name  = TextEditingController();
  final _birth = TextEditingController();
  final _address = TextEditingController();
  final _note = TextEditingController();
  String? _gender;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await _svc.getMe();
    final profile = AccountProfile.fromApi(res);
    _data = profile;

    _email.text = profile.email;
    _phone.text = profile.phone ?? '';
    _name.text  = profile.name;
    _gender = profile.gender;
    _birth.text = profile.birthYear?.toString() ?? '';
    _avatarUrl = profile.avatarUrl;
    _address.text = profile.address ?? '';
    _note.text = profile.note ?? '';

    setState(() => _loading = false);
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (picked == null) return;

    setState(() {
      _avatarFile = File(picked.path);      // preview bằng file local
    });
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      String? avatarUrl = _avatarUrl;
      if (_avatarFile != null) {
        final url = await _svc.uploadAvatar(_avatarFile!);
        avatarUrl = url;                    // url dạng /uploads/avatars/xxx.png
      }
      final payload = AccountProfile(
        id: _data!.id,
        email: _email.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        name: _name.text.trim(),
        gender: _gender,
        birthYear: _birth.text.trim().isEmpty ? null : int.tryParse(_birth.text.trim()),
        avatarUrl: avatarUrl,
        address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      ).toPatch();

      final res = await _svc.updateMe(payload);
      _data = AccountProfile.fromApi(res);

      _avatarFile = null;
      _avatarUrl = _data!.avatarUrl;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thành công')),
        );
      }
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _absoluteUrl(String url) {
    if (url.startsWith('http')) return url;
    // Env.baseUrl là .../api/v1 -> cắt /api/v1
    final apiBase = Env.baseUrl; // import Env ở đầu file
    final host = apiBase.replaceFirst(RegExp(r'/api/v1/?$'), '');
    return '$host$url';
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content:
        const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      context.read<AuthController>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ của tôi'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Lưu'),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // CARD AVATAR + TÓM TẮT
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _pickAvatar,
                          child: Stack(
                            children: [
                              _buildAvatar(),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color:
                                    Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _name.text.isEmpty
                                    ? 'Người dùng'
                                    : _name.text,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _email.text,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (_phone.text.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  _phone.text,
                                  style:
                                  Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // CARD THÔNG TIN CHI TIẾT
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _name,
                          decoration: const InputDecoration(
                            labelText: 'Họ tên',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Nhập họ tên'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _email,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => (v == null || !v.contains('@'))
                              ? 'Email không hợp lệ'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phone,
                          decoration: const InputDecoration(
                            labelText: 'Số điện thoại',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _gender,
                          decoration: const InputDecoration(
                            labelText: 'Giới tính',
                            prefixIcon: Icon(Icons.wc),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'M', child: Text('Nam')),
                            DropdownMenuItem(value: 'F', child: Text('Nữ')),
                            DropdownMenuItem(value: 'O', child: Text('Khác')),
                          ],
                          onChanged: (v) => setState(() => _gender = v),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _birth,
                          decoration: const InputDecoration(
                            labelText: 'Năm sinh',
                            prefixIcon: Icon(Icons.cake_outlined),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _address,
                          decoration: const InputDecoration(
                            labelText: 'Địa chỉ',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _note,
                          decoration: const InputDecoration(
                            labelText: 'Ghi chú',
                            alignLabelWithHint: true,
                            prefixIcon: Icon(Icons.notes_outlined),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // NÚT ĐĂNG XUẤT
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _confirmLogout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Đăng xuất'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                      Theme.of(context).colorScheme.error,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildAvatar() {
    const radius = 40.0;
    ImageProvider? image;

    if (_avatarFile != null) {
      image = FileImage(_avatarFile!);
    } else if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      image = CachedNetworkImageProvider(_absoluteUrl(_avatarUrl!));
    }

    if (image != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: image,
      );
    }

    return const CircleAvatar(
      radius: radius,
      child: Icon(Icons.person_outline, size: 32),
    );
  }

}
