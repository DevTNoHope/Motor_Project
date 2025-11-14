import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/mechanic_booking_service.dart';
import '../../../utils/formatters.dart'; // dùng để hiển thị giờ

class MechanicScheduleTab extends StatefulWidget {
  const MechanicScheduleTab({super.key});

  @override
  State<MechanicScheduleTab> createState() => _MechanicScheduleTabState();
}

class _MechanicScheduleTabState extends State<MechanicScheduleTab> {
  final _service = MechanicBookingService();
  bool _loading = true;
  List<dynamic> _bookings = [];

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getBookingsByDate(_selectedDate);
      setState(() {
        _bookings = data;
      });
    } catch (e) {
      debugPrint('Lỗi khi tải lịch làm: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không tải được lịch: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleStart(int id) async {
    try {
      await _service.startBooking(id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bắt đầu sửa chữa ✅')));
      _fetchBookings();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi bắt đầu: $e')));
    }
  }

  Future<void> _handleComplete(int id) async {
    try {
      await _service.completeBooking(id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Hoàn thành sửa chữa ✅')));
      _fetchBookings();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi hoàn thành: $e')));
    }
  }

  String _statusText(String? code) {
    switch (code) {
      case 'APPROVED':
        return 'Chưa bắt đầu';
      case 'IN_PROGRESS':
        return 'Đang sửa chữa';
      case 'DONE':
        return 'Đã sửa chữa';
      default:
        return code ?? '';
    }
  }

  Color _statusColor(String? code) {
    switch (code) {
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'DONE':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tomorrow = _selectedDate.add(const Duration(days: 1));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch làm việc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchBookings,
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔹 Nút chọn ngày
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ToggleButtons(
              isSelected: [
                _selectedDate.day == DateTime.now().day,
                _selectedDate.day == tomorrow.day,
              ],
              onPressed: (i) {
                setState(() {
                  _selectedDate = i == 0
                      ? DateTime.now()
                      : DateTime.now().add(const Duration(days: 1));
                });
                _fetchBookings();
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Hôm nay'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Ngày mai'),
                ),
              ],
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _bookings.isEmpty
                ? const Center(child: Text('Không có lịch nào cho ngày này.'))
                : RefreshIndicator(
              onRefresh: _fetchBookings,
              child: ListView.builder(
                itemCount: _bookings.length,
                itemBuilder: (context, i) {
                  final b = _bookings[i];
                  final start = DateTime.parse(b['start_dt']);
                  final end = DateTime.parse(b['end_dt']);
                  final services = (b['service_types'] as List?) ?? [];

                  final hasRepair = services.contains('REPAIR');
                  final status = b['status'];

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ExpansionTile(
                      leading: const Icon(Icons.schedule),
                      title: Text(
                        '${formatTime(start)} - ${formatTime(end)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _statusText(status),
                            style: TextStyle(
                              color: _statusColor(status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text('Khách: ${b['user']?['name'] ?? '---'}'),
                          Text(
                            'Xe: ${b['vehicle']?['brand'] ?? ''} ${b['vehicle']?['model'] ?? ''} (${b['vehicle']?['plate_no'] ?? ''})',
                          ),
                        ],
                      ),

                      // 🔧 Đây là phần đã được cập nhật logic
                      children: [
                        if (hasRepair) ...[
                          // ✅ Nếu có REPAIR (kể cả có QUICK)
                          if (status == 'APPROVED') ...[
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  context.push(
                                    '/mechanic/diagnosis',
                                    extra: b,
                                  ).then((result) {
                                    if (result == true) _fetchBookings();
                                  });
                                },
                                icon: const Icon(Icons.assignment),
                                label: const Text('Tạo phiếu đánh giá xe'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  foregroundColor: Colors.black,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                '⚠️ Vui lòng tạo phiếu đánh giá trước khi bắt đầu sửa chữa',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ] else if (status == 'IN_DIAGNOSIS' ||
                              status == 'IN_PROGRESS' ||
                              status == 'DONE') ...[
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: status == 'IN_DIAGNOSIS'
                                      ? () => _handleStart(b['id'])
                                      : null,
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text('Bắt đầu'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: status == 'IN_PROGRESS'
                                      ? () => _handleComplete(b['id'])
                                      : null,
                                  icon: const Icon(Icons.done),
                                  label: const Text('Hoàn thành'),
                                ),
                              ],
                            ),
                          ],
                        ] else ...[
                          // ✅ Chỉ có QUICK -> làm bình thường
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: status == 'APPROVED'
                                    ? () => _handleStart(b['id'])
                                    : null,
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Bắt đầu'),
                              ),
                              ElevatedButton.icon(
                                onPressed: status == 'IN_PROGRESS'
                                    ? () => _handleComplete(b['id'])
                                    : null,
                                icon: const Icon(Icons.done),
                                label: const Text('Hoàn thành'),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
