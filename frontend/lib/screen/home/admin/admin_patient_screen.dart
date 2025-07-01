import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/patient_service.dart';
import '../../../widget/widget_exporter.dart';
import '../../screens_exporter.dart';

class AdminPatientScreen extends StatefulWidget {
  const AdminPatientScreen({super.key});

  @override
  State<AdminPatientScreen> createState() => _AdminPatientScreenState();
}

class _AdminPatientScreenState extends State<AdminPatientScreen> {
  final PatientService _patientService = PatientService();
  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = true;
  bool _hasError = false;
  int? _selectedPatientID;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      final fetched = await _patientService.getAllPatients();
      setState(() {
        _patients = fetched;
        _hasError = fetched.isEmpty;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> reload() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _selectedPatientID = null;
    });
    await _loadPatients();
  }

  void _openPatientDetails(int patientID) {
    setState(() {
      _selectedPatientID = patientID;
    });
  }

  void _goBackToList() {
    setState(() {
      _selectedPatientID = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return const Center(child: Text("Error fetching patients"));
    }

    if (_selectedPatientID != null) {
      return PatientDetailsScreen(
        patientID: _selectedPatientID!,
        onBack: _goBackToList,
      );
    }

    if (_patients.isEmpty) {
      return const Center(child: Text("No patients available"));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 13),
      itemCount: _patients.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final patient = _patients[index];
        return ReusableCardWidget(
          child: ListTile(
            title: Text(
              "${patient['first_name'] ?? ''} ${patient['last_name'] ?? ''}",
            ),
            subtitle: Text("Email: ${patient['email'] ?? 'N/A'}"),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: () => _openPatientDetails(patient['ID']),
          ),
        );
      },
    );
  }
}
