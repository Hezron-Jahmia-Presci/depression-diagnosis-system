import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/layout/app_layout.dart';
import 'package:depression_diagnosis_system/service/lib/health_worker_service.dart';
import '../../layout/auth_layout.dart';
import '../../widget/widget_exporter.dart';

class HealthWorkerLoginScreen extends StatefulWidget {
  const HealthWorkerLoginScreen({super.key});

  @override
  State<HealthWorkerLoginScreen> createState() =>
      _HealthWorkerLoginScreenState();
}

class _HealthWorkerLoginScreenState extends State<HealthWorkerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final HealthWorkerService _healthWorkerService = HealthWorkerService();

  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final res = await _healthWorkerService.loginHealthWorker(
      _identifierController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (res != null && res['error'] == null) {
      // Optionally: check role here if you want to route based on role
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AppLayout(title: 'Health Worker Dashboard'),
        ),
      );
    } else {
      final error = res?['error'] ?? 'Login failed';
      ReusableSnackbarWidget.show(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: "Health Worker",
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Login to your Health Worker Account",
                style: TextStyle(fontSize: 32),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 55),
              ReusableTextFieldWidget(
                controller: _identifierController,
                label: 'Email or Employee ID',
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.username],
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Email or Employee ID required'
                            : null,
                maxLines: 1,
              ),
              const SizedBox(height: 24),
              ReusableTextFieldWidget(
                controller: _passwordController,
                label: 'Password',
                obscureText: _obscurePassword,
                autofillHints: const [AutofillHints.password],
                validator:
                    (value) =>
                        value != null && value.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                maxLines: 1,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed:
                      () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 24),
              ReusableButtonWidget(
                text: 'Login',
                isLoading: _isSubmitting,
                onPressed: _login,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
