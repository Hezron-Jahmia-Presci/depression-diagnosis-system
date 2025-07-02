// lib/screen/admin/admin_login_screen.dart

import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/layout/admin_layout.dart';
import 'package:depression_diagnosis_system/service/lib/admin_service.dart';

import '../../layout/auth_layout.dart';
import '../../widget/widget_exporter.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AdminService _adminService = AdminService();

  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final res = await _adminService.loginAdmin({
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
    });

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (res != null && res['error'] == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminLayout(title: '')),
      );
    } else {
      final error = res?['error'] ?? 'Login failed';
      ReusableSnackbarWidget.show(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: "Admin",
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Login to your Admin Account",
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
                obscureText: _obscurePassword,
                autofillHints: const [AutofillHints.password],
                validator:
                    (value) =>
                        value != null && value.length < 6
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
