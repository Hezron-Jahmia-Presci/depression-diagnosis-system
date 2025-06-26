// lib/layout/app_layout.dart

import 'package:flutter/material.dart';
import 'package:frontend/constants/layout_constant.dart'
    show kDesktopBreakpoint;

import '../screen/screens_exporter.dart';
import '../service/psychiatrist_service.dart' show PsychiatristService;
import 'lob/desktop_layout.dart' show DesktopLayout;
import 'lob/mobile_layout.dart' show MobileLayout;

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  final _psychiatristService = PsychiatristService();
  final _screens = [DashboardScreen(), PatientScreen(), SessionScreen()];

  int _selectedIndex = 0;
  Map<String, dynamic>? _psychiatristDetails;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchPsychiatristDetails();
  }

  Future<void> _fetchPsychiatristDetails() async {
    try {
      final details = await _psychiatristService.getPsychiatristDetails();
      setState(() {
        _psychiatristDetails = details;
        _hasError = details == null;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _onNavTap(int index) => setState(() => _selectedIndex = index);

  void _navigateTo(Widget screen) {
    final index = _screens.indexWhere(
      (s) => s.runtimeType == screen.runtimeType,
    );
    if (index != -1) {
      setState(() => _selectedIndex = index);
    }
  }

  Future<void> _handleLogout() async {
    final loggedOut = await _psychiatristService.logoutPsychiatrist();
    if (loggedOut && mounted) {
      Navigator.pushReplacementNamed(context, '/loginHome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobileOrTablet = constraints.maxWidth < kDesktopBreakpoint;

        return isMobileOrTablet
            ? MobileLayout(
              selectedIndex: _selectedIndex,
              onNavTap: _onNavTap,
              screen: _screens[_selectedIndex],
            )
            : DesktopLayout(
              primaryScreen: _screens[_selectedIndex],
              onItemSelected: _onNavTap,
              colorScheme: Theme.of(context).colorScheme,
              psychiatristDetails: _psychiatristDetails,
              isLoading: _isLoading,
              hasError: _hasError,
              onLogout: _handleLogout,
            );
      },
    );
  }
}
