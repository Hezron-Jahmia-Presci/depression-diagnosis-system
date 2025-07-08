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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: screen,
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
