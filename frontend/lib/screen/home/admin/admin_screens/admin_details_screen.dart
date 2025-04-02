import 'package:flutter/material.dart';

import '../../../../widget/widget_exporter.dart';
import '../../../../service/admin_service.dart' show AdminService;
import '../admin_home_screen.dart' show AdminHomeScreen;
import 'edit_admin_details_screen.dart' show EditAdminDetailsScreen;

class AdminDetailsScreen extends StatefulWidget {
  const AdminDetailsScreen({super.key});

  @override
  State<AdminDetailsScreen> createState() => _AdminDetailsScreenState();
}

class _AdminDetailsScreenState extends State<AdminDetailsScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _adminDetails;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchAdminDetails();
  }

  Future<void> _fetchAdminDetails() async {
    try {
      final details = await _adminService.getAdminDetails();
      if (details != null) {
        setState(() {
          _adminDetails = details;
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

  void _navigateToEditAdminDetailsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditAdminDetailsScreen()),
    );
  }

  void _navigateToAdminHomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PROFILE',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: _navigateToAdminHomeScreen,
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _hasError
              ? Center(child: Text('Error fetching details'))
              : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 21,
                  vertical: 13,
                ),
                child:
                    _adminDetails != null
                        ? _buildAdminDetails(_adminDetails!)
                        : const Center(child: Text('No details available')),
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToEditAdminDetailsScreen,
        icon: const Icon(Icons.edit_note_outlined),
        label: const Text("Edit Details"),
      ),
    );
  }

  Widget _buildAdminDetails(Map<String, dynamic> admin) {
    return Center(
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width / 2,
        height: MediaQuery.sizeOf(context).height / 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReusableCardWidget(
              child: Text('First Name: ${admin['first_name'] ?? 'N/A'}'),
            ),
            const SizedBox(height: 10),
            ReusableCardWidget(
              child: Text('Last Name: ${admin['last_name'] ?? 'N/A'}'),
            ),
            const SizedBox(height: 10),
            ReusableCardWidget(
              child: Text('Email: ${admin['email'] ?? 'N/A'}'),
            ),
          ],
        ),
      ),
    );
  }
}
