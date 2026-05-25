import 'package:flutter/material.dart';
import 'screens/dashboard/dashboard.dart';
import 'screens/dashboard/map.dart';
import 'screens/dashboard/browse.dart';
import 'screens/dashboard/profile.dart';

class AppNavigation {
  static Map<String, Widget Function(BuildContext)> routes() {
    return {
      '/dashboard': (context) => const DashboardScreen(),
      '/map': (context) => const MapScreen(),
      '/browse': (context) => const BrowseScreen(),
      '/profile': (context) => const ProfileScreen(),
    };
  }

  static const String initial = '/dashboard';
}
