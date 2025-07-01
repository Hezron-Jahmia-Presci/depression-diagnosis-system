import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/constants/layout_constant.dart';
import 'package:depression_diagnosis_system/layout/lib/desktop_layout.dart';
import 'package:depression_diagnosis_system/layout/lib/mobile_layout.dart';
import 'package:depression_diagnosis_system/service/lib/admin_service.dart';
import '../screen/screens_exporter.dart';
import '../widget/widget_exporter.dart';

class AdminLayout extends StatefulWidget {
  final String title;
  const AdminLayout({required this.title, super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  final _adminService = AdminService();
  late final List<Widget> _screens;
  int _selectedIndex = 0;

  Map<String, dynamic>? _adminDetails;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _screens = [
      AdminPatientScreen(),
      AdminPsychiatristScreen(),
      AdminSessionScreen(),
      AdminDetailsScreen(),
    ];
    _fetchAdminDetails();
  }

  Future<void> _fetchAdminDetails() async {
    try {
      final details = await _adminService.getAdminDetails();
      setState(() {
        _adminDetails = details;
        _hasError = details == null;
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

  void _onNavTap(int index) => setState(() => _selectedIndex = index);

  Future<void> _handleLogout() async {
    final loggedOut = await _adminService.logoutAdmin();
    if (loggedOut && mounted) {
      Navigator.pushReplacementNamed(context, '/loginHome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < kDesktopBreakpoint;

    final sidebar = AdaptiveSidebar(
      isCompact: isMobile,
      onItemSelected: _onNavTap,
      onLogout: _handleLogout,
      colorScheme: Theme.of(context).colorScheme,
      userDetails: _adminDetails,
      isLoading: _isLoading,
      hasError: _hasError,
      onProfileTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminDetailsScreen()),
        );
      },
      navigationItems: [
        SidebarNavItem(
          index: 0,
          icon: Icons.person,
          title: 'Patients',
          screen: AdminPatientScreen(),
        ),
        SidebarNavItem(
          index: 1,
          icon: Icons.medical_services,
          title: 'Psychiatrists',
          screen: AdminPsychiatristScreen(),
        ),
        SidebarNavItem(
          index: 2,
          icon: Icons.event,
          title: 'Sessions',
          screen: AdminSessionScreen(),
        ),
      ],
    );

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // disables back arrow
          forceMaterialTransparency: true,
          title: Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 50, // adjust height as needed
                fit: BoxFit.contain,
              ),
              Builder(
                builder: (context) {
                  final titles = [
                    'Patients',
                    'Psychiatrists',
                    'Sessions',
                    'Profile',
                  ];
                  return Text(
                    titles[_selectedIndex],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  );
                },
              ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'profile') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminDetailsScreen(),
                    ),
                  );
                } else if (value == 'logout') {
                  final loggedOut = await _adminService.logoutAdmin();
                  if (loggedOut && mounted) {
                    Navigator.pushReplacementNamed(context, '/loginHome');
                  }
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'profile',
                      child: Text('View Profile'),
                    ),
                    const PopupMenuItem(value: 'logout', child: Text('Logout')),
                  ],
            ),
          ],
        ),

        body:
            isMobile
                ? MobileLayout(
                  selectedIndex: _selectedIndex,
                  onNavTap: _onNavTap,
                  screen: _screens[_selectedIndex],
                  navigationItems: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline),
                      activeIcon: Icon(Icons.person),
                      label: 'Patients',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.medical_services_outlined),
                      activeIcon: Icon(Icons.medical_services),
                      label: 'Psychiatrists',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.event_outlined),
                      activeIcon: Icon(Icons.event),
                      label: 'Sessions',
                    ),
                  ],
                )
                : DesktopLayout(
                  primaryScreen: _screens[_selectedIndex],
                  sidebar: sidebar,
                ),
      ),
    );
  }
}
