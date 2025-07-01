import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/layout/app_layout.dart';
import 'package:depression_diagnosis_system/service/lib/psychiatrist_service.dart';
import '../../layout/auth_layout.dart';
import '../../widget/widget_exporter.dart';

class PsychLoginScreen extends StatefulWidget {
  const PsychLoginScreen({super.key});

  @override
  State<PsychLoginScreen> createState() => _PsychLoginScreenState();
}

class _PsychLoginScreenState extends State<PsychLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final PsychiatristService _psychiatristService = PsychiatristService();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final res = await _psychiatristService.loginPsychiatrist(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (res != null && res['error'] == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppLayout(title: '')),
      );
    } else {
      final error = res?['error'] ?? 'Login failed';
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
                "Login to your Psychiatrist Account",
                style: TextStyle(fontSize: 32),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 55),
              ReusableTextFieldWidget(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.username],
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Email required'
                            : null,
              ),
              const SizedBox(height: 24),
              ReusableTextFieldWidget(
                controller: _passwordController,
                label: 'Password',
                obscureText: true,
                autofillHints: const [AutofillHints.password],
                validator:
                    (value) =>
                        value != null && value.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
              ),
              const SizedBox(height: 24),
              ReusableButtonWidget(
                text: 'Login',
                isLoading: _isSubmitting,
                onPressed: _login,
              ),
              const SizedBox(height: 33),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text("Don't have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
