import 'package:flutter/material.dart';
import '../../models/vehicle.dart';
import '../../services/vehicle_service.dart';
import 'package:dio/dio.dart';

class VehicleFormScreen extends StatefulWidget {
  final Vehicle? initial;
  const VehicleFormScreen({super.key, this.initial});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _svc = VehicleService();
  final _form = GlobalKey<FormState>();

  final _plate = TextEditingController();
  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _year  = TextEditingController();
  final _color = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final v = widget.initial;
    if (v != null) {
      _plate.text = v.plateNo;         // <-- plateNo
      _brand.text = v.brand ?? '';
      _model.text = v.model ?? '';
      _year.text  = v.year?.toString() ?? '';
      _color.text = v.color ?? '';
    }
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final veh = Vehicle(
        id: widget.initial?.id ?? 0,
        plateNo: _plate.text.trim(),
        brand: _brand.text.trim().isEmpty ? null : _brand.text.trim(),
        model: _model.text.trim(),
        year: _year.text.trim().isEmpty ? null : int.tryParse(_year.text.trim()),
        color: _color.text.trim().isEmpty ? null : _color.text.trim(),
      );

      late Vehicle result;
      if (widget.initial == null) {
        result = await _svc.create(veh);
      } else {
        result = await _svc.update(widget.initial!.id, veh);
      }

      if (!mounted) return;
      Navigator.of(context).pop(result);
    } on DioException catch (e) {
      final code = (e.response?.data is Map) ? e.response?.data['code'] as String? : null;
      if (code == 'PLATE_EXISTS') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biển số đã tồn tại')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: ${e.message}')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteCurrent() async {
    final v = widget.initial!;
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

    setState(() => _saving = true);
    try {
      await _svc.remove(v.id);
      if (!mounted) return;
      Navigator.of(context).pop(true); // báo về list để refresh
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map && data['message'] is String)
          ? data['message'] as String
          : 'Không thể xoá xe. Vui lòng thử lại.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          isDense: true,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Cập nhật xe' : 'Thêm xe'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _saving ? null : _deleteCurrent,
              tooltip: 'Xoá xe',
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin xe',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Biển số
                    _buildTextField(
                      controller: _plate,
                      label: 'Biển số',
                      hint: 'VD: 59A1-12345',
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) {
                        if (v == null || v.trim().length < 4) {
                          return 'Nhập biển số hợp lệ';
                        }
                        return null;
                      },
                    ),

                    // Hãng
                    _buildTextField(
                      controller: _brand,
                      label: 'Hãng xe',
                    ),

                    // Dòng xe
                    _buildTextField(
                      controller: _model,
                      label: 'Dòng xe',
                    ),

                    // Năm
                    _buildTextField(
                      controller: _year,
                      label: 'Năm sản xuất',
                      keyboardType: TextInputType.number,
                    ),

                    // Màu
                    _buildTextField(
                      controller: _color,
                      label: 'Màu xe',
                    ),

                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _saving ? null : _submit,
                        icon: _saving
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Icon(Icons.check),
                        label: Text(isEdit ? 'Lưu thay đổi' : 'Thêm xe'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
