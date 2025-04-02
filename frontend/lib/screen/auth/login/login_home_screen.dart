import 'package:flutter/material.dart';
import '../../../widget/widget_exporter.dart' show ReusableCardWidget;
import 'admin_login_screen.dart' show AdminLoginScreen;
import 'login_screen.dart' show LoginScreen;

class LoginHomeScreen extends StatefulWidget {
  const LoginHomeScreen({super.key});

  @override
  State<LoginHomeScreen> createState() => _LoginHomeScreenState();
}

class _LoginHomeScreenState extends State<LoginHomeScreen> {
  void _loginAsAdmin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
    );
  }

  void _loginAsPsychiatrist() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'WELCOME',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Text(
              "Choose your role to get started with the system",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 55),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLoginOption(
                  icon: Icons.admin_panel_settings,
                  colorScheme: colorScheme.primary,
                  label: 'Admin',
                  onPressed: _loginAsAdmin,
                ),
                const SizedBox(width: 32),

                _buildLoginOption(
                  icon: Icons.psychology,
                  colorScheme: colorScheme.primary,
                  label: 'Psychiatrist',
                  onPressed: _loginAsPsychiatrist,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginOption({
    required IconData icon,
    required Color colorScheme,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ReusableCardWidget(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: IconButton(
              icon: Icon(icon, size: 87, color: colorScheme),
              onPressed: onPressed,
              tooltip: 'Login as $label',
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
