import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/patient_service.dart';
import '../../../../widget/widget_exporter.dart';

class PatientDetailsScreen extends StatefulWidget {
  final int patientID;
  final VoidCallback onBack;

  const PatientDetailsScreen({
    super.key,
    required this.patientID,
    required this.onBack,
  });

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final PatientService _patientService = PatientService();
  Map<String, dynamic>? _patientDetails;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchPatientDetails();
  }

  Future<void> _fetchPatientDetails() async {
    try {
      final details = await _patientService.getPatientByID(widget.patientID);
      setState(() {
        _patientDetails = details;
        _hasError = details == null;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_hasError || _patientDetails == null) {
      return const Center(child: Text('Error fetching patient details'));
    }

    final patient = _patientDetails!;

    return ListView(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: widget.onBack,
            ),
            const Text(
              'Patient Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ReusableCardWidget(
          child: Text('First Name: ${patient['first_name'] ?? 'N/A'}'),
        ),
        const SizedBox(height: 12),
        ReusableCardWidget(
          child: Text('Last Name: ${patient['last_name'] ?? 'N/A'}'),
        ),
        const SizedBox(height: 12),
        ReusableCardWidget(child: Text('Email: ${patient['email'] ?? 'N/A'}')),
      ],
    );
  }
}
