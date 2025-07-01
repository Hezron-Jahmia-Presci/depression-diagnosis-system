import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/admin_service.dart';
import '../../../widget/widget_exporter.dart';
import '../../screens_exporter.dart';

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
    _loadAdminDetails();
  }

  Future<void> _loadAdminDetails() async {
    try {
      final details = await _adminService.getAdminDetails();
      setState(() {
        _adminDetails = details;
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

  void _goToEditScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditAdminDetailsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading:
            Navigator.canPop(context)
                ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.pop(context),
                )
                : null,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _hasError || _adminDetails == null
              ? const Center(child: Text('Error loading admin details'))
              : _buildProfileView(),
    );
  }

  Widget _buildProfileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ReusableCardWidget(
                child: Text(
                  'First Name: ${_adminDetails!['first_name'] ?? 'N/A'}',
                ),
              ),
              const SizedBox(height: 12),
              ReusableCardWidget(
                child: Text(
                  'Last Name: ${_adminDetails!['last_name'] ?? 'N/A'}',
                ),
              ),
              const SizedBox(height: 12),
              ReusableCardWidget(
                child: Text('Email: ${_adminDetails!['email'] ?? 'N/A'}'),
              ),
              const SizedBox(height: 24),
              ReusableButtonWidget(
                text: 'Edit Details',
                isLoading: false,
                onPressed: _goToEditScreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
