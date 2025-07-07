import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/personnel_types_service.dart';
import '../../../../widget/widget_exporter.dart';
import '../../../screens_exporter.dart'; // Make sure EditPersonnelTypeScreen is exported here

class AdminPersonnelTypeScreen extends StatefulWidget {
  final void Function(bool isVisible)? onFabVisibilityChanged;
  const AdminPersonnelTypeScreen({super.key, this.onFabVisibilityChanged});

  @override
  State<AdminPersonnelTypeScreen> createState() =>
      AdminPersonnelTypeScreenState();
}

class AdminPersonnelTypeScreenState extends State<AdminPersonnelTypeScreen> {
  final PersonnelTypeService _personnelTypeService = PersonnelTypeService();

  List<Map<String, dynamic>> _personnelTypes = [];
  List<Map<String, dynamic>> _filteredPersonnelTypes = [];

  bool _isLoading = true;
  bool _hasError = false;
  int? _selectedPersonnelTypeID;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPersonnelTypes();
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
  }

  Future<void> _loadPersonnelTypes() async {
    try {
      final fetched = await _personnelTypeService.getAllPersonnelTypes();
      setState(() {
        _personnelTypes = fetched;
        _filteredPersonnelTypes = fetched;
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
        _personnelTypes.where((pt) {
          final name = (pt['name'] ?? '').toLowerCase();
          return name.contains(lowerQuery);
        }).toList();

    setState(() {
      _filteredPersonnelTypes = filtered;
    });
  }

  Future<void> reload() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _selectedPersonnelTypeID = null;
    });
    await _loadPersonnelTypes();
  }

  void _openEditScreen(int id) {
    widget.onFabVisibilityChanged?.call(false); // 👈 hide FAB
    setState(() {
      _selectedPersonnelTypeID = id;
    });
  }

  void _goBackToList() {
    widget.onFabVisibilityChanged?.call(true); // 👈 show FAB
    setState(() {
      _selectedPersonnelTypeID = null;
    });
  }

  void resetToListView() {
    if (_selectedPersonnelTypeID != null) {
      _goBackToList();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return const Center(child: Text("Error fetching personnel types"));
    }

    if (_selectedPersonnelTypeID != null) {
      return AdminEditPersonelTypesScreen(
        personnelTypeID: _selectedPersonnelTypeID!,
        onBack: _goBackToList,
      );
    }

    if (_personnelTypes.isEmpty) {
      return const Center(child: Text("No personnel types available"));
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
            itemCount: _filteredPersonnelTypes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final personnel = _filteredPersonnelTypes[index];

              return ReusableCardWidget(
                child: ListTile(
                  title: Text(personnel['name'] ?? 'Unnamed Type'),
                  leading: const Icon(Icons.person_outline_rounded),
                  onTap: () => _openEditScreen(personnel['ID']),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
