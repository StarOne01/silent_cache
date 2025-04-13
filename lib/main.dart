import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:silent_cache/screens/diary_screen.dart';
import 'package:silent_cache/screens/tasks_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/task_provider.dart';
import 'providers/note_provider.dart';
import 'screens/home_screen.dart';
import 'widgets/custom_nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Silent Cache',
      debugShowCheckedModeBanner: false,
      theme: _buildSciFiTheme(),
      darkTheme: _buildSciFiTheme(isDark: true),
      themeMode: ThemeMode.dark, // Default to dark theme for sci-fi feel
      home: const MainScreen(),
    );
  }

  ThemeData _buildSciFiTheme({bool isDark = true}) {
    // Sci-fi inspired color palette
    final primary = const Color(0xFF00E5FF); // Cyan for holographic feel
    final secondary = const Color(0xFF7A6BFF); // Purple for energy/tech feel
    final background = isDark
        ? const Color(0xFF0A0E18) // Dark deep space blue
        : const Color(0xFF1A2035); // Slightly lighter blue
    final surface = isDark
        ? const Color(0xFF111827) // Dark slate
        : const Color(0xFF212B45); // Medium slate
    final error = const Color(0xFFFF5252); // Neon red for errors

    final ColorScheme colorScheme = ColorScheme(
      primary: primary,
      secondary: secondary,
      surface: surface,
      background: background,
      error: error,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: isDark ? Colors.white : Colors.white.withOpacity(0.87),
      onBackground: isDark ? Colors.white : Colors.white.withOpacity(0.87),
      onError: Colors.white,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: primary),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primary.withOpacity(0.2), width: 1),
        ),
        shadowColor: primary.withOpacity(0.3),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: colorScheme.onBackground),
        displayMedium: TextStyle(color: colorScheme.onBackground),
        displaySmall: TextStyle(color: colorScheme.onBackground),
        headlineMedium: TextStyle(color: colorScheme.onBackground),
        headlineSmall: TextStyle(color: colorScheme.onBackground),
        titleLarge: TextStyle(color: colorScheme.onBackground),
        bodyLarge: TextStyle(color: colorScheme.onBackground.withOpacity(0.9)),
        bodyMedium: TextStyle(color: colorScheme.onBackground.withOpacity(0.9)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primary),
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        buttonColor: primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          shadowColor: primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: primary.withOpacity(0.2),
        thickness: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface.withOpacity(0.8),
        indicatorColor: primary.withOpacity(0.2),
        labelTextStyle: MaterialStateProperty.all(
          TextStyle(color: colorScheme.onSurface, fontSize: 12),
        ),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return IconThemeData(color: primary);
          }
          return IconThemeData(color: colorScheme.onSurface.withOpacity(0.7));
        }),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 4;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DiaryScreen(),
    const Scaffold(), // Camera placeholder
    const TasksScreen(),
    const Scaffold(body: Center(child: Text('Settings')))
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: IndexedStack(
        index: _currentIndex >= 0 && _currentIndex < _screens.length
            ? _currentIndex
            : 0,
        children: _screens,
      ),
      extendBody: true,
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index >= 0 && index < _screens.length) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }
}
