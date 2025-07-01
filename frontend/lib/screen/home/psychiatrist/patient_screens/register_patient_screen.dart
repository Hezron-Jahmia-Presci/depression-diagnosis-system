import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/patient_service.dart';
import '../../../../widget/widget_exporter.dart';

class RegisterPatientScreen extends StatefulWidget {
  const RegisterPatientScreen({super.key});

  @override
  State<RegisterPatientScreen> createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends State<RegisterPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientService = PatientService();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> _registerPatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final patientData = {
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
    };

    final result = await _patientService.registerPatient(patientData);

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result != null && result['error'] == null) {
      ReusableSnackbarWidget.show(context, 'Patient registered successfully!');
      Navigator.pop(context, true);
    } else {
      ReusableSnackbarWidget.show(
        context,
        result?['error'] ?? 'Failed to register patient. Try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(55.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Register Patient",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ReusableTextFieldWidget(
              controller: _firstNameController,
              label: "First Name",
              validator:
                  (val) =>
                      val == null || val.isEmpty
                          ? "First name is required"
                          : null,
              autofillHints: const [AutofillHints.familyName],
            ),
            const SizedBox(height: 24),
            ReusableTextFieldWidget(
              controller: _lastNameController,
              label: "Last Name",
              validator:
                  (val) =>
                      val == null || val.isEmpty
                          ? "Last name is required"
                          : null,
              autofillHints: const [AutofillHints.givenName],
            ),
            const SizedBox(height: 24),
            ReusableTextFieldWidget(
              controller: _emailController,
              label: "Email",
              keyboardType: TextInputType.emailAddress,
              validator: (val) {
                if (val == null || val.isEmpty) return "Email is required";
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                return emailRegex.hasMatch(val) ? null : "Enter a valid email";
              },
              autofillHints: const [AutofillHints.email],
            ),

            const SizedBox(height: 33),
            ReusableButtonWidget(
              text: "Register",
              isLoading: _isSubmitting,
              onPressed: _registerPatient,
            ),
          ],
        ),
      ),
    );
  }
}
