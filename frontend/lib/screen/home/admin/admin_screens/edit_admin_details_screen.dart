import 'package:flutter/material.dart';

import '../../../../service/admin_service.dart' show AdminService;
import '../../../../widget/widget_exporter.dart';

import 'admin_details_screen.dart' show AdminDetailsScreen;

class EditAdminDetailsScreen extends StatefulWidget {
  const EditAdminDetailsScreen({super.key});

  @override
  State<EditAdminDetailsScreen> createState() => _EditAdminDetailsScreenState();
}

class _EditAdminDetailsScreenState extends State<EditAdminDetailsScreen> {
  final AdminService _adminService = AdminService();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  Map<String, dynamic>? _adminDetails;
  bool _isSubmitting = false;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchPsychiatristDetails();
  }

  Future<void> _fetchPsychiatristDetails() async {
    try {
      final details = await _adminService.getAdminDetails();
      if (details != null) {
        setState(() {
          _adminDetails = details;
          _firstNameController.text = details['first_name'] ?? '';
          _lastNameController.text = details['last_name'] ?? '';
          _emailController.text = details['email'] ?? '';
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

  Future<void> _savePsychiatristDetails() async {
    final psychiatristData = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
    };
    final details = await _adminService.updateAdmin(psychiatristData);

    setState(() {
      _isSubmitting = false;
    });

    if (details != null) {
      ReusableSnackbarWidget.show(
        context,
        'Psychiatrist details updated successfully!',
      );
      _navigateToViewPsychiatristDetailsScreen();
    } else {
      ReusableSnackbarWidget.show(
        context,
        'Failed to update details. Try again.',
      );
    }
  }

  void _navigateToViewPsychiatristDetailsScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AdminDetailsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EDIT PROFILE',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: _navigateToViewPsychiatristDetailsScreen,
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
                child: _buildPsychDetails(_adminDetails!),
              ),
    );
  }

  Widget _buildPsychDetails(Map<String, dynamic> psych) {
    return Center(
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width / 2,
        height: MediaQuery.sizeOf(context).height / 1.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReusableTextFieldWidget(
              controller: _firstNameController,
              label: 'First Name',
            ),
            const SizedBox(height: 13),
            ReusableTextFieldWidget(
              controller: _lastNameController,
              label: 'Last Name',
            ),
            const SizedBox(height: 13),
            ReusableTextFieldWidget(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            ReusableButtonWidget(
              isLoading: _isSubmitting,
              onPressed: _savePsychiatristDetails,
              text: 'Save Changes',
            ),
          ],
        ),
      ),
    );
  }
}
