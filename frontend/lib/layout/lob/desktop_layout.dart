// lib/layout/desktop_layout.dart

import 'package:flutter/material.dart';
import '../../constants/layout_constant.dart' show kSectionSpacing;
import '../../screen/screens_exporter.dart';
import '../../widget/widget_exporter.dart';

class DesktopLayout extends StatelessWidget {
  final Widget primaryScreen;
  final Function(int) onItemSelected;
  final ColorScheme colorScheme;
  final Map<String, dynamic>? psychiatristDetails;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onLogout;

  const DesktopLayout({
    super.key,
    required this.primaryScreen,
    required this.onItemSelected,
    required this.colorScheme,
    required this.psychiatristDetails,
    required this.isLoading,
    required this.hasError,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 1128;

    return Scaffold(
      body: Row(
        children: [
          AdaptiveSidebar(
            isCompact: isCompact,
            onItemSelected: onItemSelected,
            colorScheme: colorScheme,
            psychiatristDetails: psychiatristDetails,
            isLoading: isLoading,
            hasError: hasError,
            onLogout: onLogout,
          ),
          const SizedBox(width: kSectionSpacing),
          Expanded(
            flex: 7,
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : primaryScreen,
          ),
        ],
      ),
    );
  }
}

class AdaptiveSidebar extends StatelessWidget {
  final bool isCompact;
  final Function(int) onItemSelected;
  final VoidCallback onLogout;
  final ColorScheme colorScheme;
  final Map<String, dynamic>? psychiatristDetails;
  final bool isLoading;
  final bool hasError;

  const AdaptiveSidebar({
    super.key,
    required this.isCompact,
    required this.onItemSelected,
    required this.onLogout,
    required this.colorScheme,
    required this.psychiatristDetails,
    required this.isLoading,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final username =
        psychiatristDetails != null
            ? '${psychiatristDetails!['first_name']} ${psychiatristDetails!['last_name']}'
            : "Loading...";

    return Container(
      width: isCompact ? 72 : 300,
      color: colorScheme.surfaceContainer,
      padding: const EdgeInsets.symmetric(vertical: 21, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!isCompact)
            Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.person, size: 40),
                ),
                const SizedBox(height: 10),
                if (isLoading)
                  const CircularProgressIndicator()
                else if (hasError)
                  const Text('Error fetching details')
                else
                  Text(
                    username,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 24),
                ReusableButtonWidget(
                  isLoading: false,
                  onPressed: () {
                    if (psychiatristDetails != null) {
                      final id = psychiatristDetails!['ID'];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  PsychiatristDetailsScreen(psychiatristID: id),
                        ),
                      );
                    }
                  },
                  text: 'Profile',
                ),

                const SizedBox(height: 24),
                ReusableButtonWidget(
                  isLoading: false,
                  onPressed: onLogout,
                  text: 'Logout',
                  backgroundColor: colorScheme.tertiary,
                ),

                const Divider(height: 34),
              ],
            ),
          Expanded(
            child: Column(
              children: [
                ReusableNavItemWidget(
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  screen: const DashboardScreen(),
                  onItemSelected: (_) => onItemSelected(0),
                  textColor: colorScheme.primary,
                  isCompact: isCompact,
                ),
                ReusableNavItemWidget(
                  icon: Icons.person,
                  title: 'Patients',
                  screen: const PatientScreen(),
                  onItemSelected: (_) => onItemSelected(1),
                  textColor: colorScheme.primary,
                  isCompact: isCompact,
                ),
                ReusableNavItemWidget(
                  icon: Icons.event,
                  title: 'Sessions',
                  screen: const SessionScreen(),
                  onItemSelected: (_) => onItemSelected(2),
                  textColor: colorScheme.primary,
                  isCompact: isCompact,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
