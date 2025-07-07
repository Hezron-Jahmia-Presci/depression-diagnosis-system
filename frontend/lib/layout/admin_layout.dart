import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/constants/layout_constant.dart';
import 'package:depression_diagnosis_system/layout/lib/desktop_layout.dart';
import 'package:depression_diagnosis_system/layout/lib/mobile_layout.dart';
import 'package:depression_diagnosis_system/service/lib/health_worker_service.dart';

import '../screen/screens_exporter.dart';
import '../widget/widget_exporter.dart';

class AdminLayout extends StatefulWidget {
  final String title;
  const AdminLayout({required this.title, super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  final GlobalKey<AdminHealthWorkerScreenState> _healthworkerScreenKey =
      GlobalKey<AdminHealthWorkerScreenState>();
  final GlobalKey<AdminPatientScreenState> _patientScreenKey =
      GlobalKey<AdminPatientScreenState>();
  final GlobalKey<MedicationHistoryScreenState> _medicationHistoryScreenKey =
      GlobalKey<MedicationHistoryScreenState>();
  final GlobalKey<AdminSessionScreenState> _sessionScreenKey =
      GlobalKey<AdminSessionScreenState>();
  final GlobalKey<Phq9QuestionScreenState> _phq9QuestionScreenKey =
      GlobalKey<Phq9QuestionScreenState>();
  final GlobalKey<AdminPersonnelTypeScreenState> _personelTypesScreenKey =
      GlobalKey<AdminPersonnelTypeScreenState>();
  final GlobalKey<AdminDepartmentScreenState> _departmentScreenKey =
      GlobalKey<AdminDepartmentScreenState>();

  final HealthWorkerService _healthWorkerService = HealthWorkerService();

  int _selectedIndex = 0;

  Map<String, dynamic>? _adminDetails;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isFabVisible = true;

  late final List<Widget> _screens;
  late final Map<int, FabConfig> _fabConfigs = {
    1: FabConfig(
      icon: Icons.person_add_alt_1_rounded,
      label: "Register Health Worker",
      onPressed: () async {
        final didRegister = await _openBottomSheet(
          const AdminHealthWorkerRegisterScreen(),
        );
        if (didRegister == true) {
          await _healthworkerScreenKey.currentState?.reload();
          setState(() {});
        }
      },
    ),
    2: FabConfig(
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
    3: FabConfig(
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
    4: FabConfig(
      icon: Icons.event_note_outlined,
      label: "Start New Session",
      onPressed: () async {
        final didRegister = await _openBottomSheet(
          const AdminCreateSessionScreen(),
        );
        if (didRegister == true) {
          await _sessionScreenKey.currentState?.reload();
          setState(() {});
        }
      },
    ),
    5: FabConfig(
      icon: Icons.quiz_outlined,
      label: "Create PHQ-9 Question",
      onPressed: () async {
        final didRegister = await _openBottomSheet(
          const AdminCreatePhq9QuestionScreen(),
        );
        if (didRegister == true) {
          await _phq9QuestionScreenKey.currentState?.reload();
          setState(() {});
        }
      },
    ),
    6: FabConfig(
      icon: Icons.badge_outlined,
      label: "Create Personnel Type",
      onPressed: () async {
        final didRegister = await _openBottomSheet(
          const AdminCreatePersonnelTypesScreen(),
        );
        if (didRegister == true) {
          await _personelTypesScreenKey.currentState?.reload();
          setState(() {});
        }
      },
    ),
    7: FabConfig(
      icon: Icons.business_outlined,
      label: "Create Department",
      onPressed: () async {
        final didRegister = await _openBottomSheet(
          const AdminCreateDepartmentScreen(),
        );
        if (didRegister == true) {
          await _departmentScreenKey.currentState?.reload();
          setState(() {});
        }
      },
    ),
  };

  @override
  void initState() {
    super.initState();
    _loadAdminDetails();
  }

  Future<void> _loadAdminDetails() async {
    try {
      final details = await _healthWorkerService.getHealthWorkerById();

      _adminDetails = details;
      _hasError = details == null || details['role'] != 'admin';

      _screens = [
        AdminDashboardScreen(),
        AdminHealthWorkerScreen(
          key: _healthworkerScreenKey,
          onFabVisibilityChanged:
              (visible) => setState(() => _isFabVisible = visible),
        ),
        AdminPatientScreen(
          key: _patientScreenKey,
          onFabVisibilityChanged:
              (visible) => setState(() => _isFabVisible = visible),
        ),
        AdminMedicationHistoryScreen(
          key: _medicationHistoryScreenKey,
          onFabVisibilityChanged:
              (visible) => setState(() => _isFabVisible = visible),
        ),
        AdminSessionScreen(
          key: _sessionScreenKey,
          onFabVisibilityChanged:
              (visible) => setState(() => _isFabVisible = visible),
        ),
        Phq9QuestionScreen(
          key: _phq9QuestionScreenKey,
          onFabVisibilityChanged:
              (visible) => setState(() => _isFabVisible = visible),
        ),
        AdminPersonnelTypeScreen(
          key: _personelTypesScreenKey,
          onFabVisibilityChanged:
              (visible) => setState(() => _isFabVisible = visible),
        ),
        AdminDepartmentScreen(
          key: _departmentScreenKey,
          onFabVisibilityChanged:
              (visible) => setState(() => _isFabVisible = visible),
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
      debugPrint('Error fetching admin details: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _onNavTap(int index) {
    if (_selectedIndex == index) {
      // Re-tapping the same tab - reset internal view if needed
      switch (index) {
        case 0:
          _healthworkerScreenKey.currentState?.resetToListView();
          break;
        case 1:
          _patientScreenKey.currentState?.resetToListView();
          break;
        case 2:
          _medicationHistoryScreenKey.currentState?.resetToListView();
          break;
        case 3:
          _sessionScreenKey.currentState?.resetToListView();
          break;
        case 4:
          _phq9QuestionScreenKey.currentState;
          break;
        case 5:
          _personelTypesScreenKey.currentState?.resetToListView();
          break;
        case 6:
          _departmentScreenKey.currentState?.resetToListView();
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
      'Health Workers',
      'Patients',
      'Medication Histories',
      'Sessions',
      'PHQ-9 Questions',
      'Personnel Types',
      'Departments',
      'Profile',
    ];

    final sidebar = AdaptiveSidebar(
      isCompact: isMobile,
      onItemSelected: _onNavTap,
      onLogout: _handleLogout,
      colorScheme: Theme.of(context).colorScheme,
      userDetails: _adminDetails,
      isLoading: _isLoading,
      hasError: _hasError,
      onProfileTap: () => _onNavTap(8),
      navigationItems: [
        SidebarNavItem(
          index: 0,
          icon: Icons.dashboard_outlined,
          title: 'Dashboard',
          screen: const AdminDashboardScreen(),
        ),
        SidebarNavItem(
          index: 1,
          icon: Icons.medical_services_outlined,
          title: 'Health Workers',
          screen: const AdminHealthWorkerScreen(),
        ),
        SidebarNavItem(
          index: 2,
          icon: Icons.person_outline,
          title: 'Patients',
          screen: const AdminPatientScreen(),
        ),

        SidebarNavItem(
          index: 3,
          icon: Icons.medication_outlined,
          title: 'Medication Histories',
          screen: const AdminMedicationHistoryScreen(),
        ),

        SidebarNavItem(
          index: 4,
          icon: Icons.event_note_outlined,
          title: 'Sessions',
          screen: const AdminSessionScreen(),
        ),
        SidebarNavItem(
          index: 5,
          icon: Icons.quiz_outlined,
          title: 'PHQ-9 Questions',
          screen: const Phq9QuestionScreen(),
        ),
        SidebarNavItem(
          index: 6,
          icon: Icons.badge_outlined,
          title: 'Personnel Types',
          screen: const AdminPersonnelTypeScreen(),
        ),
        SidebarNavItem(
          index: 7,
          icon: Icons.business_outlined,
          title: 'Departments',
          screen: const AdminDepartmentScreen(),
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
                if (value == 'logout') {
                  await _handleLogout();
                }
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
                        icon: Icon(Icons.medical_services_outlined),
                        activeIcon: Icon(Icons.medical_services),
                        label: 'Health Workers',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline),
                        activeIcon: Icon(Icons.person),
                        label: 'Patients',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.medication_outlined),
                        activeIcon: Icon(Icons.medication),
                        label: 'Medication Histories',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.event_note_outlined),
                        activeIcon: Icon(Icons.event_note),
                        label: 'Sessions',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.quiz_outlined),
                        activeIcon: Icon(Icons.quiz),
                        label: 'PHQ-9 Questions',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.badge_outlined),
                        activeIcon: Icon(Icons.badge),
                        label: 'Personnel Types',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.business_outlined),
                        activeIcon: Icon(Icons.business),
                        label: 'Departments',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_pin_outlined),
                        activeIcon: Icon(Icons.person_pin_rounded),
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
