// lib/layout/lib/desktop_layout.dart

import 'package:depression_diagnosis_system/constants/layout_constant.dart';
import 'package:flutter/material.dart';

class DesktopLayout extends StatelessWidget {
  final Widget primaryScreen;
  final Widget sidebar;
  final Widget? floatingActionButton;

  const DesktopLayout({
    super.key,
    required this.primaryScreen,
    required this.sidebar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                backgroundImagePath,
                fit: BoxFit.cover,
                color: Colors.green, // green overlay
                colorBlendMode:
                    BlendMode.multiply, // or BlendMode.overlay / screen / etc.
              ),
            ),
          ),

          Row(
            children: [
              sidebar,
              const SizedBox(width: 18),
              Expanded(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: primaryScreen,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
