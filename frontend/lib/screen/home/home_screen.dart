import 'package:flutter/material.dart';

import '../../widget/widget_exporter.dart';
import '../../service/psychiatrist_service.dart' show PsychiatristService;
import 'dashboard_screen.dart' show DashboardScreen;
import 'patient_screens/patient_screen.dart' show PatientScreen;
import 'session_screens/session_screen.dart' show SessionScreen;
import 'psychiatrist_screens/psychiatrist_details_screen.dart'
    show PsychiatristDetailsScreen;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget _selectedScreen = DashboardScreen();
  bool _isLoading = false;

  void _navigateTo(Widget screen) {
    setState(() {
      _isLoading = true;
      _selectedScreen = screen;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Sidebar(
              onItemSelected: _navigateTo,
              colorScheme: colorScheme,
            ),
          ),
          const SizedBox(width: 21),
          Expanded(
            flex: 7,
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _selectedScreen,
          ),
        ],
      ),
    );
  }
}

class Sidebar extends StatefulWidget {
  final Function(Widget) onItemSelected;
  final ColorScheme colorScheme;

  const Sidebar({
    super.key,
    required this.onItemSelected,
    required this.colorScheme,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final PsychiatristService _psychiatristService = PsychiatristService();
  Map<String, dynamic>? _psychiatristDetails;
  bool _isLoading = true;
  bool _hasError = false;
  String _username = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchPsychiatristDetails();
  }

  Future<void> _fetchPsychiatristDetails() async {
    try {
      final details = await _psychiatristService.getPsychiatristDetails();
      if (details != null) {
        setState(() {
          _psychiatristDetails = details;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _handleLogout() async {
    final loggedOut = await _psychiatristService.logoutPsychiatrist();

    if (loggedOut && mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _navigateToViewPsychiatristDetailsScreen() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PsychiatristDetailsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.colorScheme.onPrimary,
      padding: const EdgeInsets.symmetric(vertical: 21, horizontal: 34),
      child: Column(
        children: [
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(width: 10),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _hasError
              ? Center(child: Text('Error fetching details'))
              : Center(child: _buildPsychiatristDetails(_psychiatristDetails!)),

          SizedBox(height: 34),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ReusableButtonWidget(
                isLoading: false,
                onPressed: _handleLogout,
                text: 'Logout',
                backgroundColor: widget.colorScheme.tertiary,
              ),
              ReusableButtonWidget(
                isLoading: false,
                onPressed: _navigateToViewPsychiatristDetailsScreen,
                text: 'View Profile',
              ),
            ],
          ),
          const Divider(height: 34),
          Expanded(
            child: Column(
              children: [
                ReusablenavitemWidget(
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  screen: DashboardScreen(),
                  onItemSelected: widget.onItemSelected,
                  textColor: widget.colorScheme.primary,
                ),
                ReusablenavitemWidget(
                  icon: Icons.person,
                  title: 'Patients',
                  screen: PatientScreen(),
                  onItemSelected: widget.onItemSelected,
                  textColor: widget.colorScheme.primary,
                ),
                ReusablenavitemWidget(
                  icon: Icons.event,
                  title: 'Sessions',
                  screen: SessionScreen(),
                  onItemSelected: widget.onItemSelected,
                  textColor: widget.colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPsychiatristDetails(Map<String, dynamic> psych) {
    var firstName = psych['first_name'];
    var lastName = psych['last_name'];

    setState(() {
      _username = '$firstName $lastName';
    });
    return Text(
      _username,
      style: TextStyle(
        color: widget.colorScheme.primary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
