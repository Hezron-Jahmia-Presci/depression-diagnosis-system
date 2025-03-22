import 'package:flutter/material.dart';

import '../../../service/patient_service.dart' show PatientService;
import '../../../widget/widget_exporter.dart' show ReusableCardWidget;

class PatientDetailsScreen extends StatefulWidget {
  final int patientID;
  const PatientDetailsScreen({super.key, required this.patientID});

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
      final details = await _patientService.getPatientDetailsById(
        widget.patientID,
      );
      if (details != null) {
        setState(() {
          _patientDetails = details;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PATIENT DETAILS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _hasError
              ? Center(child: Text('Error fetching details'))
              : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 21,
                  vertical: 13,
                ),
                child:
                    _patientDetails != null
                        ? _buildPatientDetails(_patientDetails!)
                        : const Center(child: Text('No details available')),
              ),
    );
  }

  Widget _buildPatientDetails(Map<String, dynamic> patientData) {
    return Center(
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width / 2,
        height: MediaQuery.sizeOf(context).height / 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReusableCardWidget(
              child: Text('First Name: ${patientData['first_name'] ?? 'N/A'}'),
            ),
            const SizedBox(height: 10),
            ReusableCardWidget(
              child: Text('Last Name: ${patientData['last_name'] ?? 'N/A'}'),
            ),
            const SizedBox(height: 10),
            ReusableCardWidget(
              child: Text('Email: ${patientData['email'] ?? 'N/A'}'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
