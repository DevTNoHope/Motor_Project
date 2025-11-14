import 'package:app_motor/views/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/auth/login_screen.dart';
import '../views/home/home_screen.dart';
import '../views/booking/booking_flow_screen.dart';
import '../views/mechanic/mechanic_home_screen.dart';
import '../views/mechanic/tabs/mechanic_diagnosis_page.dart';
import '../views/vehicle/vehicle_list_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/vehicles', builder: (_, __) => const VehicleListScreen()),
    GoRoute(path: '/booking', builder: (_, __) => const BookingFlowScreen()),
    GoRoute(path: '/mechanic', builder: (_, __) => const MechanicHomeScreen()),
  //  GoRoute(path: '/mechanic/diagnosis', builder: (_, __) => const MechanicDiagnosisPage()),
    GoRoute(
      path: '/mechanic/diagnosis',
      builder: (_, state) {
        final booking = state.extra as Map?;
        return MechanicDiagnosisPage(booking: booking);
      },
    ),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen())
  ],
);
