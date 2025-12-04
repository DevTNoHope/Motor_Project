import 'package:app_motor/views/mechanic/tabs/mechanic_stats_tab.dart';
import 'package:flutter/material.dart';
import 'tabs/mechanic_schedule_tab.dart';
import 'tabs/mechanic_profile_tab.dart';

class MechanicHomeScreen extends StatefulWidget {
  const MechanicHomeScreen({super.key});

  @override
  State<MechanicHomeScreen> createState() => _MechanicHomeScreenState();
}

class _MechanicHomeScreenState extends State<MechanicHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    MechanicScheduleTab(),
    MechanicProfileTab(),
    MechanicStatsTab(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Lịch làm việc '
              : 'Hồ sơ cá nhân',
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Lịch làm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Thống kê"),
        ],
      ),
    );
  }
}
