import 'package:flutter/material.dart';

class ReusableSearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String label;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;

  const ReusableSearchBarWidget({
    super.key,
    required this.controller,
    required this.label,
    this.hintText = 'Search...',
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 31.0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          label: Text(label),
          fillColor: colorScheme.onPrimary,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          prefixIcon: Icon(Icons.search, color: colorScheme.primary),
          suffixIcon:
              controller.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: colorScheme.error),
                    onPressed: () {
                      controller.clear();
                      onClear?.call();
                    },
                  )
                  : null,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.tertiary),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.secondaryContainer,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
