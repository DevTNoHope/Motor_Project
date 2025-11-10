import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/service.dart';
import '../../models/vehicle.dart';
import '../../services/reference_service.dart';
import '../../services/booking_service.dart';

class BookingFlowScreen extends StatefulWidget {
  const BookingFlowScreen({super.key});
  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  final _ref = ReferenceService();
  final _svc = BookingService();

  List<Vehicle> _vehicles = [];
  List<ServiceItem> _quick = [];
  List<ServiceItem> _repair = [];
  int? _vehicleId;
  final _selectedServiceIds = <int>{};
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _slots = []; // {start, end, freeMechanics?}
  Map<String, dynamic>? _pickedSlot;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final vehicles = await _ref.listVehicles();
    final quick = await _ref.listServices(type: 'QUICK');
    final repair = await _ref.listServices(type: 'REPAIR');
    setState(() { _vehicles = vehicles; _quick = quick; _repair = repair; });
  }

  Future<void> _loadSlots() async {
    if (_selectedServiceIds.isEmpty) return;
    final data = await _ref.getSlots(
      mechanicId: null,
      date: _selectedDate,
      serviceIds: _selectedServiceIds.toList(),
    );
    setState(() { _slots = (data['slots'] as List).cast<Map<String, dynamic>>(); _pickedSlot = null; });
  }

  Future<void> _createBooking() async {
    if (_vehicleId == null || _pickedSlot == null) return;
    final start = DateTime.parse(_pickedSlot!['start']);
    final data = await _svc.createBooking(
      vehicleId: _vehicleId!,
      serviceIds: _selectedServiceIds.toList(),
      start: start,
      mechanicId: null, // thợ bất kỳ
      notes: 'Đặt lịch từ app',
    );
    if (!mounted) return;
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Tạo booking'),
      content: Text('Đặt lịch thành công. ID: ${data['id']}'),
      actions: [ TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('OK')) ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt lịch dịch vụ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // chọn xe
          DropdownButtonFormField<int>(
            value: _vehicleId,
            items: _vehicles.map((v) => DropdownMenuItem(
                value: v.id, child: Text('${v.plateNo} - ${v.model ?? ''}'))).toList(),
            onChanged: (v) => setState(()=> _vehicleId = v),
            decoration: const InputDecoration(labelText: 'Chọn xe'),
          ),
          const SizedBox(height: 16),

          // chọn dịch vụ QUICK
          const Text('Dịch vụ NHANH', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: _quick.map((s){
              final selected = _selectedServiceIds.contains(s.id);
              return FilterChip(
                label: Text(s.name),
                selected: selected,
                onSelected: (_){
                  setState(() {
                    selected ? _selectedServiceIds.remove(s.id) : _selectedServiceIds.add(s.id);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // chọn dịch vụ REPAIR (chỉ cần một “Sửa xe tổng quát”, backend tự xử lý diagnose)
          const Text('Dịch vụ SỬA CHỮA', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: _repair.map((s){
              final selected = _selectedServiceIds.contains(s.id);
              return FilterChip(
                label: Text(s.name),
                selected: selected,
                onSelected: (_){
                  setState(() {
                    selected ? _selectedServiceIds.remove(s.id) : _selectedServiceIds.add(s.id);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // chọn ngày & load slot
          Row(children: [
            Expanded(child: Text('Ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}')),
            TextButton(onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            }, child: const Text('Đổi ngày')),
            const SizedBox(width: 8),
            FilledButton(onPressed: _loadSlots, child: const Text('Xem slot')),
          ]),
          const Divider(height: 24),

          // danh sách slot
          if (_slots.isNotEmpty) const Text('Chọn khung giờ:', style: TextStyle(fontWeight: FontWeight.bold)),
          ..._slots.map((s) {
            final t = '${df.format(DateTime.parse(s['start']).toLocal())} - ${df.format(DateTime.parse(s['end']).toLocal())}';
            final selected = _pickedSlot == s;
            return ListTile(
              title: Text(t),
              subtitle: s['freeMechanics'] != null ? Text('Thợ rảnh: ${(s['freeMechanics'] as List).join(', ')}') : null,
              trailing: selected ? const Icon(Icons.check_circle, color: Colors.teal) : null,
              onTap: () => setState(()=> _pickedSlot = s),
            );
          }),
          const SizedBox(height: 12),

          FilledButton(
            onPressed: _createBooking,
            child: const Text('Đặt lịch'),
          ),
        ],
      ),
    );
  }
}
