import 'package:flutter/material.dart';

class MobileLayout extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onNavTap;
  final Widget screen;

  const MobileLayout({
    super.key,
    required this.selectedIndex,
    required this.onNavTap,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: screen,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: colorScheme.primary,
        currentIndex: selectedIndex,
        onTap: onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            activeIcon: Icon(Icons.person_2_rounded),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event_rounded),
            label: 'Sessions',
          ),
        ],
      ),
    );
  }
}
