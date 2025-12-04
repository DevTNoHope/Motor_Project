import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../services/mechanic_stats_service.dart';

class MechanicStatsTab extends StatefulWidget {
  const MechanicStatsTab({super.key});

  @override
  State<MechanicStatsTab> createState() => _MechanicStatsTabState();
}

class _MechanicStatsTabState extends State<MechanicStatsTab> {
  final _service = MechanicStatsService();
  bool _loading = true;
  Map<String, dynamic>? _data;
  String _groupBy = 'week';
  DateTimeRange? _range;

  @override
  void initState() {
    super.initState();
    _range = DateTimeRange(
      start: DateTime(DateTime.now().year, DateTime.now().month, 1),
      end: DateTime.now(),
    );
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getStats(
        from: _range!.start,
        to: _range!.end,
        groupBy: _groupBy,
      );
      setState(() => _data = data);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi tải thống kê: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  String _formatMoney(num? v) =>
      v == null ? '0' : NumberFormat('#,##0', 'vi_VN').format(v);

  num _parseNum(dynamic v) {
    if (v is num) return v;
    if (v is String) {
      return num.tryParse(v.replaceAll(',', '').trim()) ?? 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final overview = _data?['overview'] ?? {};
    final timeline = (_data?['timeline'] ?? []) as List;
    final topServices = (_data?['topServices'] ?? []) as List;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê thợ sửa xe'),
        actions: [
          IconButton(onPressed: _fetchStats, icon: const Icon(Icons.refresh))
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchStats,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 🔹 Bộ chọn ngày
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2024, 1, 1),
                      lastDate: DateTime(2030, 12, 31),
                      initialDateRange: _range,
                    );
                    if (picked != null) {
                      setState(() => _range = picked);
                      _fetchStats();
                    }
                  },
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    '${DateFormat('dd/MM/yyyy').format(_range!.start)} → ${DateFormat('dd/MM/yyyy').format(_range!.end)}',
                  ),
                ),
                DropdownButton<String>(
                  value: _groupBy,
                  items: const [
                    DropdownMenuItem(value: 'day', child: Text('Theo ngày')),
                    DropdownMenuItem(value: 'week', child: Text('Theo tuần')),
                    DropdownMenuItem(value: 'month', child: Text('Theo tháng')),
                  ],
                  onChanged: (v) {
                    setState(() => _groupBy = v!);
                    _fetchStats();
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 🔹 Tổng quan
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _statCard(
                  title: 'Tổng số đơn',
                  value: '${overview['totalBookings'] ?? 0}',
                  color: Colors.blue,
                  icon: Icons.list_alt_rounded,
                ),
                _statCard(
                  title: 'Đơn hoàn thành',
                  value: '${overview['completedBookings'] ?? 0}',
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
                _statCard(
                  title: 'Tổng doanh thu',
                  value: '${_formatMoney(_parseNum(overview['totalRevenue']))}đ',
                  color: Colors.orange,
                  icon: Icons.monetization_on,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 🔹 Biểu đồ doanh thu theo thời gian
            if (timeline.isNotEmpty) ...[
              const Text(
                'Doanh thu theo thời gian',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= timeline.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                timeline[i]['period'].toString(),
                                style: const TextStyle(fontSize: 9),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: Colors.blueAccent,
                        dotData: FlDotData(show: false),
                        spots: List.generate(
                          timeline.length,
                              (i) {
                            final raw = timeline[i]['revenue'];
                            final value = (raw is num)
                                ? raw.toDouble()
                                : double.tryParse(raw?.toString() ?? '0') ?? 0.0;
                            return FlSpot(i.toDouble(), value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else
              const Text('Chưa có dữ liệu doanh thu.'),

            const SizedBox(height: 24),

            // 🔹 Top dịch vụ
            if (topServices.isNotEmpty) ...[
              const Text(
                'Top 5 dịch vụ nhiều nhất',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...topServices.map((s) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.build_circle),
                    title: Text(s['name']),
                    trailing: Text('x${s['total']}'),
                  ),
                );
              }),
            ] else
              const Text('Chưa có dịch vụ nào được thực hiện.'),
          ],
        ),
      ),
    );
  }

  // 🔸 Widget thẻ thống kê
  Widget _statCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: (MediaQuery.of(context).size.width - 60) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title,
              style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                  fontSize: 13)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
