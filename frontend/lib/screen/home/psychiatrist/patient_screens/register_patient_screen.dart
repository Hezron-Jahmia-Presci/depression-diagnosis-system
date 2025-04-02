import 'package:flutter/material.dart';

import '../../../../widget/widget_exporter.dart';
import '../../../../service/patient_service.dart' show PatientService;

class RegisterPatientScreen extends StatefulWidget {
  const RegisterPatientScreen({super.key});

  @override
  State<RegisterPatientScreen> createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends State<RegisterPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final PatientService _patientService = PatientService();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _registerPatient() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final patientData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      };

      final patient = await _patientService.registerPatient(patientData);

      setState(() {
        _isSubmitting = false;
      });

      if (patient != null && mounted) {
        ReusableSnackbarWidget.show(
          context,
          'Patient registered successfully!',
        );

        Navigator.pop(context);
      } else {
        ReusableSnackbarWidget.show(
          context,
          'Failed to register patient. Try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "REGISTER PATIENTS",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 13),
        child: Form(
          key: _formKey,
          child: Center(
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width / 2,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ReusableTextFieldWidget(
                    controller: _firstNameController,
                    label: "First Name",
                    validator:
                        (value) =>
                            value!.isEmpty ? "First name is required" : null,
                  ),
                  const SizedBox(height: 13),
                  ReusableTextFieldWidget(
                    controller: _lastNameController,
                    label: "Last Name",
                    validator:
                        (value) =>
                            value!.isEmpty ? "Last name is required" : null,
                  ),
                  const SizedBox(height: 13),
                  ReusableTextFieldWidget(
                    controller: _emailController,
                    label: "Email",
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Email is required";
                      }
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      return emailRegex.hasMatch(value)
                          ? null
                          : "Enter a valid email";
                    },
                  ),
                  const SizedBox(height: 13),
                  ReusableTextFieldWidget(
                    controller: _passwordController,
                    label: "Password",
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) return "Password is required";
                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ReusableButtonWidget(
                    isLoading: _isSubmitting,
                    onPressed: _registerPatient,
                    text: "Register",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
