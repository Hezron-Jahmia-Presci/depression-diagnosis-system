import 'dart:async';
import 'package:flutter/material.dart';

import 'package:depression_diagnosis_system/service/lib/theme_service.dart';
import 'screen/auth/login_home_screen.dart' show LoginHomeScreen;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isDarkMode = await ThemeService().isDarkMode();
  runApp(MyApp(isDarkMode: isDarkMode));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  const MyApp({super.key, required this.isDarkMode});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late bool _isDarkMode;
  final ThemeService _themeService = ThemeService();

  static const Color _seedColor = Colors.greenAccent;

  static ColorScheme _getColorScheme(bool isDark) {
    return ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );
  }

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  void _toggleTheme() async {
    setState(() => _isDarkMode = !_isDarkMode);
    await _themeService.setDarkMode(_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: _getColorScheme(false),
        fontFamily: 'SFPro',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: _getColorScheme(true),
        fontFamily: 'SFPro',
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      onGenerateRoute: (settings) {
        if (settings.name == '/loginHome') {
          return MaterialPageRoute(
            builder: (context) => LoginHomeScreen(toggleTheme: _toggleTheme),
          );
        }
        return null;
      },
      home: SplashScreen(), // No toggle passed here
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 4), () {
      Navigator.pushNamed(context, '/loginHome');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          height: 430, // adjust height as needed
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
