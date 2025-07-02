import 'package:flutter/material.dart';

class ReusableDropdownWidget extends StatelessWidget {
  final String? selectedValue;
  final List<Map<String, dynamic>> items;
  final Function(String?) onChanged;
  final String label;
  final String? Function(String?)? validator;

  const ReusableDropdownWidget({
    super.key,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    required this.label,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: colorScheme.onPrimary,
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items:
          items.map((item) {
            return DropdownMenuItem<String>(
              value: item['ID'].toString(),
              child: Text("${item['first_name']} ${item['last_name']}"),
            );
          }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
