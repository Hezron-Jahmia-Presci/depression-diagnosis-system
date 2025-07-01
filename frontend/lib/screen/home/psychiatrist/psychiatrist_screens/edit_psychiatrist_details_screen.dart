import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/psychiatrist_service.dart';
import '../../../../widget/widget_exporter.dart';
import 'psychiatrist_details_screen.dart';

class EditPsychiatristDetailsScreen extends StatefulWidget {
  const EditPsychiatristDetailsScreen({super.key});

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) =>
                  PsychiatristDetailsScreen(psychiatristID: _psychiatristId!),
        ),
      );
    } else {
      ReusableSnackbarWidget.show(
        context,
        res?['error'] ?? 'Failed to update details',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (_psychiatristId != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => PsychiatristDetailsScreen(
                        psychiatristID: _psychiatristId!,
                      ),
                ),
              );
            }
          },
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _hasError
              ? const Center(child: Text('Failed to load psychiatrist details'))
              : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReusableTextFieldWidget(
                  controller: _firstNameController,
                  label: 'First Name',
                  validator:
                      (val) =>
                          val == null || val.isEmpty
                              ? 'First name is required'
                              : null,
                  autofillHints: const [AutofillHints.givenName],
                ),
                const SizedBox(height: 24),
                ReusableTextFieldWidget(
                  controller: _lastNameController,
                  label: 'Last Name',
                  validator:
                      (val) =>
                          val == null || val.isEmpty
                              ? 'Last name is required'
                              : null,
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
            ),
          ),
        ),
      ),
    );
  }
}
