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
  bool _isSubmitting = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      return;
    }

    try {
      final adminResponse = await _adminService.loginAdmin(
        _emailController.text.trim(),
        _passwordController.text,
      );

      setState(() {
        _isSubmitting = false;
      });

      if (adminResponse != null && adminResponse['error'] == null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
          );
        }
      } else {
        if (adminResponse != null && adminResponse['error'] != null) {
          if (mounted) {
            ReusableSnackbarWidget.show(context, adminResponse['error']);
          }
        } else {
          if (mounted) {
            ReusableSnackbarWidget.show(context, 'Login failed');
          }
        }
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ReusableSnackbarWidget.show(context, 'An error occurred: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "LOGIN AS AN ADMIN",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
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
                    isLoading: _isSubmitting,
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
