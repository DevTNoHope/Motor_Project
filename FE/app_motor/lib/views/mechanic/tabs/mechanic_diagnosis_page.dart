import 'package:flutter/material.dart';
import '../../../services/mechanic_booking_service.dart';

class MechanicDiagnosisPage extends StatefulWidget {
  const MechanicDiagnosisPage({super.key});

  @override
  State<MechanicDiagnosisPage> createState() => _MechanicDiagnosisPageState();
}

class _MechanicDiagnosisPageState extends State<MechanicDiagnosisPage> {
  final _formKey = GlobalKey<FormState>();
  final _noteCtrl = TextEditingController();
  final _laborEstCtrl = TextEditingController();
  final _etaCtrl = TextEditingController();

  bool _submitting = false;
  final _service = MechanicBookingService();

  Future<void> _submit(int bookingId) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      await _service.submitDiagnosis(
        bookingId,
        diagnosisNote: _noteCtrl.text.trim(),
        laborEstMin: int.tryParse(_laborEstCtrl.text) ?? 0,
        etaMin: int.tryParse(_etaCtrl.text) ?? 0,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi phiếu đánh giá xe ✅')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi gửi phiếu đánh giá: $e')),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = ModalRoute.of(context)!.settings.arguments as Map;
    final vehicle = booking['vehicle'] ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text('Phiếu đánh giá xe')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Xe: ${vehicle['brand'] ?? ''} ${vehicle['model'] ?? ''} (${vehicle['plate_no'] ?? ''})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú chẩn đoán',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (v) =>
                v == null || v.isEmpty ? 'Vui lòng nhập chẩn đoán' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _laborEstCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ước lượng thời gian sửa (phút)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _etaCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Thời gian trả xe dự kiến (phút)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submitting ? null : () => _submit(booking['id']),
                icon: const Icon(Icons.send),
                label: _submitting
                    ? const Text('Đang gửi...')
                    : const Text('Gửi phiếu đánh giá'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
