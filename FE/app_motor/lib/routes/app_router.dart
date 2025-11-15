import 'package:app_motor/core/auth_guard.dart';
import 'package:app_motor/views/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/booking.dart';
import '../models/role.dart';
import '../views/auth/login_screen.dart';
import '../views/booking/booking_detail_screen.dart';
import '../views/booking/booking_diagnosis_screen.dart';
import '../views/booking/booking_flow_screen.dart';

import '../views/booking/booking_history_screen.dart';
import '../views/home/home_screen.dart';
import '../views/mechanic/mechanic_home_screen.dart';
import '../views/mechanic/tabs/mechanic_diagnosis_page.dart';
import '../views/vehicle/vehicle_list_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/vehicles', builder: (_, __) => const VehicleListScreen()),
    GoRoute(path: '/mechanic', builder: (_, __) => const MechanicHomeScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(
      path: '/booking',
      builder: (_, __) => AuthGate(
        allowed: const {AppRole.user},
        redirectWhenDenied: '/mechanic',
        child: const BookingFlowScreen(),
      ),
    ),
    GoRoute(
      path: '/booking-history',
      builder: (_, __) => const BookingHistoryScreen(),
    ),
    GoRoute(
      path: '/booking-history/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return BookingDetailScreen(bookingId: id);
      },
    ),
    GoRoute(
      path: '/booking-diagnosis',
      builder: (context, state) {
        final booking = state.extra as Booking;
        return BookingDiagnosisScreen(booking: booking);
      },
    ),
  //  GoRoute(path: '/mechanic/diagnosis', builder: (_, __) => const MechanicDiagnosisPage()),
    GoRoute(
      path: '/mechanic/diagnosis',
      builder: (_, state) {
        final booking = state.extra as Map?;
        return MechanicDiagnosisPage(booking: booking);
      },
    ),
  ],
);
