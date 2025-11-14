import 'package:flutter/material.dart';
import 'tabs/mechanic_schedule_tab.dart';
import 'tabs/mechanic_diagnosis_page.dart';
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
              ? 'Lịch làm việc hôm nay'
              : _selectedIndex == 1
              ? 'Đánh giá tình trạng xe'
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
        ],
      ),
    );
  }
}
