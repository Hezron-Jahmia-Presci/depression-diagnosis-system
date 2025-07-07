import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/department_service.dart';
import '../../../../../widget/widget_exporter.dart';
import '../../../screens_exporter.dart';

class AdminDepartmentDetailsScreen extends StatefulWidget {
  final int departmentID;
  final VoidCallback onBack;

  const AdminDepartmentDetailsScreen({
    super.key,
    required this.departmentID,
    required this.onBack,
  });

  @override
  State<AdminDepartmentDetailsScreen> createState() =>
      _AdminDepartmentDetailsScreenState();
}

class _AdminDepartmentDetailsScreenState
    extends State<AdminDepartmentDetailsScreen> {
  final DepartmentService _departmentService = DepartmentService();

  Map<String, dynamic>? _departmentDetails;
  bool _isLoading = true;
  bool _hasError = false;
  int? _selectedDepartmentID;
  int? _selectedHealthWorkerID;

  @override
  void initState() {
    super.initState();
    _loadDepartmentDetails();
  }

  Future<void> _loadDepartmentDetails() async {
    try {
      final all = await _departmentService.getAllDepartments();
      final selected = all.firstWhere(
        (d) => d['ID'] == widget.departmentID,
        orElse: () => {},
      );
      print(all);
      setState(() {
        _departmentDetails = selected.isNotEmpty ? selected : null;
        _hasError = _departmentDetails == null;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _goToEditScreen(int id) {
    setState(() => _selectedDepartmentID = id);
  }

  void _goBackToDetails() {
    setState(() => _selectedDepartmentID = null);
    _loadDepartmentDetails(); // Optional: refresh after edit
  }

  void _openHealthWorkerDetails(int id) {
    setState(() {
      _selectedHealthWorkerID = id;
    });
  }

  void _goBackToList() {
    setState(() {
      _selectedHealthWorkerID = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_hasError || _departmentDetails == null) {
      return const Center(child: Text('Error fetching department details'));
    }

    if (_selectedDepartmentID != null) {
      return AdminEditDepartmentDetailsScreen(
        departmentID: _selectedDepartmentID!,
        onBack: _goBackToDetails,
      );
    }
    if (_selectedHealthWorkerID != null) {
      return HealthWorkerDetailsScreen(
        healthWorkerID: _selectedHealthWorkerID!,
        onBack: _goBackToList,
      );
    }

    final dept = _departmentDetails!;

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: widget.onBack,
            ),
            const Text(
              'Department Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),

        const SizedBox(height: 55),

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 33),
                  children: [
                    ReusableCardWidget(
                      child: Column(
                        children: [
                          Text(
                            dept['name'],
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(dept['description']),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ReusableButtonWidget(
                      text: 'Edit Details',
                      isLoading: false,
                      onPressed: () => _goToEditScreen(dept['ID']),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              const SizedBox(width: 34),

              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _sectionHeader(
                      "Department Health Workers",
                      Icons.info_outline,
                    ),
                    Expanded(
                      child:
                          (dept['health_workers'] != null &&
                                  (dept['health_workers'] as List).isNotEmpty)
                              ? ListView.builder(
                                itemCount:
                                    (dept['health_workers'] as List).length,
                                itemBuilder: (context, index) {
                                  final hw = dept['health_workers'][index];

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: ReusableCardWidget(
                                      child: ListTile(
                                        title: Text(
                                          "${hw['first_name'] ?? ''} ${hw['last_name'] ?? ''}",
                                        ),
                                        subtitle: Text(
                                          "Employee ID: ${hw['employee_id'] ?? 'N/A'}",
                                        ),
                                        leading: const Icon(Icons.person),
                                        trailing: const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                        ),
                                        onTap:
                                            () => _openHealthWorkerDetails(
                                              hw['ID'],
                                            ),
                                      ),
                                    ),
                                  );
                                },
                              )
                              : const Text(
                                'No health workers found in this department.',
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

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
