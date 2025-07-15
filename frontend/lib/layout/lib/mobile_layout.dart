import 'package:depression_diagnosis_system/constants/layout_constant.dart';
import 'package:flutter/material.dart';

class MobileLayout extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onNavTap;
  final Widget screen;
  final List<BottomNavigationBarItem> navigationItems;
  final Widget? floatingActionButton;

  const MobileLayout({
    super.key,
    required this.selectedIndex,
    required this.onNavTap,
    required this.screen,
    required this.navigationItems,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                color: Colors.green,
                colorBlendMode:
                    BlendMode.multiply, // or BlendMode.overlay / screen / etc.
              ),
            ),
          ),

          Padding(padding: const EdgeInsets.all(24.0), child: screen),
        ],
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: SizedBox(
        height: 94,
        child: BottomNavigationBar(
          selectedItemColor: colorScheme.primary,
          currentIndex: selectedIndex,
          onTap: onNavTap,
          items: navigationItems,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
