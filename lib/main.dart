import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'models/note_model.dart';
import 'providers/note_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => NoteProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Silent Cache',
      theme: ThemeData(
        // Obsidian-inspired dark theme
        primaryColor: const Color(0xFF7A6BFF), // Obsidian purple accent
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7A6BFF), // Purple accent
          secondary: Color(0xFF7A6BFF),
          surface: Color(0xFF1E1E1E), // Dark background
          background: Color(0xFF15151B), // Darker background
          onBackground: Colors.white70,
        ),
        scaffoldBackgroundColor:
            const Color(0xFF15151B), // Obsidian dark background
        appBarTheme: const AppBarTheme(
          backgroundColor:
              Color(0xFF1C1C22), // Slightly lighter than background
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF7A6BFF)),
          titleTextStyle: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
          bodyLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1C1C22),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF7A6BFF)),
        dividerTheme: const DividerThemeData(color: Color(0xFF333340)),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF7A6BFF),
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
