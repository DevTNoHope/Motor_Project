import 'package:app_motor/core/auth_guard.dart';
import 'package:app_motor/views/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/role.dart';
import '../views/auth/login_screen.dart';
import '../views/booking/booking_flow_screen.dart';

import '../views/home/home_screen.dart';
import '../views/mechanic/mechanic_home_screen.dart';
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
  ],
);
