import 'package:flutter/material.dart';

import '../../../service/admin_service.dart' show AdminService;
import 'admin_screens/admin_details_screen.dart' show AdminDetailsScreen;
import 'home_screens/patient_screen.dart' show PatientScreen;
import 'home_screens/psychiatrist_screen.dart' show PsychiatristScreen;
import 'home_screens/session_screen.dart' show SessionScreen;

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _adminDetails;
  bool _isLoading = true;
  bool _hasError = false;
  String _username = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchAdminDetails();
  }

  Future<void> _fetchAdminDetails() async {
    try {
      final details = await _adminService.getAdminDetails();
      if (!mounted) return;

      setState(() {
        if (details != null) {
          _adminDetails = details;

          _isLoading = false;
        } else {
          _hasError = true;
          _isLoading = false;
        }
      });

      setState(() {
        _username =
            "${_adminDetails!['first_name']} ${_adminDetails!['last_name']}";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final loggedOut = await _adminService.logoutAdmin();

    if (loggedOut && mounted) {
      Navigator.pushReplacementNamed(context, '/loginHome');
    }
  }

  void _navigateToViewAdminDetailsScreen() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminDetailsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _hasError
        ? Center(child: Text('Error fetching details'))
        : DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: Text(
                'Welcome $_username',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.person),
                  onPressed: _navigateToViewAdminDetailsScreen,
                ),
                SizedBox(width: 13),
                IconButton(icon: Icon(Icons.logout), onPressed: _handleLogout),
              ],
              bottom: TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.person), text: "Patients"),
                  Tab(icon: Icon(Icons.person), text: "Psychiatrists"),
                  Tab(icon: Icon(Icons.event), text: "Sessions"),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                PatientScreen(),
                PsychiatristScreen(),
                SessionScreen(),
              ],
            ),
          ),
        );
  }
}
