import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/constants/layout_constant.dart';
import 'package:depression_diagnosis_system/layout/lib/desktop_layout.dart';
import 'package:depression_diagnosis_system/layout/lib/mobile_layout.dart';
import 'package:depression_diagnosis_system/service/lib/health_worker_service.dart';

import '../screen/screens_exporter.dart';
import '../widget/widget_exporter.dart';

class AppLayout extends StatefulWidget {
  final String title;
  const AppLayout({required this.title, super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  final GlobalKey<AdminPatientScreenState> _patientScreenKey =
      GlobalKey<AdminPatientScreenState>();
  final GlobalKey<MedicationHistoryScreenState> _medicationHistoryScreenKey =
      GlobalKey<MedicationHistoryScreenState>();
  final GlobalKey<AdminSessionScreenState> _sessionScreenKey =
      GlobalKey<AdminSessionScreenState>();
  final GlobalKey<Phq9QuestionScreenState> _phq9QuestionScreenKey =
      GlobalKey<Phq9QuestionScreenState>();

  final HealthWorkerService _healthWorkerService = HealthWorkerService();

  int _selectedIndex = 0;

  Map<String, dynamic>? _userDetails;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isFabVisible = true;

  late List<Widget> _screens;
  late final Map<int, FabConfig> _fabConfigs = {
    1: FabConfig(
      icon: Icons.add_to_queue_outlined,
      label: "Register Patient",
      onPressed: () async {
        final didCreate = await _openBottomSheet(const RegisterPatientScreen());
        if (didCreate == true) {
          await _patientScreenKey.currentState?.reload();
          setState(() {});
        }
      },
    ),
    2: FabConfig(
      icon: Icons.medication_outlined,
      label: "Medication History",
      onPressed: () async {
        final didCreate = await _openBottomSheet(
          const MedicationHistoryScreen(),
        );
        if (didCreate == true) {
          await _medicationHistoryScreenKey.currentState?.reload();
          setState(() {});
        }
      },
    ),
    3: FabConfig(
      icon: Icons.event_note_outlined,
      label: "Start New Session",
      onPressed: () async {
        final didRegister = await _openBottomSheet(const CreateSessionScreen());
        if (didRegister == true) {
          await _sessionScreenKey.currentState?.reload();
          setState(() {});
        }
      },
    ),
  };

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      final details = await _healthWorkerService.getHealthWorkerById();

      _userDetails = details;
      _hasError = details == null;

      _screens = [
        DashboardScreen(),
        PatientScreen(
          key: _patientScreenKey,
          onFabVisibilityChanged:
              (visible) => setState(() => _isFabVisible = visible),
        ),
        MedicationHistoryScreen(
          key: _medicationHistoryScreenKey,
          onFabVisibilityChanged:
              (visible) => setState(() => _isFabVisible = visible),
        ),
        SessionScreen(
          key: _sessionScreenKey,
          onFabVisibilityChanged:
              (visible) => setState(() => _isFabVisible = visible),
        ),
        Phq9QuestionScreen(
          key: _phq9QuestionScreenKey,
          onFabVisibilityChanged:
              (visible) => setState(() => _isFabVisible = !visible),
        ),
        HealthWorkerDetailsScreen(
          healthWorkerID: details!['ID'],
          onBack: () => setState(() => _selectedIndex = 0),
        ),
      ];

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching user details: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _onNavTap(int index) {
    if (_selectedIndex == index) {
      // Re-tap logic if needed
      switch (index) {
        case 0:
          _patientScreenKey.currentState?.resetToListView();
          break;
        case 1:
          _medicationHistoryScreenKey.currentState?.resetToListView();
          break;
        case 2:
          _phq9QuestionScreenKey.currentState;
          break;
        case 3:
          _sessionScreenKey.currentState?.resetToListView();
          break;
      }
      return;
    }

    setState(() {
      _selectedIndex = index;
      _isFabVisible = true;
    });
  }

  Future<void> _handleLogout() async {
    final loggedOut = await _healthWorkerService.logoutHealthWorker();
    if (loggedOut && mounted) {
      Navigator.pushReplacementNamed(context, '/loginHome');
    }
  }

  Future<bool?> _openBottomSheet(Widget child) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return ReusableCardWidget(
              child: SingleChildScrollView(
                controller: scrollController,
                child: child,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < kDesktopBreakpoint;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final titles = [
      'Dashboard',
      'Patients',
      'Medication Histories',
      'Sessions',
      'PHQ-9 Questions',
      'Profile',
    ];

    final sidebar = AdaptiveSidebar(
      isCompact: isMobile,
      onItemSelected: _onNavTap,
      onLogout: _handleLogout,
      colorScheme: Theme.of(context).colorScheme,
      userDetails: _userDetails,
      isLoading: _isLoading,
      hasError: _hasError,
      onProfileTap: () => _onNavTap(4),
      navigationItems: [
        SidebarNavItem(
          index: 0,
          icon: Icons.dashboard_outlined,
          title: 'Dashboard',
          screen: const DashboardScreen(),
        ),
        SidebarNavItem(
          index: 1,
          icon: Icons.person_outline,
          title: 'Patients',
          screen: const PatientScreen(),
        ),
        SidebarNavItem(
          index: 2,
          icon: Icons.medication_outlined,
          title: 'Medication Histories',
          screen: const MedicationHistoryScreen(),
        ),
        SidebarNavItem(
          index: 3,
          icon: Icons.event_note_outlined,
          title: 'Sessions',
          screen: const SessionScreen(),
        ),
        SidebarNavItem(
          index: 4,
          icon: Icons.quiz_outlined,
          title: 'PHQ-9 Questions',
          screen: const Phq9QuestionScreen(),
        ),
      ],
    );

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          forceMaterialTransparency: true,
          title: Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 50, // adjust height as needed
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 13),
              Text(
                titles[_selectedIndex],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            PopupMenuButton(
              onSelected: (value) async {
                if (value == 'logout') await _handleLogout();
              },
              itemBuilder:
                  (context) => const [
                    PopupMenuItem(value: 'logout', child: Text('Logout')),
                  ],
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child:
              isMobile
                  ? MobileLayout(
                    floatingActionButton: _buildFAB(),
                    selectedIndex: _selectedIndex,
                    onNavTap: _onNavTap,
                    screen: _screens[_selectedIndex],
                    navigationItems: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.dashboard_outlined),
                        activeIcon: Icon(Icons.dashboard),
                        label: 'Dashboard',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline),
                        label: 'Patients',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.medication_outlined),
                        label: 'Medication',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.event_note_outlined),
                        label: 'Sessions',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.quiz_outlined),
                        label: 'PHQ-9',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_pin_outlined),
                        label: 'Profile',
                      ),
                    ],
                  )
                  : DesktopLayout(
                    primaryScreen: _screens[_selectedIndex],
                    sidebar: sidebar,
                    floatingActionButton: _buildFAB(),
                  ),
        ),
      ),
    );
  }

  Widget? _buildFAB() {
    if (!_isFabVisible || _selectedIndex == 0) return null;

    final config = _fabConfigs[_selectedIndex];
    if (config == null) return null;

    return FloatingActionButton.extended(
      heroTag: 'fab_$_selectedIndex',
      onPressed: config.onPressed,
      icon: Icon(config.icon),
      label: Text(config.label),
    );
  }
}

class FabConfig {
  final IconData icon;
  final String label;
  final Future<void> Function() onPressed;

  FabConfig({required this.icon, required this.label, required this.onPressed});
}
