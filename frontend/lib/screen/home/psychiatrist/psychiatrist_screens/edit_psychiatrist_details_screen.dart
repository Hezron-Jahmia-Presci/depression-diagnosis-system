import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/psychiatrist_service.dart';
import '../../../../widget/widget_exporter.dart';
import 'psychiatrist_details_screen.dart';

class EditPsychiatristDetailsScreen extends StatefulWidget {
  final int psychiatristID;
  final VoidCallback onBack;

  const EditPsychiatristDetailsScreen({
    super.key,
    required this.psychiatristID,
    required this.onBack,
  });

  @override
  State<EditPsychiatristDetailsScreen> createState() =>
      _EditPsychiatristDetailsScreenState();
}

class _EditPsychiatristDetailsScreenState
    extends State<EditPsychiatristDetailsScreen> {
  final _psychiatristService = PsychiatristService();
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _hasError = false;
  int? _psychiatristId;
  int? _selectedPsychiatristID;

  @override
  void initState() {
    super.initState();
    _loadPsychiatristDetails();
  }

  Future<void> _loadPsychiatristDetails() async {
    try {
      final details = await _psychiatristService.getPsychiatristDetails();
      if (details != null && !details.containsKey('error')) {
        _firstNameController.text = details['first_name'] ?? '';
        _lastNameController.text = details['last_name'] ?? '';
        _emailController.text = details['email'] ?? '';
        _psychiatristId = details['ID'];
        setState(() => _isLoading = false);
      } else {
        _setError();
      }
    } catch (_) {
      _setError();
    }
  }

  void _setError() {
    setState(() {
      _hasError = true;
      _isLoading = false;
    });
  }

  Future<void> reload() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _selectedPsychiatristID = null;
    });
    await _loadPsychiatristDetails();
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final data = {
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
    };

    final res = await _psychiatristService.updatePsychiatrist(data);

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (res != null && res['error'] == null) {
      ReusableSnackbarWidget.show(context, 'Details updated successfully!');
    } else {
      ReusableSnackbarWidget.show(
        context,
        res?['error'] ?? 'Failed to update details',
      );
    }
  }

  void _goBackToList() {
    setState(() {
      _selectedPsychiatristID = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return const Center(child: Text('Failed to fetch patients.'));
    }

    if (_selectedPsychiatristID != null) {
      return PsychiatristDetailsScreen();
    }

    if (_psychiatristId == null) {
      return const Center(child: Text('No psychiatrist details found'));
    }

    return ListView(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: widget.onBack,
            ),
            const Text(
              'Psychiatrist Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 55),
        ReusableTextFieldWidget(
          controller: _firstNameController,
          label: 'First Name',
          validator:
              (val) =>
                  val == null || val.isEmpty ? 'First name is required' : null,
          autofillHints: const [AutofillHints.givenName],
        ),
        const SizedBox(height: 24),
        ReusableTextFieldWidget(
          controller: _lastNameController,
          label: 'Last Name',
          validator:
              (val) =>
                  val == null || val.isEmpty ? 'Last name is required' : null,
          autofillHints: const [AutofillHints.familyName],
        ),
        const SizedBox(height: 24),
        ReusableTextFieldWidget(
          controller: _emailController,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
          validator:
              (val) =>
                  val == null || !val.contains('@')
                      ? 'Enter a valid email'
                      : null,
          autofillHints: const [AutofillHints.email],
        ),
        const SizedBox(height: 33),
        ReusableButtonWidget(
          text: 'Save Changes',
          isLoading: _isSubmitting,
          onPressed: _submitUpdate,
        ),
      ],
    );
  }
}
