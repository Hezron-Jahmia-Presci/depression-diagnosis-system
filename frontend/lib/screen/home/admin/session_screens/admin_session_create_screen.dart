import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/patient_service.dart';
import 'package:depression_diagnosis_system/service/lib/session_service.dart';

import '../../../../widget/widget_exporter.dart';

class AdminCreateSessionScreen extends StatefulWidget {
  const AdminCreateSessionScreen({super.key});

  @override
  State<AdminCreateSessionScreen> createState() =>
      _AdminCreateSessionScreenState();
}

class _AdminCreateSessionScreenState extends State<AdminCreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();

  final PatientService _patientService = PatientService();
  final SessionService _sessionService = SessionService();

  final _dateController = TextEditingController();
  final _patientStateAtRegistration = TextEditingController();
  final _sessionIssue = TextEditingController();
  final _descripiton = TextEditingController();
  final _nextSessionDate = TextEditingController();
  final _currentPatientPrescription = TextEditingController();

  List<Map<String, dynamic>> _patients = [];
  String? _selectedPatientId;

  List<Map<String, dynamic>> _previousSessions = [];
  String? _selectedSessionId;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _loadPreviousSessions();
  }

  Future<void> _loadPreviousSessions() async {
    try {
      final list = await _sessionService.getAllSessions();
      setState(() {
        _previousSessions = list;
      });
    } catch (_) {}
  }

  Future<void> _loadPatients() async {
    try {
      final list = await _patientService.getAllPatients();

      setState(() {
        _patients = list;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _currentPatientPrescription.dispose();
    _patientStateAtRegistration.dispose();
    _dateController.dispose();
    _descripiton.dispose();
    _nextSessionDate.dispose();
    _sessionIssue.dispose();
    super.dispose();
  }

  Future<void> _createSession() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPatientId == null) {
      ReusableSnackbarWidget.show(context, 'Please select a patient');
      return;
    }

    setState(() => _isSubmitting = true);

    final response = await _sessionService.createSession({
      'health_worker_id': int.parse(_selectedPatientId!),
      'patient_id': int.parse(_selectedPatientId!),
      'date': _dateController.text.trim(),
      'patient_state': _patientStateAtRegistration.text.trim(),
      'previous_session_id':
          _selectedPatientId != null ? int.tryParse(_selectedPatientId!) : null,

      'session_issue': _sessionIssue.text.trim(),
      'description': _descripiton.text.trim(),
      'next_session_date': _nextSessionDate.text.trim(),
      'current_prescription': _currentPatientPrescription.text.trim(),
    });

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (response['error'] == null) {
      ReusableSnackbarWidget.show(context, 'Session created successfully!');
    } else {
      final error = response['error'] ?? 'failed to create session';
      ReusableSnackbarWidget.show(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(55.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Create Session",
                  style: TextStyle(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                ReusableDropdownWidget(
                  selectedValue: _selectedPatientId,
                  items: _patients,
                  onChanged: (val) => setState(() => _selectedPatientId = val),
                  label: "Select Patient",
                  listItems: 'first_name',
                  secondListItem: 'last_name',
                ),
                const SizedBox(height: 16),

                ReusableDateTimePickerField(
                  controller: _dateController,
                  label: 'Session Date',
                ),
                const SizedBox(height: 16),

                ReusableDropdownWidget(
                  selectedValue: _selectedSessionId,
                  items: _previousSessions,
                  onChanged: (val) => setState(() => _selectedSessionId = val),
                  label: "Select a previous session if any",
                  listItems: 'first_name',
                ),
                const SizedBox(height: 16),

                ReusableTextFieldWidget(
                  controller: _patientStateAtRegistration,
                  label: 'Patient State',
                  autofillHints: [],
                  maxLines: 1,
                ),
                const SizedBox(height: 16),

                ReusableTextFieldWidget(
                  controller: _sessionIssue,
                  label: 'Current Issue at Hand',
                  autofillHints: [],
                  maxLines: 1,
                ),
                const SizedBox(height: 16),

                ReusableTextFieldWidget(
                  controller: _descripiton,
                  label: 'Description',
                  autofillHints: [],
                  maxLines: 1,
                ),
                const SizedBox(height: 16),

                ReusableDateTimePickerField(
                  controller: _nextSessionDate,
                  label: 'Schedule follow up Session',
                ),
                const SizedBox(height: 16),

                ReusableTextFieldWidget(
                  controller: _currentPatientPrescription,
                  label: 'Current Patient Prescription',
                  autofillHints: [],
                  maxLines: 1,
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
        ),
      ),
    );
  }
}
