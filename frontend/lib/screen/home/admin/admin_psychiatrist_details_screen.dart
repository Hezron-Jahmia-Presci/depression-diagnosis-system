import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/psychiatrist_service.dart';
import '../../../../widget/widget_exporter.dart';

class AdminPsychiatristDetailsScreen extends StatefulWidget {
  final int psychiatristID;
  final VoidCallback onBack;
  const AdminPsychiatristDetailsScreen({
    super.key,
    required this.psychiatristID,
    required this.onBack,
  });

  @override
  State<AdminPsychiatristDetailsScreen> createState() =>
      _AdminPsychiatristDetailsScreenState();
}

class _AdminPsychiatristDetailsScreenState
    extends State<AdminPsychiatristDetailsScreen> {
  final _psychiatristService = PsychiatristService();
  Map<String, dynamic>? _psychiatristDetails;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadPsychiatristDetails();
  }

  Future<void> _loadPsychiatristDetails() async {
    try {
      final details = await _psychiatristService.getPsychiatristDetails();
      setState(() {
        _psychiatristDetails = details;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_hasError || _psychiatristDetails == null) {
      return const Center(child: Text('Error fetching patient details'));
    }

    final psych = _psychiatristDetails!;

    return ListView(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: widget.onBack,
            ),
            const Text(
              'Psychiatrist Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ReusableCardWidget(
          child: Text('First Name: ${psych['first_name'] ?? 'N/A'}'),
        ),
        const SizedBox(height: 12),
        ReusableCardWidget(
          child: Text('Last Name: ${psych['last_name'] ?? 'N/A'}'),
        ),
        const SizedBox(height: 12),
        ReusableCardWidget(child: Text('Email: ${psych['email'] ?? 'N/A'}')),
        const SizedBox(height: 24),
      ],
    );
  }
}
