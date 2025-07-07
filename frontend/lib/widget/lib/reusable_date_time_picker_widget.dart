import 'package:depression_diagnosis_system/widget/widget_exporter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReusableDateTimePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool requiredUtc;
  final String dateFormat;
  final void Function(DateTime)? onDateTimeChanged;

  const ReusableDateTimePickerField({
    super.key,
    required this.controller,
    required this.label,
    this.requiredUtc = true,
    this.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'",
    this.onDateTimeChanged,
  });

  Future<void> _selectDateTime(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && context.mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null && context.mounted) {
        final selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        final finalDateTime =
            requiredUtc ? selectedDateTime.toUtc() : selectedDateTime;

        controller.text = DateFormat(dateFormat).format(finalDateTime);

        if (onDateTimeChanged != null) {
          onDateTimeChanged!(finalDateTime);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReusableTextFieldWidget(
      controller: controller,
      readOnly: true,
      keyboardType: TextInputType.datetime,
      suffixIcon: IconButton(
        icon: const Icon(Icons.calendar_today),
        onPressed: () => _selectDateTime(context),
      ),
      validator:
          (val) =>
              val == null || val.isEmpty
                  ? "Date and time are required ⛔"
                  : null,
      autofillHints: const [],

      label: label,
    );
  }
}
