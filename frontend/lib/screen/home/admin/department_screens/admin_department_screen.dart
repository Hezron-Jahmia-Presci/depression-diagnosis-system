import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/department_service.dart';
import '../../../../widget/widget_exporter.dart';
import '../../../screens_exporter.dart';

class AdminDepartmentScreen extends StatefulWidget {
  final void Function(bool isVisible)? onFabVisibilityChanged;

  const AdminDepartmentScreen({super.key, this.onFabVisibilityChanged});

  @override
  State<AdminDepartmentScreen> createState() => AdminDepartmentScreenState();
}

class AdminDepartmentScreenState extends State<AdminDepartmentScreen> {
  final DepartmentService _departmentService = DepartmentService();

  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _filteredDepartments = [];

  bool _isLoading = true;
  bool _hasError = false;
  int? _selectedDepartmentID;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDepartments();
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDepartments() async {
    try {
      final fetched = await _departmentService.getAllDepartments();
      setState(() {
        _departments = fetched;
        _filteredDepartments = fetched;
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
        _departments.where((dept) {
          final name = (dept['name'] ?? '').toLowerCase();
          return name.contains(lowerQuery);
        }).toList();

    setState(() {
      _filteredDepartments = filtered;
    });
  }

  Future<void> reload() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _selectedDepartmentID = null;
    });
    await _loadDepartments();
  }

  void _openDepartmentDetails(int id) {
    widget.onFabVisibilityChanged?.call(false); // 👈 hide FAB
    setState(() {
      _selectedDepartmentID = id;
    });
  }

  void _goBackToList() {
    widget.onFabVisibilityChanged?.call(true); // 👈 show FAB
    setState(() {
      _selectedDepartmentID = null;
    });
  }

  void resetToListView() {
    if (_selectedDepartmentID != null) {
      _goBackToList();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_hasError) {
      return const Center(child: Text('Error fetching departments'));
    }

    if (_selectedDepartmentID != null) {
      return AdminDepartmentDetailsScreen(
        departmentID: _selectedDepartmentID!,
        onBack: _goBackToList,
      );
    }

    if (_departments.isEmpty) {
      return const Center(child: Text('No departments available'));
    }

    return Column(
      children: [
        ReusableSearchBarWidget(
          controller: _searchController,
          label: 'Search by name',
        ),

        SizedBox(height: 55),

        Expanded(
          child: ListView.separated(
            itemCount: _filteredDepartments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final dept = _filteredDepartments[index];

              return ReusableCardWidget(
                child: ListTile(
                  title: Text(dept['name'] ?? 'Unnamed Department'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () => _openDepartmentDetails(dept['ID']),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
