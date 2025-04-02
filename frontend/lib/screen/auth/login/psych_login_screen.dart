import 'package:flutter/material.dart';
import '../../../service/psychiatrist_service.dart' show PsychiatristService;
import '../../../widget/widget_exporter.dart';
import '../../home/psychiatrist/home_screen.dart' show HomeScreen;

class PsychLoginScreen extends StatefulWidget {
  const PsychLoginScreen({super.key});

  @override
  State<PsychLoginScreen> createState() => _PsychLoginScreenState();
}

class _PsychLoginScreenState extends State<PsychLoginScreen> {
  final PsychiatristService _psychiatristService = PsychiatristService();

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
      final psychiatristResponse = await _psychiatristService.loginPsychiatrist(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (psychiatristResponse != null &&
          psychiatristResponse['error'] == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        if (psychiatristResponse != null &&
            psychiatristResponse['error'] != null) {
          if (!mounted) return;
          ReusableSnackbarWidget.show(context, psychiatristResponse['error']);
        }
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ReusableSnackbarWidget.show(context, 'An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "LOGIN AS A PSYCHIATRIST",
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
                  const SizedBox(height: 32),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text("Don't have an account? Register"),
                  ),
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
