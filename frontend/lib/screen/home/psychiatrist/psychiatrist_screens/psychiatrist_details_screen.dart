import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/psychiatrist_service.dart';
import '../../../../widget/widget_exporter.dart';
import '../../../screens_exporter.dart';

class PsychiatristDetailsScreen extends StatefulWidget {
  const PsychiatristDetailsScreen({super.key});

  @override
  State<PsychiatristDetailsScreen> createState() =>
      _PsychiatristDetailsScreenState();
}

class _PsychiatristDetailsScreenState extends State<PsychiatristDetailsScreen> {
  final _psychiatristService = PsychiatristService();
  Map<String, dynamic>? _psychiatristDetails;
  bool _isLoading = true;
  bool _hasError = false;
  int? _selectedPsychiatristID;

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

  Future<void> reload() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _selectedPsychiatristID = null;
    });
    await _loadPsychiatristDetails();
  }

  void _goToEditScreen(int psychiatristID) {
    setState(() => _selectedPsychiatristID = psychiatristID);
  }

  void _goBackToList() {
    setState(() => _selectedPsychiatristID = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_hasError || _psychiatristDetails == null) {
      return const Center(child: Text('Error fetching patient details'));
    }

    if (_selectedPsychiatristID != null) {
      return EditPsychiatristDetailsScreen(
        psychiatristID: _selectedPsychiatristID!,
        onBack: _goBackToList,
      );
    }

    final psych = _psychiatristDetails!;

    return ListView(
      children: [
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
        ReusableButtonWidget(
          text: 'Edit Details',
          isLoading: false,
          onPressed: () => _goToEditScreen(psych['ID']),
        ),
      ],
    );
  }
}
