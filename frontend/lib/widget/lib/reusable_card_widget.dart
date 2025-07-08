import 'package:flutter/material.dart';

class ReusableCardWidget extends StatelessWidget {
  final Widget child;
  final bool addSpaceAfter;

  const ReusableCardWidget({
    super.key,
    required this.child,
    this.addSpaceAfter = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin:
          addSpaceAfter
              ? const EdgeInsets.only(bottom: 21)
              : const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.3),
            blurRadius: 24,
            spreadRadius: 5,
            offset: const Offset(0, 13),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(24), child: child),
    );
  }
}
