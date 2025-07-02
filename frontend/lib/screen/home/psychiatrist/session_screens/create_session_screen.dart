import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:depression_diagnosis_system/service/lib/patient_service.dart';
import 'package:depression_diagnosis_system/service/lib/session_service.dart';

import '../../../../widget/widget_exporter.dart';

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sessionService = SessionService();
  final _patientService = PatientService();

  final _dateController = TextEditingController();
  String? _selectedPatientId;
  List<Map<String, dynamic>> _patients = [];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      final patients = await _patientService.getPatientsByPsychiatrist();

      setState(() {
        _patients = patients.cast<Map<String, dynamic>>();
      });
    } catch (_) {}
  }

  Future<void> _selectDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null && mounted) {
        final selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        _dateController.text = DateFormat(
          "yyyy-MM-dd'T'HH:mm:ss'Z'",
        ).format(selectedDateTime.toUtc());
      }
    }
  }

  Future<void> _createSession() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final sessionData = {
      'patientID': int.parse(_selectedPatientId!),
      'date': _dateController.text.trim(),
    };

    final response = await _sessionService.createSession(sessionData);

    setState(() => _isSubmitting = false);

    if (response['error'] == null) {
      if (!mounted) return;
      ReusableSnackbarWidget.show(context, 'Session created successfully!');
      Navigator.pop(context, true);
    } else {
      ReusableSnackbarWidget.show(
        context,
        response['error'] ?? 'Failed to create session',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(55.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Create Session",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ReusableDropdownWidget(
              selectedValue: _selectedPatientId,
              items: _patients,
              onChanged: (val) => setState(() => _selectedPatientId = val),
              label: "Select Patient",
              validator: (val) => val == null ? "Patient is required ⛔" : null,
            ),
            const SizedBox(height: 24),
            ReusableTextFieldWidget(
              controller: _dateController,
              label: "Select Date and Time",
              keyboardType: TextInputType.datetime,
              readOnly: true,
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _selectDateTime,
              ),
              validator:
                  (val) =>
                      val == null || val.isEmpty
                          ? "Date and time are required ⛔"
                          : null,
              autofillHints: const [],
            ),
            const SizedBox(height: 33),
            ReusableButtonWidget(
              isLoading: _isSubmitting,
              onPressed: _createSession,
              text: "Create Session",
            ),
          ],
        ),
      ),
    );
  }
}
