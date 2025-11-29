import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/mechanic_booking_service.dart';
import '../../../utils/formatters.dart';

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

  // Bộ lọc trạng thái
  String? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    _selectedStatusFilter = 'APPROVED'; // Đảm bảo filter được set
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getBookingsByDate(_selectedDate);
      setState(() {
        _bookings = data;
      });
      debugPrint('Fetched ${_bookings.length} bookings, filter: $_selectedStatusFilter');
    } catch (e) {
      debugPrint('Lỗi khi tải lịch làm: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Không tải được lịch: $e')),
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

  Future<void> _handleStart(int id) async {
    try {
      await _service.startBooking(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Bắt đầu sửa chữa ✅'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      _fetchBookings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Lỗi khi bắt đầu: $e')),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _handleComplete(int id) async {
    try {
      await _service.completeBooking(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Hoàn thành sửa chữa ✅'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      _fetchBookings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Lỗi khi hoàn thành: $e')),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  String _statusText(String? code) {
    switch (code) {
      case 'APPROVED':
        return 'Chưa bắt đầu';
      case 'IN_DIAGNOSIS':
        return 'Đã đánh giá';
      case 'IN_PROGRESS':
        return 'Đang sửa chữa';
      case 'DONE':
        return 'Đã hoàn thành';
      default:
        return code ?? '';
    }
  }

  Color _statusColor(String? code) {
    switch (code) {
      case 'APPROVED':
        return Colors.blue;
      case 'IN_DIAGNOSIS':
        return Colors.amber;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'DONE':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String? code) {
    switch (code) {
      case 'APPROVED':
        return Icons.schedule;
      case 'IN_DIAGNOSIS':
        return Icons.assignment;
      case 'IN_PROGRESS':
        return Icons.build_circle;
      case 'DONE':
        return Icons.check_circle;
      default:
        return Icons.info_outline;
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  bool get _hasActiveBooking {
    return _bookings.any((b) =>
    b['status'] == 'IN_DIAGNOSIS' || b['status'] == 'IN_PROGRESS'
    );
  }

  Map<String, dynamic>? get _activeBooking {
    try {
      return _bookings.firstWhere((b) =>
      b['status'] == 'IN_DIAGNOSIS' || b['status'] == 'IN_PROGRESS'
      );
    } catch (e) {
      return null;
    }
  }

  List<dynamic> get _filteredBookings {
    if (_selectedStatusFilter == null) return _bookings;
    final filtered = _bookings.where((b) => b['status'] == _selectedStatusFilter).toList();
    debugPrint('Filtered: ${filtered.length} bookings with status $_selectedStatusFilter');
    return filtered;
  }

  Map<String, int> get _statusCounts {
    final counts = <String, int>{};
    for (var b in _bookings) {
      final status = b['status'] as String?;
      if (status != null) {
        counts[status] = (counts[status] ?? 0) + 1;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(_selectedDate);
    final counts = _statusCounts;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          // Date Picker Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2024, 1, 1),
                            lastDate: DateTime(2030, 12, 31),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: Colors.blue.shade600,
                                    onPrimary: Colors.white,
                                    surface: Colors.white,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedDate = picked;
                              _selectedStatusFilter = null;
                            });
                            _fetchBookings();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade600, Colors.blue.shade500],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade300.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.calendar_today_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isToday ? 'Hôm nay' : 'Ngày đã chọn',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _fetchBookings,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.refresh_rounded,
                          color: Colors.grey.shade700,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Status Filter Chips
          if (!_loading && _bookings.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.filter_list_rounded, size: 18, color: Colors.grey.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Lọc theo trạng thái',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedStatusFilter != null)
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedStatusFilter = null;
                            });
                          },
                          icon: const Icon(Icons.clear, size: 14),
                          label: const Text('Xóa', style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: const Size(0, 28),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          'Chưa bắt đầu',
                          'APPROVED',
                          Colors.blue,
                          Icons.schedule,
                          counts['APPROVED'] ?? 0,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Đã đánh giá',
                          'IN_DIAGNOSIS',
                          Colors.amber,
                          Icons.assignment,
                          counts['IN_DIAGNOSIS'] ?? 0,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Đang sửa',
                          'IN_PROGRESS',
                          Colors.orange,
                          Icons.build_circle,
                          counts['IN_PROGRESS'] ?? 0,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Hoàn thành',
                          'DONE',
                          Colors.green,
                          Icons.check_circle,
                          counts['DONE'] ?? 0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Bookings List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _bookings.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy_rounded, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Không có lịch nào cho ngày này.',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
                : _filteredBookings.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.filter_alt_off_rounded, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Không có lịch nào với trạng thái này.',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _fetchBookings,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredBookings.length,
                itemBuilder: (context, i) {
                  final b = _filteredBookings[i];
                  final start = DateTime.parse(b['start_dt']);
                  final end = DateTime.parse(b['end_dt']);
                  final services = (b['service_types'] as List?) ?? [];
                  final hasRepair = services.contains('REPAIR');
                  final status = b['status'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _statusColor(status).withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _statusColor(status).withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _statusColor(status),
                                _statusColor(status).withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: _statusColor(status).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _statusIcon(status),
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        title: Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 18, color: Colors.grey.shade600),
                            const SizedBox(width: 8),
                            Text(
                              '${formatTime(start)} - ${formatTime(end)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _statusColor(status).withOpacity(0.2),
                                      _statusColor(status).withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _statusColor(status).withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _statusIcon(status),
                                      size: 14,
                                      color: _statusColor(status),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _statusText(status),
                                      style: TextStyle(
                                        color: _statusColor(status),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.person_rounded, size: 16, color: Colors.blue.shade700),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      b['user']?['name'] ?? '---',
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.directions_car_rounded, size: 16, color: Colors.green.shade700),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${b['vehicle']?['brand'] ?? ''} ${b['vehicle']?['model'] ?? ''} (${b['vehicle']?['plate_no'] ?? ''})',
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        children: [
                          const Divider(height: 24),
                          if (hasRepair) ...[
                            if (status == 'APPROVED') ...[
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: isToday && !_hasActiveBooking
                                      ? () {
                                    context.push('/mechanic/diagnosis', extra: b).then((result) {
                                      if (result == true) _fetchBookings();
                                    });
                                  }
                                      : null,
                                  icon: const Icon(Icons.assignment_rounded),
                                  label: const Text(
                                    'Tạo phiếu đánh giá xe',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber.shade600,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.grey.shade300,
                                    elevation: isToday && !_hasActiveBooking ? 2 : 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (_hasActiveBooking) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.red.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.block_rounded, color: Colors.red.shade700, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Bạn chưa hoàn thành đơn cũ',
                                              style: TextStyle(
                                                color: Colors.red.shade900,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Hoàn thành xe ${_activeBooking?['vehicle']?['plate_no'] ?? '---'} trước',
                                              style: TextStyle(
                                                color: Colors.red.shade800,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.amber.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline_rounded, color: Colors.amber.shade700, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Phải tạo phiếu đánh giá trước khi bắt đầu sửa chữa',
                                          style: TextStyle(
                                            color: Colors.amber.shade900,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ] else if (status == 'IN_DIAGNOSIS' ||
                                status == 'IN_PROGRESS' ||
                                status == 'DONE') ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 48,
                                      child: ElevatedButton.icon(
                                        onPressed: isToday && status == 'IN_DIAGNOSIS'
                                            ? () => _handleStart(b['id'])
                                            : null,
                                        icon: const Icon(Icons.play_arrow_rounded),
                                        label: const Text(
                                          'Bắt đầu',
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green.shade600,
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor: Colors.grey.shade300,
                                          elevation: isToday && status == 'IN_DIAGNOSIS' ? 2 : 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: SizedBox(
                                      height: 48,
                                      child: ElevatedButton.icon(
                                        onPressed: isToday && status == 'IN_PROGRESS'
                                            ? () => _handleComplete(b['id'])
                                            : null,
                                        icon: const Icon(Icons.done_rounded),
                                        label: const Text(
                                          'Hoàn thành',
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue.shade600,
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor: Colors.grey.shade300,
                                          elevation: isToday && status == 'IN_PROGRESS' ? 2 : 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ] else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      onPressed: isToday && status == 'APPROVED' && !_hasActiveBooking
                                          ? () => _handleStart(b['id'])
                                          : null,
                                      icon: const Icon(Icons.play_arrow_rounded),
                                      label: const Text(
                                        'Bắt đầu',
                                        style: TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade600,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: Colors.grey.shade300,
                                        elevation: isToday && status == 'APPROVED' && !_hasActiveBooking ? 2 : 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      onPressed: isToday && status == 'IN_PROGRESS'
                                          ? () => _handleComplete(b['id'])
                                          : null,
                                      icon: const Icon(Icons.done_rounded),
                                      label: const Text(
                                        'Hoàn thành',
                                        style: TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade600,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: Colors.grey.shade300,
                                        elevation: isToday && status == 'IN_PROGRESS' ? 2 : 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_hasActiveBooking && status == 'APPROVED') ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.block_rounded, color: Colors.red.shade700, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Bạn chưa hoàn thành đơn cũ',
                                            style: TextStyle(
                                              color: Colors.red.shade900,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Hoàn thành xe ${_activeBooking?['vehicle']?['plate_no'] ?? '---'} trước',
                                            style: TextStyle(
                                              color: Colors.red.shade800,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
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

  Widget _buildFilterChip(String label, String status, Color color, IconData icon, int count) {
    final isSelected = _selectedStatusFilter == status;

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : color,
          ),
          const SizedBox(width: 6),
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.3) : color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ),
          ],
        ],
      ),
      onSelected: (selected) {
        setState(() {
          _selectedStatusFilter = selected ? status : null;
        });
      },
      selectedColor: color,
      checkmarkColor: Colors.white,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? color : color.withOpacity(0.3),
        width: 1.5,
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : color,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: isSelected ? 4 : 0,
      shadowColor: color.withOpacity(0.4),
    );
  }
}