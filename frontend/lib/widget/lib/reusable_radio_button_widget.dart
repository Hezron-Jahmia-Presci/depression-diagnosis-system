import 'package:flutter/material.dart';

class ReusableRadioButtonWidget extends StatelessWidget {
  final int selectedStatus;
  final List<int> options;
  final ValueChanged<int?> onChanged;
  final Map<int, String>? statusMap;

  const ReusableRadioButtonWidget({
    super.key,
    required this.selectedStatus,
    required this.options,
    required this.onChanged,
    this.statusMap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:
          options.map((status) {
            bool isSelected = selectedStatus == status;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => onChanged(status),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isSelected
                                ? colorScale[status - 1]
                                : colorScale[status - 1].withAlpha(35),
                        border: Border.all(
                          color:
                              isSelected
                                  ? colorScale[status - 1]
                                  : colorScale[status - 1].withAlpha(155),
                          width: 2.0,
                        ),
                      ),
                      width: 32.0,
                      height: 32.0,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    statusMap?[status] ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected
                              ? colorScale[status - 1]
                              : colorScale[status - 1].withAlpha(155),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}

final List<Color> colorScale = [
  Colors.red, // 1
  Colors.orange, // 2
  Colors.grey, // 3 (neutral)
  Colors.lightGreen, // 4
  Colors.green, // 5 (deep green)
];
