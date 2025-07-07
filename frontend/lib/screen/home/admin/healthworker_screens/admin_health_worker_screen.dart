import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/health_worker_service.dart';
import '../../../../widget/widget_exporter.dart';
import '../../../screens_exporter.dart';

class AdminHealthWorkerScreen extends StatefulWidget {
  final void Function(bool isVisible)? onFabVisibilityChanged;
  const AdminHealthWorkerScreen({super.key, this.onFabVisibilityChanged});

  @override
  State<AdminHealthWorkerScreen> createState() =>
      AdminHealthWorkerScreenState();
}

class AdminHealthWorkerScreenState extends State<AdminHealthWorkerScreen> {
  final HealthWorkerService _healthWorkerService = HealthWorkerService();

  List<Map<String, dynamic>> _healthWorkers = [];
  List<Map<String, dynamic>> _filteredHealthWorkers = [];

  bool _isLoading = true;
  bool _hasError = false;
  int? _selectedHealthWorkerID;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHealthWorkers();
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHealthWorkers() async {
    try {
      final fetched = await _healthWorkerService.getAllHealthWorkers();
      setState(() {
        _healthWorkers = fetched;
        _filteredHealthWorkers = fetched;
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
        _healthWorkers.where((hw) {
          final name = '${hw['first_name']} ${hw['last_name']}'.toLowerCase();
          final email = (hw['email'] ?? '').toLowerCase();
          final employeeID = (hw['employee_id'] ?? '').toLowerCase();
          return name.contains(lowerQuery) ||
              email.contains(lowerQuery) ||
              employeeID.contains(lowerQuery);
        }).toList();

    setState(() {
      _filteredHealthWorkers = filtered;
    });
  }

  Future<void> reload() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _selectedHealthWorkerID = null;
    });
    await _loadHealthWorkers();
  }

  void _openHealthWorkerDetails(int id) {
    widget.onFabVisibilityChanged?.call(false); // 👈 hide FAB
    setState(() {
      _selectedHealthWorkerID = id;
    });
  }

  void _goBackToList() {
    widget.onFabVisibilityChanged?.call(true); // 👈 show FAB
    setState(() {
      _selectedHealthWorkerID = null;
    });
  }

  void resetToListView() {
    if (_selectedHealthWorkerID != null) {
      _goBackToList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_hasError) {
      return const Center(child: Text('Error fetching health workers'));
    }

    if (_selectedHealthWorkerID != null) {
      return HealthWorkerDetailsScreen(
        healthWorkerID: _selectedHealthWorkerID!,
        onBack: _goBackToList,
      );
    }

    if (_healthWorkers.isEmpty) {
      return const Center(child: Text('No health workers available'));
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
            itemCount: _filteredHealthWorkers.length,
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final hw = _filteredHealthWorkers[index];
              final imageUrl =
                  (hw['image_url'] is String) ? hw['image_url'] : '';

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
                    "${hw['first_name'] ?? ''} ${hw['last_name'] ?? ''}",
                  ),
                  subtitle: Text("Employee ID: ${hw['employee_id'] ?? 'N/A'}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              (hw['is_active'] == true)
                                  ? Colors.green
                                  : Colors.grey,
                          border: Border.all(color: Colors.black26),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.arrow_forward_ios_rounded),
                    ],
                  ),
                  onTap: () => _openHealthWorkerDetails(hw['ID']),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
