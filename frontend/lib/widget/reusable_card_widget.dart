import 'package:flutter/material.dart';

class ReusableCardWidget extends StatelessWidget {
  final Widget child;

  const ReusableCardWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      shadowColor: colorScheme.primaryContainer.withAlpha(100),
      color: colorScheme.onPrimary,
      margin: const EdgeInsets.only(bottom: 21),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: const EdgeInsets.all(13), child: child),
    );
  }
}
