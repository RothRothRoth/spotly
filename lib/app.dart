import 'package:flutter/material.dart';
import 'screens/dashboard/dashboard.dart';
import 'screens/dashboard/map.dart';
import 'screens/dashboard/review.dart';
import 'screens/dashboard/profile.dart';

class AppNavigation {
  static Map<String, Widget Function(BuildContext)> routes() {
    return {
      '/dashboard': (context) => const DashboardScreen(),
      '/map': (context) => const MapScreen(),
      '/review': (context) => const ReviewScreen(),
      '/profile': (context) => const ProfileScreen(),
    };
  }

  static const String initial = '/dashboard';
}
