import 'package:flutter/material.dart';
import 'dart:async';

import 'screen/auth/login_screen.dart' show LoginScreen;
import 'screen/auth/register_screen.dart' show RegisterScreen;
import 'screen/home/home_screen.dart' show HomeScreen;
import 'screen/home/psychiatrist_screens/psychiatrist_details_screen.dart'
    show PsychiatristDetailsScreen;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color _seedColor = Colors.blue;
  static const bool _isDarkMode = false;

  static ColorScheme lightColorScheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.light,
  );

  static ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.dark,
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/psychDashboard': (context) => HomeScreen(),
        '/psychProfile': (context) => PsychiatristDetailsScreen(),
      },
      debugShowCheckedModeBanner: false,

      theme: ThemeData(useMaterial3: true, colorScheme: MyApp.lightColorScheme),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: MyApp.darkColorScheme,
      ),
      themeMode: MyApp._isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
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
      Navigator.pushNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: Center(
        child: Text(
          'DDS',
          style: TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
