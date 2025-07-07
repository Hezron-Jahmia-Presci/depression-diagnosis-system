// lib/layout/lib/desktop_layout.dart

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
      body: Row(
        children: [
          sidebar,
          const SizedBox(width: 18),
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: primaryScreen,
            ),
          ),
        ],
      ),
      floatingActionButton: this.floatingActionButton,
    );
  }
}
