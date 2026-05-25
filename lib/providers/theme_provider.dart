import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  ThemeData get currentTheme => _isDarkMode ? _darkTheme : _lightTheme;

  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFEFEBE4), // Premium beige
    cardColor: Colors.white,
    primaryColor: const Color(0xFF383838),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF2E2C2A)),
      bodyMedium: TextStyle(color: Color(0xFF2E2C2A)),
      bodySmall: TextStyle(color: Color(0xFF7A7774)),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF2E2C2A)),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFEFEBE4),
      iconTheme: IconThemeData(color: Color(0xFF2E2C2A)),
      titleTextStyle: TextStyle(color: Color(0xFF2E2C2A), fontSize: 20, fontWeight: FontWeight.bold),
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF1E1E1E), // Sleek dark charcoal
    cardColor: const Color(0xFF2A2A2A),
    primaryColor: Colors.white,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      bodySmall: TextStyle(color: Colors.white60),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
  );
}
