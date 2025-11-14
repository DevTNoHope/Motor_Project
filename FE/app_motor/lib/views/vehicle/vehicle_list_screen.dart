import 'package:flutter/material.dart';
import '../../models/vehicle.dart';
import '../../services/vehicle_service.dart';
import 'vehicle_form_screen.dart';
import 'package:dio/dio.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final _svc = VehicleService();
  bool _loading = true;
  List<Vehicle> _items = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items = await _svc.listMine();        // <-- /me/vehicles
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openCreate() async {
    final v = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const VehicleFormScreen()),
    );
    if (v != null) _load();
  }

  Future<void> _openEdit(Vehicle v) async {
    final r = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VehicleFormScreen(initial: v)),
    );
    if (r != null) _load();
  }

  Future<void> _confirmDelete(Vehicle v) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Xoá xe ${v.plateNo}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huỷ')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xoá')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await _svc.remove(v.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xoá xe')));
        _load();
      }
    } on DioException catch (e) {
      // Thường BE sẽ từ chối xoá nếu xe có booking → có thể trả 409 hoặc 400 với code riêng
      final data = e.response?.data;
      final msg = (data is Map && data['message'] is String)
          ? data['message'] as String
          : 'Không thể xoá xe. Vui lòng thử lại.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xe của tôi')),
      floatingActionButton: FloatingActionButton(onPressed: _openCreate, child: const Icon(Icons.add)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final v = _items[i];
            return ListTile(
              title: Text(v.plateNo),
              subtitle: Text([
                if (v.brand != null) v.brand,
                if (v.model != null) v.model,
                if (v.year != null) '${v.year}',
                if (v.color != null) v.color,
              ].whereType<String>().join(' · ')),
              trailing: PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'edit') _openEdit(v);
                  if (val == 'delete') _confirmDelete(v);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Sửa')),
                  PopupMenuItem(value: 'delete', child: Text('Xoá')),
                ],
              ),
              onTap: () => _openEdit(v),
            );
          },
        ),
      ),
    );
  }
}
