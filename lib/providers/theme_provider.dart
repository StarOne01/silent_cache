import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccentOption {
  final String id;
  final String name;
  final Color color;

  AccentOption({
    required this.id,
    required this.name,
    required this.color,
  });
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  String _accentId = 'blue';
  late SharedPreferences _prefs;

  // List of available accent colors
  final List<AccentOption> accentOptions = [
    AccentOption(
      id: 'blue',
      name: 'Blue',
      color: Colors.blue,
    ),
    AccentOption(
      id: 'purple',
      name: 'Purple',
      color: Colors.purple,
    ),
    AccentOption(
      id: 'pink',
      name: 'Pink',
      color: Color(0xFFF06292),
    ),
    AccentOption(
      id: 'teal',
      name: 'Teal',
      color: Colors.teal,
    ),
    AccentOption(
      id: 'amber',
      name: 'Amber',
      color: Colors.amber,
    ),
    AccentOption(
      id: 'indigo',
      name: 'Indigo',
      color: Colors.indigo,
    ),
    AccentOption(
      id: 'red',
      name: 'Red',
      color: Colors.red,
    ),
    AccentOption(
      id: 'green',
      name: 'Green',
      color: Colors.green,
    ),
  ];

  ThemeProvider() {
    _loadPreferences();
  }

  bool get isDarkMode => _isDarkMode;
  String get accentId => _accentId;

  // Load theme and accent color preferences
  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    _accentId = _prefs.getString('accentId') ?? 'blue';
    notifyListeners();
  }

  // Toggle between light and dark themes
  void toggleThemeMode() {
    _isDarkMode = !_isDarkMode;
    _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  // Change accent color
  void setAccentColor(String id) {
    if (_accentId != id) {
      _accentId = id;
      _prefs.setString('accentId', id);
      notifyListeners();
    }
  }

  // Get current theme data
  ThemeData getTheme() {
    final Color accentColor =
        accentOptions.firstWhere((accent) => accent.id == _accentId).color;

    if (_isDarkMode) {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: accentColor,
          secondary: accentColor,
          surface: const Color(0xFF1E1E1E),
          background: const Color(0xFF121212),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1E1E1E),
          elevation: 0,
          iconTheme: IconThemeData(color: accentColor),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF2A2A2A),
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: accentColor.withOpacity(0.3),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      );
    } else {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: accentColor,
          secondary: accentColor,
          surface: Colors.white,
          background: const Color(0xFFF5F5F5),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: accentColor),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: accentColor.withOpacity(0.3),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      );
    }
  }
}
