import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../models/vehicle.dart';
import '../../models/service_item.dart';
import '../../models/mechanic_item.dart';
import '../../models/slot_item.dart';

import '../../services/vehicle_service.dart';
import '../../services/service_catalog_service.dart';
import '../../services/mechanic_service.dart';
import '../../services/slot_service.dart';
import '../../services/booking_service.dart';

class BookingFlowScreen extends StatefulWidget {
  const BookingFlowScreen({super.key});

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

enum _Step { vehicle, services, mechanic, time, confirm }
enum _MechanicMode { any, specific }

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  final _vehicleSvc = VehicleService();
  final _serviceSvc = ServiceCatalogService();
  final _mechanicSvc = MechanicService();
  final _slotSvc = SlotService();
  final _bookingSvc = BookingService();

  _Step _step = _Step.vehicle;

  // data
  List<Vehicle> _vehicles = [];
  List<ServiceItem> _services = [];
  List<MechanicItem> _mechanics = [];

  Vehicle? _selectedVehicle;
  final Set<int> _selectedServiceIds = {};
  _MechanicMode _mechanicMode = _MechanicMode.any;
  MechanicItem? _selectedMechanic;

  DateTime _selectedDate = DateTime.now();
  List<SlotItem> _slots = [];
  SlotItem? _selectedSlot;

