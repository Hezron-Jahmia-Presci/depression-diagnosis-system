import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/health_worker_service.dart';
import '../../../../../widget/widget_exporter.dart';
import '../../../screens_exporter.dart';

class HealthWorkerDetailsScreen extends StatefulWidget {
  final int healthWorkerID;
  final VoidCallback onBack;

  const HealthWorkerDetailsScreen({
    super.key,
    required this.healthWorkerID,
    required this.onBack,
  });

  @override
  State<HealthWorkerDetailsScreen> createState() =>
      _HealthWorkerDetailsScreenState();
}

class _HealthWorkerDetailsScreenState extends State<HealthWorkerDetailsScreen> {
  final HealthWorkerService _healthWorkerService = HealthWorkerService();
  Map<String, dynamic>? _healthWorkerDetails;
  bool _isLoading = true;
  bool _hasError = false;
  int? _selectedHealthWorkerID;

  @override
  void initState() {
    super.initState();
    _loadHealthWorkerDetails();
  }

  Future<void> _loadHealthWorkerDetails() async {
    try {
      final workers = await _healthWorkerService.getAllHealthWorkers();
      final selected = workers.firstWhere(
        (w) => w['ID'] == widget.healthWorkerID,
        orElse: () => {},
      );
      setState(() {
        _healthWorkerDetails = selected.isNotEmpty ? selected : null;
        _hasError = _healthWorkerDetails == null;
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

  void _goToEditScreen(int id) {
    setState(() => _selectedHealthWorkerID = id);
  }

  void _goBackToDetails() {
    setState(() => _selectedHealthWorkerID = null);
    _loadHealthWorkerDetails(); // optional: refresh after edit
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_hasError || _healthWorkerDetails == null) {
      return const Center(child: Text('Error fetching health worker details'));
    }

    if (_selectedHealthWorkerID != null) {
      return EditHealthWorkerDetailsScreen(
        onBack: _goBackToDetails,
        healthWorkerID: _selectedHealthWorkerID!,
      );
    }

    final hw = _healthWorkerDetails!;
    final imageUrl = hw['image_url']?.toString() ?? '';

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Row(
        //   children: [
        //     IconButton(
        //       icon: const Icon(Icons.arrow_back_ios_new_rounded),
        //       onPressed: widget.onBack,
        //     ),
        //     const Text(
        //       'Health Worker Details',
        //       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        //     ),
        //   ],
        // ),
        const SizedBox(height: 55),

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                            hw['first_name'] + ' ' + hw['last_name'],
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ReusableButtonWidget(
                              text: 'Edit Details',
                              isLoading: false,
                              onPressed: () => _goToEditScreen(hw['ID']),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ReusableButtonWidget(
                              text:
                                  hw['is_active'] == true
                                      ? 'Deactivate'
                                      : 'Activate',
                              backgroundColor:
                                  hw['is_active'] == true
                                      ? colorScheme.secondary
                                      : colorScheme.tertiary,
                              onPressed: () async {
                                final confirm = await _showConfirmationDialog(
                                  context,
                                  hw['is_active'] == true
                                      ? 'Are you sure you want to deactivate this account?'
                                      : 'Are you sure you want to activate this account?',
                                );
                                if (confirm == true) {
                                  final result = await _healthWorkerService
                                      .setActiveStatus(
                                        hw['ID'],
                                        !(hw['is_active'] == true),
                                      );
                                  if (context.mounted) {
                                    final msg =
                                        result?['message'] ??
                                        result?['error'] ??
                                        'Failed';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(msg)),
                                    );
                                  }
                                  _loadHealthWorkerDetails();
                                }
                              },
                              isLoading: _isLoading,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (hw['is_active'] == false)
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
                                    final success = await _healthWorkerService
                                        .deleteHealthWorker(hw['ID']);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
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
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 34),

              // Right: Health Worker Details
              Expanded(
                flex: 2,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 33),
                  children: [
                    _buildDetailTile('Email', hw['email']),
                    _buildDetailTile(
                      'Personnel Type',
                      hw['PersonnelType'] != null
                          ? hw['PersonnelType']['name']
                          : 'N/A',
                    ),
                    _buildDetailTile('Job Title', hw['job_title']),
                    _buildDetailTile('Address', hw['address']),
                    _buildDetailTile('Contact', hw['contact']),
                    _buildDetailTile('Bio', hw['bio']),
                    _buildDetailTile('Qualification', hw['qualification']),
                    _buildDetailTile('Education Level', hw['education_level']),
                    _buildDetailTile(
                      'Years of Practice',
                      hw['years_of_practice']?.toString(),
                    ),
                    _buildDetailTile(
                      'Department',
                      hw['Department'] != null
                          ? hw['Department']['name']
                          : 'N/A',
                    ),
                    _buildDetailTile(
                      'Supervisor',
                      hw['supervisor'] != null
                          ? '${hw['supervisor']['first_name']} ${hw['supervisor']['last_name']}'
                          : 'None',
                    ),
                    _buildDetailTile('Role', hw['role']),
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
}
