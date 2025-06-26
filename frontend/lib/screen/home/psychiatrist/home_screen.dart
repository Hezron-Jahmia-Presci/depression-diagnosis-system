import 'package:flutter/material.dart';

import '../../../layout/lob/desktop_layout.dart' show DesktopLayout;
import '../../../service/psychiatrist_service.dart';
import '../../../constants/layout_constant.dart' show kDesktopBreakpoint;
import 'dashboard_screen.dart';
import 'patient_screens/patient_screen.dart';
import 'session_screens/session_screen.dart';
import 'psychiatrist_screens/psychiatrist_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PsychiatristService _psychiatristService = PsychiatristService();

  int _selectedIndex = 0;
  Map<String, dynamic>? _psychiatristDetails;
  bool _isLoading = true;
  bool _hasError = false;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const PatientScreen(),
    const SessionScreen(),
  ];

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

  Future<void> _handleLogout() async {
    final loggedOut = await _psychiatristService.logoutPsychiatrist();
    if (loggedOut && mounted) {
      Navigator.pushReplacementNamed(context, '/loginHome');
    }
  }

  void _onBottomNavItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width < kDesktopBreakpoint;

    return isMobile
        ? Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  if (_psychiatristDetails != null) {
                    final id = _psychiatristDetails!['ID'];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) =>
                                PsychiatristDetailsScreen(psychiatristID: id),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(width: 13),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _handleLogout,
              ),
            ],
          ),
          body:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _hasError
                  ? const Center(child: Text('Error fetching details'))
                  : _screens[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onBottomNavItemTapped,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard_outlined),
                activeIcon: const Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
                backgroundColor: colorScheme.primary,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_2_outlined),
                activeIcon: const Icon(Icons.person_2_rounded),
                label: 'Patients',
                backgroundColor: colorScheme.primary,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.event_outlined),
                activeIcon: const Icon(Icons.event_rounded),
                label: 'Sessions',
                backgroundColor: colorScheme.primary,
              ),
            ],
          ),
        )
        : DesktopLayout(
          primaryScreen: _screens[_selectedIndex],
          onItemSelected: (index) => setState(() => _selectedIndex = index),
          colorScheme: colorScheme,
          psychiatristDetails: _psychiatristDetails,
          isLoading: _isLoading,
          hasError: _hasError,
          onLogout: _handleLogout,
        );
  }
}
