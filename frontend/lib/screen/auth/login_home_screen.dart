import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/constants/color_constants.dart';
import '../../widget/widget_exporter.dart';
import 'unified_login_screen.dart';

class LoginHomeScreen extends StatelessWidget {
  const LoginHomeScreen({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = screenWidth * 0.35;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: cardWidth,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 200, // adjust height as needed
                        fit: BoxFit.contain,
                      ),
                    ),

                    Text(
                      'DDS',
                      style: TextStyle(
                        fontSize: 128,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "Log in to get started with the system",
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 83),

              _LoginOption(
                icon: Icons.admin_panel_settings,
                label: 'Login',
                onTap: () => _navigateTo(context, const UnifiedLoginScreen()),
                color: colorScheme.primary,
                width: cardWidth,
              ),

              const SizedBox(height: 122), // spacing before footer
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        width:
            double.infinity, // full width of parent (which is scroll's width)
        color: colorScheme.surfaceContainer, // same color as before
        padding: const EdgeInsets.all(16),
        child: const _FooterText(),
      ),
    );
  }
}

class _FooterText extends StatelessWidget {
  const _FooterText();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Text(
        '© 2025 Butabika National Mental Referral Hospital. All rights reserved.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
          fontSize: 14,
        ),
      ),
    );
  }
}

class _LoginOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final double width;

  const _LoginOption({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableCardWidget(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: SizedBox(
          width: width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReusableGradientIcon(
                icon: icon,
                size: 148,
                colors: AppGradients.vibrant,
                onPressed: onTap,
                tooltip: 'Login as $label',
              ),

              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
