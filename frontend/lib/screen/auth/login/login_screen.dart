import 'package:flutter/material.dart';
import '../../../service/psychiatrist_service.dart' show PsychiatristService;
import '../../../widget/widget_exporter.dart';
import '../../home/psychiatrist/home_screen.dart' show HomeScreen;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final PsychiatristService _psychiatristService = PsychiatristService();

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final psychiatristResponse = await _psychiatristService.loginPsychiatrist(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (psychiatristResponse != null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
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
                  const SizedBox(height: 32),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text("Don't have an account? Register"),
                  ),
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
