import 'package:flutter/material.dart';

class ReusableRadioButtonWidget extends StatelessWidget {
  final String selectedStatus;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const ReusableRadioButtonWidget({
    super.key,
    required this.selectedStatus,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children:
          options.map((status) {
            return Row(
              children: [
                Radio<String>(
                  value: status,
                  groupValue: selectedStatus,
                  onChanged: onChanged,
                ),
                Text(status),
              ],
            );
          }).toList(),
    );
  }
}
