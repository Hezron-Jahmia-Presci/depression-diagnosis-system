import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:depression_diagnosis_system/service/lib/patient_service.dart';
import '../../../../widget/widget_exporter.dart';
import '../../../screens_exporter.dart';

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
  List<dynamic> _medicationHistories = [];

  bool _isLoading = true;
  bool _hasError = false;
  int? _selectedPatientID;

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
        _medicationHistories = details?['medication_histories'] ?? [];
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

  Future<bool?> _showConfirmationDialog(BuildContext context, String message) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Action'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
  }

  void _openEditScreen(int id) {
    setState(() => _selectedPatientID = id);
  }

  void _goBackToDetails() {
    setState(() => _selectedPatientID = null);
    _fetchPatientDetails(); // refresh after edit
  }

  String formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(date));
    } catch (_) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_hasError || _patientDetails == null) {
      return const Center(child: Text('Error fetching patient details'));
    }

    if (_selectedPatientID != null) {
      return EditPatientDetailsScreen(
        patientId: _selectedPatientID!,
        onBack: _goBackToDetails,
      );
    }

    final patient = _patientDetails!;
    final imageUrl = patient['image_url']?.toString() ?? '';

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: widget.onBack,
            ),
            const Text(
              'Patient Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),

        const SizedBox(height: 55),

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Avatar & Button
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 33.0),
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 128,
                          backgroundImage:
                              imageUrl.isNotEmpty
                                  ? NetworkImage(imageUrl)
                                  : null,
                          child:
                              imageUrl.isEmpty
                                  ? const Icon(Icons.person, size: 60)
                                  : null,
                        ),

                        const SizedBox(height: 16),

                        Text(
                          '${patient['first_name']} ${patient['last_name']}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(patient['patient_code'] ?? 'No Code'),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ReusableButtonWidget(
                            text: 'Edit Details',
                            isLoading: false,
                            onPressed: () => _openEditScreen(patient['ID']),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ReusableButtonWidget(
                            text:
                                patient['is_active'] == true
                                    ? 'Deactivate'
                                    : 'Activate',
                            backgroundColor:
                                patient['is_active'] == true
                                    ? colorScheme.secondary
                                    : colorScheme.tertiary,
                            onPressed: () async {
                              final confirm = await _showConfirmationDialog(
                                context,
                                patient['is_active'] == true
                                    ? 'Are you sure you want to deactivate this account?'
                                    : 'Are you sure you want to activate this account?',
                              );
                              if (confirm == true) {
                                final result = await _patientService
                                    .setActiveStatus(
                                      patient['ID'],
                                      !(patient['is_active'] == true),
                                    );
                                if (context.mounted) {
                                  final msg =
                                      result?['message'] ??
                                      result?['error'] ??
                                      'Failed';
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(SnackBar(content: Text(msg)));
                                }
                                _fetchPatientDetails();
                              }
                            },
                            isLoading: _isLoading,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (patient['is_active'] == false)
                          SizedBox(
                            width: double.infinity,
                            child: ReusableButtonWidget(
                              text: 'Delete Health Worker',
                              backgroundColor: colorScheme.error,
                              onPressed: () async {
                                final confirm = await _showConfirmationDialog(
                                  context,
                                  'Are you sure you want to permanently delete this health worker?',
                                );
                                if (confirm == true) {
                                  final success = await _patientService
                                      .deletePatient(patient['ID']);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          success
                                              ? 'Deleted successfully'
                                              : 'Failed to delete health worker',
                                        ),
                                      ),
                                    );
                                    if (success) widget.onBack();
                                  }
                                }
                              },
                              isLoading: _isLoading,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 55),

                    const Text(
                      'Medication History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ..._medicationHistories.map(
                      (med) => ReusableCardWidget(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailLine(
                              'Prescription',
                              med['prescription'],
                            ),
                            _buildDetailLine(
                              'Prescribing Doctor',
                              med['prescribing_doctor'] != null
                                  ? '${med['prescribing_doctor']['first_name']} ${med['prescribing_doctor']['last_name']}'
                                  : 'N/A',
                            ),
                            _buildDetailLine(
                              'External Doctor',
                              med['external_doctor_name'],
                            ),
                            _buildDetailLine(
                              'External Doctor Contact',
                              med['external_doctor_contact'],
                            ),
                            _buildDetailLine(
                              'Health Center',
                              med['health_center'],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 34),

              // Right: Patient Details
              Expanded(
                flex: 2,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 33),
                  children: [
                    _buildDetailTile('Email', patient['email']),
                    _buildDetailTile('Contact', patient['contact']),
                    _buildDetailTile('Address', patient['address']),
                    _buildDetailTile('Gender', patient['gender']),
                    _buildDetailTile(
                      'Date of Birth',
                      formatDate(patient['date_of_birth']),
                    ),
                    _buildDetailTile('National ID', patient['national_id']),
                    _buildDetailTile(
                      'Patient Description',
                      patient['description'],
                    ),
                    _buildDetailTile(
                      'Admission Date',
                      formatDate(patient['admission_date']),
                    ),
                    _buildDetailTile(
                      'Department',
                      patient['department']?['name'],
                    ),
                    _buildDetailTile(
                      'Admitted By',
                      patient['admitted_by'] != null
                          ? '${patient['admitted_by']['first_name']} ${patient['admitted_by']['last_name']}'
                          : null,
                    ),

                    _buildDetailTile(
                      'Previous Diagnosis',
                      patient['previous_diagnosis'],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailTile(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ReusableCardWidget(child: Text('$title: ${value ?? 'N/A'}')),
    );
  }

  Widget _buildDetailLine(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value?.isNotEmpty == true ? value! : 'N/A')),
        ],
      ),
    );
  }
}
