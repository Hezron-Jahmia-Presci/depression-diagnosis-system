import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/psychiatrist_service.dart';
import '../../../../widget/widget_exporter.dart';
import '../../../screens_exporter.dart';

class PsychiatristDetailsScreen extends StatefulWidget {
  final int psychiatristID;
  const PsychiatristDetailsScreen({super.key, required this.psychiatristID});

  @override
  State<PsychiatristDetailsScreen> createState() =>
      _PsychiatristDetailsScreenState();
}

class _PsychiatristDetailsScreenState extends State<PsychiatristDetailsScreen> {
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

  void _goToEditScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditPsychiatristDetailsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading:
            Navigator.canPop(context)
                ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.pop(context),
                )
                : null,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _hasError || _psychiatristDetails == null
              ? const Center(child: Text('Error loading psychiatrist details'))
              : _buildProfileView(),
    );
  }

  Widget _buildProfileView() {
    final psych = _psychiatristDetails!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ReusableCardWidget(
                child: Text('First Name: ${psych['first_name'] ?? 'N/A'}'),
              ),
              const SizedBox(height: 12),
              ReusableCardWidget(
                child: Text('Last Name: ${psych['last_name'] ?? 'N/A'}'),
              ),
              const SizedBox(height: 12),
              ReusableCardWidget(
                child: Text('Email: ${psych['email'] ?? 'N/A'}'),
              ),
              const SizedBox(height: 24),
              ReusableButtonWidget(
                text: 'Edit Details',
                isLoading: false,
                onPressed: _goToEditScreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