  final _noteCtrl = TextEditingController();
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _loading = true);
    try {
      final vehicles = await _vehicleSvc.listMine();
      final services = await _serviceSvc.getServices();
      final mechanics = await _mechanicSvc.getMechanics();

      setState(() {
        _vehicles = vehicles;
        _services = services.where((s) => s.isQuick || s.isRepair).toList();
        _mechanics = mechanics;
        if (_vehicles.isNotEmpty) _selectedVehicle = _vehicles.first;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _hasRepair {
    return _services
        .where((s) => _selectedServiceIds.contains(s.id))
        .any((s) => s.isRepair);
  }

  List<ServiceItem> get _quickServices =>
      _services.where((s) => s.isQuick).toList();
  List<ServiceItem> get _repairServices =>
      _services.where((s) => s.isRepair).toList();

  Future<void> _next() async {
    if (_step == _Step.vehicle) {
      if (_selectedVehicle == null) {
        _showMsg('Vui lòng chọn xe');
        return;
      }
      setState(() => _step = _Step.services);
    } else if (_step == _Step.services) {
      if (_selectedServiceIds.isEmpty) {
        _showMsg('Vui lòng chọn ít nhất 1 dịch vụ');
        return;
      }
      setState(() => _step = _Step.mechanic);
    } else if (_step == _Step.mechanic) {
      if (_mechanicMode == _MechanicMode.specific &&
          _selectedMechanic == null) {
        _showMsg('Vui lòng chọn thợ hoặc chọn "Thợ bất kỳ"');
        return;
      }
      setState(() => _step = _Step.time);
      await _loadSlots();
    } else if (_step == _Step.time) {
      if (_selectedSlot == null) {
        _showMsg('Vui lòng chọn khung giờ');
        return;
      }
      setState(() => _step = _Step.confirm);
    } else if (_step == _Step.confirm) {
      await _submit();
    }
  }

  void _back() {
    setState(() {
      if (_step == _Step.services) {
        _step = _Step.vehicle;
      } else if (_step == _Step.mechanic) {
        _step = _Step.services;
      } else if (_step == _Step.time) {
        _step = _Step.mechanic;
      } else if (_step == _Step.confirm) {
        _step = _Step.time;
      }
    });
  }

  Future<void> _loadSlots() async {
    setState(() {
      _slots = [];
      _selectedSlot = null;
    });
    try {
      final serviceIds = _selectedServiceIds.toList();
      final mechanicId =
      _mechanicMode == _MechanicMode.specific ? _selectedMechanic?.id : null;

      final slots = await _slotSvc.getSlots(
        date: _selectedDate,
        mechanicId: mechanicId,
        serviceIds: serviceIds,
      );

      setState(() {
        _slots = slots;
      });
    } catch (e) {
      _showMsg('Lỗi tải slots: $e');
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      await _loadSlots();
    }
  }

  Future<void> _submit() async {
    if (_selectedVehicle == null || _selectedSlot == null) return;
    setState(() => _submitting = true);
    try {
      final serviceIds = _selectedServiceIds.toList();
      final mechanicId =
      _mechanicMode == _MechanicMode.specific ? _selectedMechanic?.id : null;

      final startUtc = _selectedSlot!.start.toUtc();

      final result = await _bookingSvc.createBooking(
        vehicleId: _selectedVehicle!.id,
        serviceIds: serviceIds,
        mechanicId: mechanicId,
        startUtc: startUtc,
        notesUser:
        _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );

      if (!mounted) return;

      _showMsg(
        'Đặt lịch thành công (mã #${result['id']}, trạng thái: ${result['status']})',
      );
      Navigator.of(context).pop(); // hoặc chuyển sang màn danh sách booking
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? ((e.response!.data['message'] ??
          e.response!.data['code'] ??
          'Lỗi không xác định') as String)
          : e.message ?? 'Lỗi không xác định';
      _showMsg('Đặt lịch thất bại: $msg');
    } catch (e) {
      _showMsg('Đặt lịch thất bại: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
        title: const Text('Đặt lịch dịch vụ'),
        leading: _step == _Step.vehicle
            ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        )
            : IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _back,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildStep(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ElevatedButton(
          onPressed: _submitting ? null : _next,
          child: _submitting
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Text(_step == _Step.confirm ? 'Xác nhận đặt lịch' : 'Tiếp tục'),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _Step.vehicle:
        return _buildVehicleStep();
      case _Step.services:
        return _buildServicesStep();
      case _Step.mechanic:
        return _buildMechanicStep();
      case _Step.time:
        return _buildTimeStep();
      case _Step.confirm:
        return _buildConfirmStep();
    }
  }

  Widget _buildVehicleStep() {
    if (_vehicles.isEmpty) {
      return const Center(child: Text('Bạn chưa có xe. Vui lòng thêm xe trước.'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Chọn xe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._vehicles.map((v) {
          final selected = _selectedVehicle?.id == v.id;
          return Card(
            child: ListTile(
              title: Text(v.plateNo),
              subtitle: Text('${v.brand ?? ''} ${v.model ?? ''} ${v.year ?? ''}'),
              trailing: selected ? const Icon(Icons.check_circle, color: Colors.green) : null,
              onTap: () => setState(() => _selectedVehicle = v),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildServicesStep() {
    return ListView(
      children: [
        const Text('Chọn dịch vụ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (_quickServices.isNotEmpty) ...[
          const Text('Dịch vụ nhanh', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ..._quickServices.map(_buildServiceTile),
          const SizedBox(height: 12),
        ],
        if (_repairServices.isNotEmpty) ...[
          const Text('Dịch vụ sửa chữa', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ..._repairServices.map(_buildServiceTile),
        ],
      ],
    );
  }

  Widget _buildServiceTile(ServiceItem s) {
    final selected = _selectedServiceIds.contains(s.id);
    return Card(
      child: CheckboxListTile(
        value: selected,
        onChanged: (_) {
          setState(() {
            if (selected) {
              _selectedServiceIds.remove(s.id);
            } else {
              _selectedServiceIds.add(s.id);
            }
          });
        },
        title: Text(s.name),
        subtitle: Text(
          '${s.description ?? ''}'
              '${s.basePrice != null ? ' · ${s.basePrice!.toStringAsFixed(0)}đ' : ''}'
              '${s.defaultDurationMin != null ? ' · ~${s.defaultDurationMin}\' ' : ''}',
        ),
      ),
    );
  }

  Widget _buildMechanicStep() {
    return ListView(
      children: [
        const Text('Chọn thợ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        RadioListTile<_MechanicMode>(
          value: _MechanicMode.any,
          groupValue: _mechanicMode,
          onChanged: (v) => setState(() {
            _mechanicMode = v!;
            _selectedMechanic = null;
          }),
          title: const Text('Thợ bất kỳ'),
        ),
        RadioListTile<_MechanicMode>(
          value: _MechanicMode.specific,
          groupValue: _mechanicMode,
          onChanged: (v) => setState(() => _mechanicMode = v!),
          title: const Text('Chọn thợ cụ thể'),
        ),
        if (_mechanicMode == _MechanicMode.specific) ...[
          const SizedBox(height: 8),
          ..._mechanics.map((m) {
            final selected = _selectedMechanic?.id == m.id;
            return Card(
              child: ListTile(
                leading: const Icon(Icons.engineering),
                title: Text(m.name),
                subtitle: Text([
                  if (m.phone != null) m.phone,
                  if (m.skillTags != null) 'Kỹ năng: ${m.skillTags}',
                ].whereType<String>().join(' · ')),
                trailing:
                selected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                onTap: () => setState(() => _selectedMechanic = m),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildTimeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Chọn ngày & giờ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Ngày: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: _pickDate,
              child: const Text('Đổi ngày'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _slots.isEmpty
              ? const Center(child: Text('Không có slot phù hợp trong ngày này'))
              : ListView.builder(
            itemCount: _slots.length,
            itemBuilder: (_, i) {
              final slot = _slots[i];
              final selected = _selectedSlot == slot;
              return Card(
                child: ListTile(
                  title: Text(slot.timeRangeLabel),
                  subtitle: Text('Số thợ rảnh: ${slot.freeMechanicIds.length}'),
                  trailing: selected
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () => setState(() => _selectedSlot = slot),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmStep() {
    final selectedServices = _services
        .where((s) => _selectedServiceIds.contains(s.id))
        .toList();
    return ListView(
      children: [
        const Text('Xác nhận đặt lịch',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListTile(
          title: const Text('Xe'),
          subtitle: Text(
              '${_selectedVehicle?.plateNo} · ${_selectedVehicle?.brand ?? ''} ${_selectedVehicle?.model ?? ''}'),
        ),
        const Divider(),
        ListTile(
          title: const Text('Dịch vụ'),
          subtitle: Text(selectedServices.map((e) => e.name).join('\n')),
        ),
        const Divider(),
        ListTile(
          title: const Text('Thợ'),
          subtitle: Text(_mechanicMode == _MechanicMode.any
              ? 'Thợ bất kỳ'
              : (_selectedMechanic?.name ?? 'Chưa chọn')),
        ),
        const Divider(),
        ListTile(
          title: const Text('Thời gian'),
          subtitle: Text(_selectedSlot?.timeRangeLabel ?? ''),
        ),
        const Divider(),
        TextField(
          controller: _noteCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Ghi chú cho cửa hàng',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
