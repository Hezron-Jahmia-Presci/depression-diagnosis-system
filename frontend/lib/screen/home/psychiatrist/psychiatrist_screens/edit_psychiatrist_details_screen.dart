import 'package:flutter/material.dart';
import '../../../../widget/widget_exporter.dart';
import '../../../../service/psychiatrist_service.dart' show PsychiatristService;
import 'psychiatrist_details_screen.dart' show PsychiatristDetailsScreen;

class EditPsychiatristDetailsScreen extends StatefulWidget {
  const EditPsychiatristDetailsScreen({super.key});

  @override
  State<EditPsychiatristDetailsScreen> createState() =>
      _EditPsychiatristDetailsScreenState();
}

class _EditPsychiatristDetailsScreenState
    extends State<EditPsychiatristDetailsScreen> {
  final PsychiatristService _psyhiatristService = PsychiatristService();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  Map<String, dynamic>? _psychiatristDetails;
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
      final details = await _psyhiatristService.getPsychiatristDetails();
      if (details != null) {
        setState(() {
          _psychiatristDetails = details;
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
    setState(() {
      _isSubmitting = true;
    });

    final details = await _psyhiatristService.updatePsychiatrist(
      psychiatristData,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (details != null) {
      ReusableSnackbarWidget.show(
        context,
        'Psychiatrist details updated successfully!',
      );
      _navigateToViewPsychiatristDetailsScreen(details['ID']);
    } else {
      ReusableSnackbarWidget.show(
        context,
        'Failed to update details. Try again.',
      );
    }
  }

  void _navigateToViewPsychiatristDetailsScreen(int psychiatristID) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                PsychiatristDetailsScreen(psychiatristID: psychiatristID),
      ),
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
          onPressed: () {
            if (_psychiatristDetails != null) {
              _navigateToViewPsychiatristDetailsScreen(
                _psychiatristDetails!['ID'],
              );
            }
          },
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
                child: _buildPsychDetails(_psychiatristDetails!),
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
