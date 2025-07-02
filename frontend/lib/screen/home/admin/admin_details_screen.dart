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
  int? _selectedAdminID;

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

  Future<void> reload() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _selectedAdminID = null;
    });
    await _loadAdminDetails();
  }

  void _goToEditScreen(int psychiatristID) {
    setState(() => _selectedAdminID = psychiatristID);
  }

  void _goBackToList() {
    setState(() => _selectedAdminID = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_hasError || _adminDetails == null) {
      return const Center(child: Text('Error fetching admin details'));
    }

    if (_selectedAdminID != null) {
      return EditAdminDetailsScreen(
        adminID: _selectedAdminID!,
        onBack: _goBackToList,
      );
    }

    final admin = _adminDetails!;

    return ListView(
      children: [
        const SizedBox(height: 16),
        ReusableCardWidget(
          child: Text('First Name: ${admin['first_name'] ?? 'N/A'}'),
        ),
        const SizedBox(height: 12),
        ReusableCardWidget(
          child: Text('Last Name: ${admin['last_name'] ?? 'N/A'}'),
        ),
        const SizedBox(height: 12),
        ReusableCardWidget(child: Text('Email: ${admin['email'] ?? 'N/A'}')),
        const SizedBox(height: 24),
        ReusableButtonWidget(
          text: 'Edit Details',
          isLoading: false,
          onPressed: () => _goToEditScreen(admin['ID']),
        ),
      ],
    );
  }
}
