import 'package:flutter/material.dart';

class ReusableNavItemWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget screen;
  final Function(Widget) onItemSelected;
  final Color textColor;

  const ReusableNavItemWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.screen,
    required this.onItemSelected,
    required this.textColor,
    required bool isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 1000;
    final tileWidth = isCompact ? 60.0 : double.infinity;

    return Padding(
      padding: EdgeInsets.only(bottom: 13.0),
      child: SizedBox(
        width: tileWidth,
        child: ListTile(
          leading: Icon(icon, color: textColor),
          title:
              isCompact
                  ? null
                  : Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          onTap: () => onItemSelected(screen),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isCompact ? 13.0 : 18.0,
          ),
        ),
      ),
    );
  }
}
