import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/constants/color_constants.dart';
import '../../widget/widget_exporter.dart';
import 'unified_login_screen.dart';

class LoginHomeScreen extends StatelessWidget {
  final void Function() toggleTheme;
  const LoginHomeScreen({super.key, required this.toggleTheme});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = screenWidth * 0.6;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
      ),

      body: Stack(
        children: [
          // background image
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset('assets/images/2.jpg', fit: BoxFit.cover),
            ),
          ),

          // content area
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: Column(
                      children: [
                        const SizedBox(height: 96),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'BUTABIKA NATIONAL REFERAL MENTAL HOSPITAL',
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Text(
                          "Depression Diagnosis System",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 96),

                        // Info cards
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  ReusableCardWidget(
                                    child: _buildInfoContent(
                                      icon: Icons.local_hospital,
                                      color: Colors.green,
                                      title: "About Butabika Hospital",
                                      paragraph1:
                                          "Butabika National Mental Referral Hospital is Uganda’s primary psychiatric care institution, offering specialized services in mental health treatment, rehabilitation, and training. Established in 1955, it plays a crucial role in the country’s mental healthcare system.",
                                      paragraph2:
                                          "The hospital also serves as a teaching and research facility, collaborating with universities and mental health stakeholders across East Africa. With a multidisciplinary team of psychiatrists, psychologists, nurses, and social workers, Butabika is at the forefront of mental health advocacy and patient-centered care.",
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  ReusableCardWidget(
                                    child: _buildInfoContent(
                                      icon: Icons.dashboard_customize,
                                      color: Colors.teal,
                                      title: "Using the Diagnosis System",
                                      paragraph1:
                                          "This system streamlines the workflow for psychiatrists by simplifying patient intake, session tracking, and scoring using the PHQ-9. It reduces administrative overhead and supports clinical accuracy.",
                                      paragraph2:
                                          "Each session is recorded in detail and summarized to reflect patient progress. The system supports continuity of care and allows for data-driven decision-making during diagnosis and follow-ups.",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 33),
                            Expanded(
                              child: Column(
                                children: [
                                  ReusableCardWidget(
                                    child: _buildInfoContent(
                                      icon: Icons.psychology,
                                      color: Colors.deepPurple,
                                      title: "Understanding Mental Health",
                                      paragraph1:
                                          "Mental health includes emotional, psychological, and social well-being. It influences how individuals handle stress, relate to others, and make choices. Early symptoms like mood swings or withdrawal need professional evaluation.",
                                      paragraph2:
                                          "Promoting well-being requires early intervention and a supportive environment. PHQ-9 screenings enable consistent monitoring of depressive symptoms, empowering both patients and professionals.",
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  ReusableCardWidget(
                                    child: _buildInfoContent(
                                      icon: Icons.analytics_outlined,
                                      color: Colors.orange,
                                      title: "Importance of PHQ-9 Assessments",
                                      paragraph1:
                                          "PHQ-9 is a validated tool used globally to measure the severity of depression. It provides a consistent method to track changes in mood, energy, sleep, appetite, and thoughts over time.",
                                      paragraph2:
                                          "At Butabika, PHQ-9 supports diagnosis and documentation. The system highlights critical scores and patterns, enabling timely interventions and better care coordination.",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 83),
                        _buildLoginOption(context, cardWidth),
                        const SizedBox(height: 122),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: colorScheme.surfaceContainer,
        padding: const EdgeInsets.all(16),
        child: _buildFooterText(context),
      ),
    );
  }

  Widget _buildInfoContent({
    required IconData icon,
    required Color color,
    required String title,
    required String paragraph1,
    required String paragraph2,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 64),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(paragraph1, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Text(paragraph2, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildFooterText(BuildContext context) {
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

  Widget _buildLoginOption(BuildContext context, double width) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Login',
              style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 33),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ReusableGradientIcon(
                icon: Icons.admin_panel_settings,
                size: 148,
                colors: AppGradients.vibrant,
                onPressed:
                    () => _navigateTo(
                      context,
                      UnifiedLoginScreen(toggleTheme: toggleTheme),
                    ),

                tooltip: 'Login as Admin',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
