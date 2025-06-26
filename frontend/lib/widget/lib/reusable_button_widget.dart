import 'package:flutter/material.dart';

class ReusableButtonWidget extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String text;
  final Color? backgroundColor;

  const ReusableButtonWidget({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.text,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            shadowColor: colorScheme.secondary,
            elevation: 3,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 32),
            child: Text(text),
          ),
        );
  }
}
