import 'package:flutter/material.dart';
import '../../../../service/patient_service.dart' show PatientService;
import '../../../../widget/widget_exporter.dart' show ReusableCardWidget;
import '../../psychiatrist/patient_screens/patient_details_creen.dart'
    show PatientDetailsScreen;

class PatientScreen extends StatefulWidget {
  const PatientScreen({super.key});

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  final PatientService _patientService = PatientService();
  List<Map<String, dynamic>>? _patientDetails;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchPatientDetails();
  }

  Future<void> _fetchPatientDetails() async {
    try {
      final details = await _patientService.getAllPatients();
      if (details != null && details.isNotEmpty) {
        setState(() {
          _patientDetails = List<Map<String, dynamic>>.from(details);
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

  void _navigateToPatientDetailsScreen(int patientID) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailsScreen(patientID: patientID),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _hasError
        ? Center(child: Text('Error fetching details'))
        : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 13),
          child:
              _patientDetails != null && _patientDetails!.isNotEmpty
                  ? _buildPatientList()
                  : const Center(child: Text('No patients available')),
        );
  }

  Widget _buildPatientList() {
    return ListView.builder(
      itemCount: _patientDetails!.length,
      itemBuilder: (context, index) {
        final patient = _patientDetails![index];
        return ReusableCardWidget(
          child: ListTile(
            title: Text(
              "${patient['first_name'] ?? ''} ${patient['last_name'] ?? ''}",
            ),
            subtitle: Text("Email: ${patient['email'] ?? ''}"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _navigateToPatientDetailsScreen(patient['ID']),
          ),
        );
      },
    );
  }
}
