import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/psychiatrist_service.dart';
import '../../../widget/widget_exporter.dart';
import '../../screens_exporter.dart';

class AdminPsychiatristScreen extends StatefulWidget {
  const AdminPsychiatristScreen({super.key});

  @override
  State<AdminPsychiatristScreen> createState() =>
      _AdminPsychiatristScreenState();
}

class _AdminPsychiatristScreenState extends State<AdminPsychiatristScreen> {
  final PsychiatristService _psychiatristService = PsychiatristService();

  List<Map<String, dynamic>> _psychiatrists = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadPsychiatrists();
  }

  Future<void> _loadPsychiatrists() async {
    try {
      final fetched = await _psychiatristService.getAllPsychiatrists();
      setState(() {
        _psychiatrists = fetched;
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

  void _openPsychiatristDetails(int psychiatristID) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => PsychiatristDetailsScreen(psychiatristID: psychiatristID),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_hasError) {
      return const Center(child: Text('Error fetching psychiatrists'));
    }
    if (_psychiatrists.isEmpty) {
      return const Center(child: Text('No psychiatrists available'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 13),
      child: ListView.separated(
        itemCount: _psychiatrists.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final psych = _psychiatrists[index];
          return ReusableCardWidget(
            child: ListTile(
              title: Text(
                "${psych['first_name'] ?? ''} ${psych['last_name'] ?? ''}",
              ),
              subtitle: Text("Email: ${psych['email'] ?? 'N/A'}"),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                final id = psych['ID'];
                if (id != null) _openPsychiatristDetails(id);
              },
            ),
          );
        },
      ),
    );
  }
}
