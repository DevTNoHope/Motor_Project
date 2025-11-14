import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/env.dart';
import '../../models/profile.dart';
import '../../services/profile_service.dart';

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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ của tôi'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Lưu'),
          )
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: CircleAvatar(
                  radius: 44,
                  backgroundImage: _avatarFile != null
                      ? FileImage(_avatarFile!)
                      : (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                      ? NetworkImage(_absoluteUrl(_avatarUrl!)) // helper bên dưới
                      : null,
                  child: (_avatarFile == null && (_avatarUrl == null || _avatarUrl!.isEmpty))
                      ? const Icon(Icons.camera_alt)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Họ tên'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Nhập họ tên' : null,
            ),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || !v.contains('@')) ? 'Email không hợp lệ' : null,
            ),
            TextFormField(
              controller: _phone,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
              keyboardType: TextInputType.phone,
            ),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: const InputDecoration(labelText: 'Giới tính'),
              items: const [
                DropdownMenuItem(value: 'M', child: Text('Nam')),
                DropdownMenuItem(value: 'F', child: Text('Nữ')),
                DropdownMenuItem(value: 'O', child: Text('Khác')),
              ],
              onChanged: (v) => setState(() => _gender = v),
            ),
            TextFormField(
              controller: _birth,
              decoration: const InputDecoration(labelText: 'Năm sinh'),
              keyboardType: TextInputType.number,
            ),
            const Divider(height: 32),
            TextFormField(
              controller: _address,
              decoration: const InputDecoration(labelText: 'Địa chỉ'),
            ),
            TextFormField(
              controller: _note,
              decoration: const InputDecoration(labelText: 'Ghi chú'),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
