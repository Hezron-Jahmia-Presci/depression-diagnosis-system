import 'package:flutter/material.dart';

import '../../../service/patient_service.dart' show PatientService;
import '../../../widget/widget_exporter.dart' show ReusableCardWidget;
import '../home_screen.dart' show HomeScreen;
import 'patient_details_creen.dart' show PatientDetailsScreen;
import 'register_patient_screen.dart' show RegisterPatientScreen;

class PatientScreen extends StatefulWidget {
  const PatientScreen({super.key});

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  final PatientService _patientService = PatientService();
  List<dynamic>? _patients;
  bool _isLoading = true;
  bool _hasError = false;

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

  void _navigateToCreatePatientScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPatientScreen()),
    );
  }

  void _navigateToPatientDetailsScreen(int patientID) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailsScreen(patientID: patientID),
      ),
    );
  }

  void _navigateToDashboardDetailsScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'PATIENTS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: _navigateToDashboardDetailsScreen,
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
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _patients!.isEmpty
                        ? const Center(child: Text('No patients found'))
                        : _buildPatientList(),
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreatePatientScreen,
        icon: const Icon(Icons.edit_note_outlined),
        label: const Text("Register Patient"),
      ),
    );
  }

  Widget _buildPatientList() {
    return ListView.builder(
      itemCount: _patients!.length,
      itemBuilder: (context, index) {
        final patient = _patients![index];
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
