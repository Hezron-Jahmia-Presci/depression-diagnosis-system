import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/patient_service.dart';
import '../../../../widget/widget_exporter.dart';
import '../../../screens_exporter.dart';

class AdminPatientScreen extends StatefulWidget {
  final void Function(bool isVisible)? onFabVisibilityChanged;
  const AdminPatientScreen({super.key, this.onFabVisibilityChanged});

  @override
  State<AdminPatientScreen> createState() => AdminPatientScreenState();
}

class AdminPatientScreenState extends State<AdminPatientScreen> {
  final PatientService _patientService = PatientService();

  List<Map<String, dynamic>> _patients = [];
  List<Map<String, dynamic>> _filteredPatients = [];

  bool _isLoading = true;
  bool _hasError = false;
  int? _selectedPatientID;

  final TextEditingController _searchController = TextEditingController();

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
      final fetched = await _patientService.getAllPatients();
      setState(() {
        _patients = fetched;
        _filteredPatients = fetched;
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

  void _onSearchChanged(String query) {
    final lowerQuery = query.toLowerCase();
    final filtered =
        _patients.where((patient) {
          final name =
              '${patient['first_name']} ${patient['last_name']}'.toLowerCase();
          final email = (patient['email'] ?? '').toLowerCase();
          final employeeID = (patient['patient_id'] ?? '').toLowerCase();
          return name.contains(lowerQuery) ||
              email.contains(lowerQuery) ||
              employeeID.contains(lowerQuery);
        }).toList();

    setState(() {
      _filteredPatients = filtered;
    });
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
    widget.onFabVisibilityChanged?.call(false); // 👈 hide FAB
    setState(() {
      _selectedPatientID = patientID;
    });
  }

  void _goBackToList() {
    widget.onFabVisibilityChanged?.call(true); // 👈 show FAB
    setState(() {
      _selectedPatientID = null;
    });
  }

  void resetToListView() {
    if (_selectedPatientID != null) {
      _goBackToList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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

    return Column(
      children: [
        ReusableSearchBarWidget(
          controller: _searchController,
          label: 'Search by name, email, or ID',
        ),

        SizedBox(height: 55),

        Expanded(
          child: ListView.separated(
            itemCount: _filteredPatients.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final patient = _filteredPatients[index];
              final imageUrl = patient['image_url']?.toString() ?? '';

              return ReusableCardWidget(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.onPrimary,
                    backgroundImage:
                        imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                    child:
                        imageUrl.isEmpty
                            ? Icon(
                              Icons.person_outline_rounded,
                              color: colorScheme.primary,
                            )
                            : null,
                  ),
                  title: Text(
                    "${patient['first_name'] ?? ''} ${patient['last_name'] ?? ''}",
                  ),
                  subtitle: Text(
                    "Patient ID: ${patient['patient_code'] ?? 'N/A'}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              (patient['is_active'] == true)
                                  ? Colors.green
                                  : Colors.grey,
                          border: Border.all(color: Colors.black26),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.arrow_forward_ios_rounded),
                    ],
                  ),

                  onTap: () => _openPatientDetails(patient['ID']),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
