// lib/layout/widgets/adaptive_sidebar.dart

import 'package:flutter/material.dart';
import '../../widget/widget_exporter.dart';

class AdaptiveSidebar extends StatelessWidget {
  final bool isCompact;
  final void Function(int) onItemSelected;
  final VoidCallback onLogout;
  final ColorScheme colorScheme;
  final Map<String, dynamic>? userDetails;
  final bool isLoading;
  final bool hasError;
  final bool showProfileButton;
  final VoidCallback? onProfileTap;
  final List<SidebarNavItem> navigationItems;

  const AdaptiveSidebar({
    super.key,
    required this.isCompact,
    required this.onItemSelected,
    required this.onLogout,
    required this.colorScheme,
    required this.userDetails,
    required this.isLoading,
    required this.hasError,
    this.onProfileTap,
    this.showProfileButton = true,
    required this.navigationItems,
  });

  @override
  Widget build(BuildContext context) {
    final username =
        userDetails != null
            ? '${userDetails!['first_name'] ?? ''} ${userDetails!['last_name'] ?? ''}'
                .trim()
            : 'Loading...';

    return ReusableCardWidget(
      child: Container(
        width: isCompact ? 72 : 300,
        padding: const EdgeInsets.symmetric(vertical: 21, horizontal: 16),
        child: Column(
          children: [
            if (!isCompact)
              ...navigationItems.map(
                (item) => ReusableNavItemWidget(
                  icon: item.icon,
                  title: item.title,
                  screen: item.screen,
                  onItemSelected: (_) => onItemSelected(item.index),
                  textColor: colorScheme.primary,
                  isCompact: isCompact,
                ),
              ),

            // Optionally, you can add a spacer and profile/logout buttons here
            if (!isCompact && showProfileButton)
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.account_circle),
                        title: Text(username),
                        onTap: onProfileTap,
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Logout'),
                        onTap: onLogout,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SidebarNavItem {
  final int index;
  final IconData icon;
  final String title;
  final Widget screen;

  SidebarNavItem({
    required this.index,
    required this.icon,
    required this.title,
    required this.screen,
  });
}
