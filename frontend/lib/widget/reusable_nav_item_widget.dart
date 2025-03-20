import 'package:flutter/material.dart';
import 'package:frontend/widget/widget_exporter.dart' show ReusableCardWidget;

class ReusablenavitemWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget screen;
  final Function(Widget) onItemSelected;
  final Color textColor;
  const ReusablenavitemWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.screen,
    required this.onItemSelected,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableCardWidget(
      child: ListTile(
        leading: Icon(icon, color: textColor),
        title: Text(title, style: TextStyle(color: textColor)),
        onTap: () => onItemSelected(screen),
      ),
    );
  }
}
