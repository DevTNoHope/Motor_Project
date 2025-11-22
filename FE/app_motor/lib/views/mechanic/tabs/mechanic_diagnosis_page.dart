import 'package:flutter/material.dart';
import '../../../services/mechanic_booking_service.dart';
import '../../../utils/formatters.dart';

class MechanicDiagnosisPage extends StatefulWidget {
  final Map? booking;
  const MechanicDiagnosisPage({super.key, this.booking});

  @override
  State<MechanicDiagnosisPage> createState() => _MechanicDiagnosisPageState();
}

class _MechanicDiagnosisPageState extends State<MechanicDiagnosisPage> {
  final _formKey = GlobalKey<FormState>();
  final _noteCtrl = TextEditingController();
  final _laborEstCtrl = TextEditingController();
  final _etaCtrl = TextEditingController();

  bool _submitting = false;
  bool _loadingParts = true;
  List<dynamic> _allParts = []; // Danh sách phụ tùng lấy từ server
  final _service = MechanicBookingService();

  List<Map<String, dynamic>> _requiredParts = []; // phụ tùng được chọn
  DateTime? _calculatedEta;

  @override
  void initState() {
    super.initState();
    _fetchParts();
  }

  /// 🔹 Gọi API lấy danh sách phụ tùng
  Future<void> _fetchParts() async {
    try {
      final parts = await _service.getAllParts(); // gọi API /parts
      setState(() {
        _allParts = parts;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tải được danh sách phụ tùng: $e')));
    } finally {
      setState(() => _loadingParts = false);
    }
  }

  /// 🔹 Tính ETA tự động khi nhập thời gian sửa
  void _updateEta() {
    final booking = widget.booking ?? {};
    if (booking['start_dt'] == null) return;

    final start = DateTime.tryParse(booking['start_dt']);
    final laborEstMin = int.tryParse(_laborEstCtrl.text) ?? 0;

    if (start != null && laborEstMin > 0) {
      final eta = start.add(Duration(minutes: laborEstMin));
      setState(() {
        _calculatedEta = eta;
        _etaCtrl.text = formatTime(eta);
      });
    }
  }

  /// 🔹 Thêm dòng phụ tùng (chặn trùng ID)
  void _addPart() {
    final existingIds = _requiredParts.map((e) => e['partId']).whereType<int>().toList();
    final available = _allParts.where((p) => !existingIds.contains(p['id'])).toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã chọn hết các phụ tùng có sẵn')),
      );
      return;
    }

    setState(() {
      _requiredParts.add({'partId': null, 'qty': 1});
    });
  }

  /// 🔹 Xoá dòng phụ tùng
  void _removePart(int index) {
    setState(() {
      _requiredParts.removeAt(index);
    });
  }

  Future<void> _submit(int bookingId) async {
    if (!_formKey.currentState!.validate()) return;

    // Lọc phụ tùng hợp lệ và loại bỏ trùng
    final uniqueIds = <int>{};
    final validParts = _requiredParts
        .where((p) => p['partId'] != null && p['qty'] > 0)
        .where((p) => uniqueIds.add(p['partId'])) // chặn trùng
        .toList();

    setState(() => _submitting = true);

    try {
      await _service.submitDiagnosis(
        bookingId,
        diagnosisNote: _noteCtrl.text.trim(),
        laborEstMin: int.tryParse(_laborEstCtrl.text) ?? 0,
        etaMin: _calculatedEta != null
            ? _calculatedEta!
            .difference(DateTime.parse(widget.booking?['start_dt']))
            .inMinutes
            : 0,
        requiredParts: validParts,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi phiếu đánh giá xe ✅')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi khi gửi phiếu đánh giá: $e')));
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking ?? {};
    final vehicle = booking['vehicle'] ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text('Phiếu đánh giá xe')),
      body: _loadingParts
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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

              // Ghi chú
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

              // Ước lượng thời gian sửa
              TextFormField(
                controller: _laborEstCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ước lượng thời gian sửa (phút)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _updateEta(),
              ),
              const SizedBox(height: 16),

              // Thời gian trả xe dự kiến
              TextFormField(
                controller: _etaCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Thời gian trả xe dự kiến',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // 🔧 Phụ tùng
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Phụ tùng cần sử dụng',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    onPressed: _addPart,
                    icon: const Icon(Icons.add_circle, color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_requiredParts.isEmpty)
                const Text('Chưa thêm phụ tùng nào',
                    style: TextStyle(color: Colors.grey)),

              ..._requiredParts.asMap().entries.map((entry) {
                final i = entry.key;
                final part = entry.value;

                final existingIds = _requiredParts
                    .asMap()
                    .entries
                    .where((e) => e.key != i && e.value['partId'] != null)
                    .map((e) => e.value['partId'])
                    .toSet();

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<int>(
                            value: part['partId'],
                            decoration: const InputDecoration(
                              labelText: 'Phụ tùng',
                              border: OutlineInputBorder(),
                            ),
                            items: _allParts
                                .where((p) => !existingIds.contains(p['id']))
                                .map<DropdownMenuItem<int>>((p) {
                              return DropdownMenuItem<int>(
                                value: p['id'],
                                child: Text(p['name']),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => part['partId'] = val),
                            validator: (v) => v == null ? 'Chọn phụ tùng' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            initialValue: part['qty'].toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'SL',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) => part['qty'] = int.tryParse(v) ?? 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _removePart(i),
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                );
              }),

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
