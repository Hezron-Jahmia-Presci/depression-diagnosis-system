import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../widget/widget_exporter.dart';
import '../../../service/patient_service.dart' show PatientService;
import '../../../service/session_service.dart' show SessionService;

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();

  final SessionService _sessionService = SessionService();
  final PatientService _patientService = PatientService();
  final _dateController = TextEditingController();
  List<dynamic>? _patients;
  String? _selectedPatientId;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      final patients = await _patientService.getPatientsByPsychiatrist();
      if (patients != null) {
        setState(() {
          _patients = patients;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _createSession() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      final sessionData = {
        'patientID': int.parse(_selectedPatientId!),
        'date': _dateController.text.trim(),
      };

      await _sessionService.createSession(sessionData);
      setState(() {
        _isSubmitting = false;
      });
      ReusableSnackbarWidget.show(context, 'Session created successfully!');
      Navigator.pop(context);
    }
  }

  Future<void> _selectDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && mounted) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (pickedTime != null && mounted) {
        setState(() {
          DateTime selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _dateController.text = _formatDateTime(selectedDateTime);
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    return formatter.format(dateTime.toUtc());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "CREATE SESSION",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 13),
        child: Form(
          key: _formKey,
          child: Center(
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width / 2,
              height: MediaQuery.sizeOf(context).height / 1.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _hasError
                      ? Center(child: Text('Error fetching details'))
                      : ReusableDropdownWidget(
                        selectedValue: _selectedPatientId,
                        items: (_patients ?? []).cast<Map<String, dynamic>>(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPatientId = value;
                          });
                        },
                        label: "Select Patient",
                        validator:
                            (value) =>
                                value == null ? "Patient is required ⛔" : null,
                      ),

                  const SizedBox(height: 13),

                  ReusableTextFieldWidget(
                    controller: _dateController,
                    label: "Select Date and Time",
                    obscureText: false,
                    keyboardType: TextInputType.datetime,
                    validator:
                        (value) =>
                            value!.isEmpty
                                ? "Date and time are required ⛔"
                                : null,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDateTime(),
                    ),
                    readOnly: true,
                  ),

                  const SizedBox(height: 13),

                  if (_dateController.text.isNotEmpty)
                    Text(
                      "Selected DateTime (RFC3339): ${_dateController.text}",
                      style: const TextStyle(fontSize: 18),
                    ),

                  if (_selectedPatientId != null)
                    Text(
                      "Selected Patient is : $_selectedPatientId",
                      style: const TextStyle(fontSize: 18),
                    ),

                  const SizedBox(height: 24),

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
      ),
    );
  }
}
