import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/psychiatrist_service.dart';
import '../../layout/auth_layout.dart';
import '../../widget/widget_exporter.dart';
import 'psych_login_screen.dart';

class PsychRegisterScreen extends StatefulWidget {
  const PsychRegisterScreen({super.key});

  @override
  State<PsychRegisterScreen> createState() => _PsychRegisterScreenState();
}

class _PsychRegisterScreenState extends State<PsychRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final PsychiatristService _psychiatristService = PsychiatristService();

  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final response = await _psychiatristService.registerPsychiatrist({
      'first_Name': _firstNameController.text.trim(),
      'last_Name': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
    });

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (response != null && response['error'] == null) {
      ReusableSnackbarWidget.show(context, 'Registration successful');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PsychLoginScreen()),
      );
    } else {
      final error = response?['error'] ?? 'Registration failed';
      ReusableSnackbarWidget.show(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: "Psychiatrist",
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Register a Psychiatrist Account",
                style: TextStyle(fontSize: 32),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 55),
              ReusableTextFieldWidget(
                controller: _firstNameController,
                label: 'First Name',
                autofillHints: const [AutofillHints.givenName],
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter first name'
                            : null,
              ),
              const SizedBox(height: 16),
              ReusableTextFieldWidget(
                controller: _lastNameController,
                label: 'Last Name',
                autofillHints: const [AutofillHints.familyName],
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter last name'
                            : null,
              ),
              const SizedBox(height: 16),
              ReusableTextFieldWidget(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your email';
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  return emailRegex.hasMatch(value)
                      ? null
                      : 'Enter a valid email';
                },
              ),
              const SizedBox(height: 16),
              ReusableTextFieldWidget(
                controller: _passwordController,
                label: 'Password',
                obscureText: _obscurePassword,
                autofillHints: const [AutofillHints.password],
                validator:
                    (value) =>
                        value == null || value.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              ReusableButtonWidget(
                text: 'Register',
                isLoading: _isSubmitting,
                onPressed: _register,
              ),
              const SizedBox(height: 33),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const PsychLoginScreen()),
                  );
                },
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
