import 'package:flutter/material.dart';
import 'dart:async';

import 'screen/auth/login_home_screen.dart' show LoginHomeScreen;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color _seedColor = Colors.greenAccent;
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
      routes: {'/loginHome': (context) => LoginHomeScreen()},
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
