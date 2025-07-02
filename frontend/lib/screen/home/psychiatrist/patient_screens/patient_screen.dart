import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/patient_service.dart';
import '../../../../widget/widget_exporter.dart';
import '../../../screens_exporter.dart';

class PatientScreen extends StatefulWidget {
  final void Function(bool isVisible)? onFabVisibilityChanged;

  const PatientScreen({super.key, this.onFabVisibilityChanged});

  @override
  State<PatientScreen> createState() => PatientScreenState();
}

class PatientScreenState extends State<PatientScreen> {
  final _patientService = PatientService();
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
      final patients = await _patientService.getPatientsByPsychiatrist();
      setState(() {
        _patients = patients;
        _hasError = false;
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

  void _navigateToPatientDetailsScreen(int patientID) {
    widget.onFabVisibilityChanged?.call(false); // 👈 hide FAB
    setState(() => _selectedPatientID = patientID);
  }

  void _goBackToList() {
    widget.onFabVisibilityChanged?.call(true); // 👈 show FAB
    setState(() => _selectedPatientID = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return const Center(child: Text('Failed to fetch patients.'));
    }

    if (_selectedPatientID != null) {
      return PatientDetailsScreen(
        patientID: _selectedPatientID!,
        onBack: _goBackToList,
      );
    }

    if (_patients.isEmpty) {
      return const Center(
        child: Text('No patients found. Tap the "+" button to add one.'),
      );
    }

    return ListView.separated(
      itemCount: _patients.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final patient = _patients[index];
        return ReusableCardWidget(
          child: ListTile(
            title: Text(
              "${patient['first_name'] ?? ''} ${patient['last_name'] ?? ''}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text("Email: ${patient['email'] ?? 'N/A'}"),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: () => _navigateToPatientDetailsScreen(patient['ID']),
          ),
        );
      },
    );
  }
}
