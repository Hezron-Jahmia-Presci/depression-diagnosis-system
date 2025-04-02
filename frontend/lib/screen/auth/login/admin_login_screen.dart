import 'package:flutter/material.dart';

import '../../../widget/widget_exporter.dart';
import '../../../service/admin_service.dart' show AdminService;
import '../../home/admin/admin_home_screen.dart' show AdminHomeScreen;

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final AdminService _adminService = AdminService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final adminResponse = await _adminService.loginAdmin(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (adminResponse != null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
        );
        return;
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ReusableSnackbarWidget.show(context, 'User does not exist');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ReusableSnackbarWidget.show(context, 'An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width / 2.3,
            height: MediaQuery.sizeOf(context).height / 1.5,
            child: ReusableCardWidget(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      "LOGIN",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  Divider(color: colorScheme.onSecondary),
                  const SizedBox(height: 32),
                  ReusableTextFieldWidget(
                    controller: _emailController,
                    label: 'Email',
                    validator:
                        (value) => value!.isEmpty ? 'Enter your email' : null,
                  ),
                  const SizedBox(height: 13),
                  ReusableTextFieldWidget(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: true,
                    validator:
                        (value) =>
                            value != null && value.length < 6
                                ? 'Password must be at least 6 characters'
                                : null,
                  ),
                  const SizedBox(height: 24),
                  ReusableButtonWidget(
                    isLoading: _isLoading,
                    onPressed: _login,
                    text: 'Login',
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
