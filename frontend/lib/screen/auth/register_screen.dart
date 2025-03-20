import 'package:flutter/material.dart';
import '../../service/psychiatrist_service.dart' show PsychiatristService;
import '../../widget/widget_exporter.dart';
import 'login_screen.dart' show LoginScreen;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  final PsychiatristService _psychiatristService = PsychiatristService();

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _psychiatristService.registerPsychiatrist({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      });

      if (!mounted) return;
      setState(() => _isLoading = false);

      ReusableSnackbarWidget.show(
        context,
        response != null ? 'Registration successful' : 'Registration failed',
      );

      if (response != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
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
      body: Center(
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width / 2.3,
          height: MediaQuery.sizeOf(context).height / 1.3,
          child: Form(
            key: _formKey,
            child: ReusableCardWidget(
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      "SIGN UP",
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
                    controller: _firstNameController,
                    label: 'First Name',
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Enter your first name' : null,
                  ),
                  const SizedBox(height: 13),
                  ReusableTextFieldWidget(
                    controller: _lastNameController,
                    label: 'Last Name',
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Enter your last name' : null,
                  ),
                  const SizedBox(height: 13),
                  ReusableTextFieldWidget(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) return 'Enter your email';
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      return emailRegex.hasMatch(value)
                          ? null
                          : 'Enter a valid email';
                    },
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
                  const SizedBox(height: 20),
                  ReusableButtonWidget(
                    isLoading: _isLoading,
                    onPressed: _register,
                    text: 'Register',
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text('Already have an account? Login'),
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
