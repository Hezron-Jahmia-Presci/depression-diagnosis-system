import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/constants/layout_constant.dart';
import 'package:depression_diagnosis_system/layout/lib/desktop_layout.dart';
import 'package:depression_diagnosis_system/layout/lib/mobile_layout.dart';
import 'package:depression_diagnosis_system/screen/home/psychiatrist/patient_screens/patient_screen.dart';
import 'package:depression_diagnosis_system/screen/home/psychiatrist/session_screens/session_screen.dart';
import 'package:depression_diagnosis_system/service/lib/psychiatrist_service.dart';
import '../screen/screens_exporter.dart';
import '../widget/widget_exporter.dart';

class AppLayout extends StatefulWidget {
  final String title;
  const AppLayout({required this.title, super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  final _psychiatristService = PsychiatristService();
  final GlobalKey<PatientScreenState> _patientScreenKey =
      GlobalKey<PatientScreenState>();
  final GlobalKey<SessionScreenState> _sessionScreenKey =
      GlobalKey<SessionScreenState>();

  late List<Widget> _screens;
  int _selectedIndex = 0;

  Map<String, dynamic>? _psychiatristDetails;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isFabVisible = true;

  late final Map<int, FabConfig> _fabConfigs = {
    1: FabConfig(
      icon: Icons.person_add_alt_1_rounded,
      label: "Register Patient",
      onPressed: () async {
        final didRegister = await _openBottomSheet(
          const RegisterPatientScreen(),
        );
        if (didRegister == true) {
          await _patientScreenKey.currentState?.reload();
          setState(() {});
        }
      },
    ),
    2: FabConfig(
      icon: Icons.add_to_queue_outlined,
      label: "Start New Session",
      onPressed: () async {
        final didCreate = await _openBottomSheet(const CreateSessionScreen());
        if (didCreate == true) {
          await _sessionScreenKey.currentState?.reload();
          setState(() {});
        }
      },
    ),
  };

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(),
      PatientScreen(
        key: _patientScreenKey,
        onFabVisibilityChanged: (visible) {
          setState(() => _isFabVisible = visible);
        },
      ),
      SessionScreen(
        key: _sessionScreenKey,
        onFabVisibilityChanged: (visible) {
          setState(() => _isFabVisible = visible);
        },
      ),
      const PsychiatristDetailsScreen(), // Rendered as part of layout
    ];

    _fetchPsychiatristDetails();
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

  Future<void> _fetchPsychiatristDetails() async {
    try {
      final details = await _psychiatristService.getPsychiatristDetails();
      setState(() {
        _psychiatristDetails = details;
        _hasError = details == null;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching psychiatrist details: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
      _isFabVisible = true;
    });
  }

  Future<void> _handleLogout() async {
    final loggedOut = await _psychiatristService.logoutPsychiatrist();
    if (loggedOut && mounted) {
      Navigator.pushReplacementNamed(context, '/loginHome');
    }
  }

  Widget? _buildFAB() {
    if (!_isFabVisible || _selectedIndex == 3)
      return null; // 👈 hide FAB on profile

    final config = _fabConfigs[_selectedIndex];
    if (config == null) return null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 83),
      child: FloatingActionButton.extended(
        onPressed: config.onPressed,
        icon: Icon(config.icon),
        label: Text(config.label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < kDesktopBreakpoint;

    final sidebar = AdaptiveSidebar(
      isCompact: isMobile,
      onItemSelected: _onNavTap,
      onLogout: _handleLogout,
      colorScheme: Theme.of(context).colorScheme,
      userDetails: _psychiatristDetails,
      isLoading: _isLoading,
      hasError: _hasError,
      onProfileTap: () => _onNavTap(3), // ✅ go to profile screen
      navigationItems: [
        SidebarNavItem(
          index: 0,
          icon: Icons.dashboard_rounded,
          title: 'Dashboard',
          screen: DashboardScreen(),
        ),
        SidebarNavItem(
          index: 1,
          icon: Icons.person,
          title: 'Patients',
          screen: const PatientScreen(),
        ),
        SidebarNavItem(
          index: 2,
          icon: Icons.event,
          title: 'Sessions',
          screen: const SessionScreen(),
        ),
      ],
    );

    final titles = ['Dashboard', 'Patients', 'Sessions', 'Profile'];

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          forceMaterialTransparency: true,
          title: Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 50,
                fit: BoxFit.contain,
              ),
              Text(
                titles[_selectedIndex],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'profile') {
                  _onNavTap(3); // ✅ navigate to profile screen
                } else if (value == 'logout') {
                  await _handleLogout();
                }
              },
              itemBuilder:
                  (context) => const [
                    PopupMenuItem(
                      value: 'profile',
                      child: Text('View Profile'),
                    ),
                    PopupMenuItem(value: 'logout', child: Text('Logout')),
                  ],
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 13.0),
          child:
              isMobile
                  ? MobileLayout(
                    selectedIndex: _selectedIndex,
                    onNavTap: _onNavTap,
                    screen: _screens[_selectedIndex],
                    navigationItems: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.dashboard_outlined),
                        activeIcon: Icon(Icons.dashboard_rounded),
                        label: 'Dashboard',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline),
                        activeIcon: Icon(Icons.person),
                        label: 'Patients',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.event_outlined),
                        activeIcon: Icon(Icons.event),
                        label: 'Sessions',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.account_circle_outlined),
                        activeIcon: Icon(Icons.account_circle),
                        label: 'Profile',
                      ),
                    ],
                  )
                  : DesktopLayout(
                    primaryScreen: _screens[_selectedIndex],
                    sidebar: sidebar,
                  ),
        ),
        floatingActionButton: _buildFAB(),
      ),
    );
  }
}

class FabConfig {
  final IconData icon;
  final String label;
  final Future<void> Function() onPressed;

  FabConfig({required this.icon, required this.label, required this.onPressed});
}
