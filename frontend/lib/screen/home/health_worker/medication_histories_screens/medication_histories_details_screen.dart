import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:depression_diagnosis_system/service/lib/patient_service.dart';
import '../../../../widget/widget_exporter.dart';

class MedicationHistoriesDetailsScreen extends StatefulWidget {
  final int patientID;
  final VoidCallback onBack;

  const MedicationHistoriesDetailsScreen({
    super.key,
    required this.patientID,
    required this.onBack,
  });

  @override
  State<MedicationHistoriesDetailsScreen> createState() =>
      _MedicationHistoriesDetailsScreenState();
}

class _MedicationHistoriesDetailsScreenState
    extends State<MedicationHistoriesDetailsScreen> {
  final PatientService _patientService = PatientService();

  Map<String, dynamic>? _patient;
  List<dynamic> _medicationHistories = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final patient = await _patientService.getPatientByID(widget.patientID);
      setState(() {
        _patient = patient;
        _medicationHistories = patient?['medication_histories'] ?? [];
        _isLoading = false;
        _hasError = patient == null;
      });
    } catch (_) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  String formatDate(String? rawDate) {
    if (rawDate == null) return 'Unknown date';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(rawDate));
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_hasError || _patient == null) {
      return const Center(child: Text('Failed to load medical history.'));
    }

    final imageUrl = _patient!['image_url'] ?? '';
    final fullName = '${_patient!['first_name']} ${_patient!['last_name']}';
    final patientCode = _patient!['patient_code'] ?? 'No Code';

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: widget.onBack,
            ),
            const Text(
              'Patient\'s Medication History Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),

        const SizedBox(height: 55),

        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    ReusableCardWidget(
                      child: Column(
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
                            fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Patient Code: $patientCode'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 34),

              Expanded(
                flex: 2,
                child: ListView(
                  children: [
                    // Medical history list
                    if (_medicationHistories.isEmpty)
                      ReusableCardWidget(
                        child: const Text('No medical history found.'),
                      )
                    else
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
            ],
          ),
        ),
      ],
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
