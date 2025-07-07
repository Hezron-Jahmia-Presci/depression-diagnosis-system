import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/patient_service.dart';
import '../../../../widget/widget_exporter.dart';
import '../../../screens_exporter.dart';

class MedicationHistoryScreen extends StatefulWidget {
  final void Function(bool isVisible)? onFabVisibilityChanged;

  const MedicationHistoryScreen({super.key, this.onFabVisibilityChanged});

  @override
  State<MedicationHistoryScreen> createState() =>
      MedicationHistoryScreenState();
}

class MedicationHistoryScreenState extends State<MedicationHistoryScreen> {
  final PatientService _patientService = PatientService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _patients = [];
  List<Map<String, dynamic>> _filteredPatients = [];

  bool _isLoading = true;
  bool _hasError = false;
  int? _selectedPatientID;

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    try {
      final patients = await _patientService.getPatientsByHealthWorker();
      setState(() {
        _patients = patients;
        _filteredPatients = patients;
        _isLoading = false;
        _hasError = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _onSearchChanged(String query) {
    final lower = query.toLowerCase();
    final filtered =
        _patients.where((p) {
          final name = "${p['first_name']} ${p['last_name']}".toLowerCase();
          final code = (p['patient_code'] ?? '').toLowerCase();
          return name.contains(lower) || code.contains(lower);
        }).toList();

    setState(() => _filteredPatients = filtered);
  }

  Future<void> reload() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _selectedPatientID = null;
    });
    await _loadPatients();
  }

  void _navigateToMedicationHistoriesDetailsScreen(int patientID) {
    widget.onFabVisibilityChanged?.call(false); // Hide FAB
    setState(() => _selectedPatientID = patientID);
  }

  void _goBackToList() {
    widget.onFabVisibilityChanged?.call(true); // Show FAB
    setState(() => _selectedPatientID = null);
  }

  void resetToListView() {
    if (_selectedPatientID != null) {
      _goBackToList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_hasError) return const Center(child: Text('Error loading patients'));

    if (_selectedPatientID != null) {
      return MedicationHistoriesDetailsScreen(
        patientID: _selectedPatientID!,
        onBack: _goBackToList,
      );
    }

    if (_patients.isEmpty) {
      return const Center(child: Text("No patients available"));
    }

    return Column(
      children: [
        ReusableSearchBarWidget(
          controller: _searchController,
          label: 'Search by patient name or code',
        ),

        SizedBox(height: 55),

        Expanded(
          child: ListView.separated(
            itemCount: _filteredPatients.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final patient = _filteredPatients[index];
              final imageUrl = patient['image_url'] ?? '';

              return ReusableCardWidget(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.onPrimary,
                    backgroundImage:
                        imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                    child:
                        imageUrl.isEmpty
                            ? Icon(
                              Icons.person_outline,
                              color: colorScheme.primary,
                            )
                            : null,
                  ),
                  title: Text(
                    "${patient['first_name']} ${patient['last_name']}",
                  ),
                  subtitle: Text("Code: ${patient['patient_code'] ?? 'N/A'}"),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  onTap:
                      () => _navigateToMedicationHistoriesDetailsScreen(
                        patient['ID'],
                      ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
