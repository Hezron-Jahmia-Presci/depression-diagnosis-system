import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/session_service.dart';
import '../../../widget/widget_exporter.dart';
import '../../screens_exporter.dart';

class AdminSessionScreen extends StatefulWidget {
  const AdminSessionScreen({super.key});

  @override
  State<AdminSessionScreen> createState() => _AdminSessionScreenState();
}

class _AdminSessionScreenState extends State<AdminSessionScreen> {
  final SessionService _sessionService = SessionService();

  List<Map<String, dynamic>> _sessions = [];
  bool _isLoading = true;
  bool _hasError = false;
  int? _selectedSessionId;

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    try {
      final results = await _sessionService.getAllSessions();
      setState(() {
        _sessions = results;
        _hasError = results.isEmpty;
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
      _selectedSessionId = null;
    });
    await _fetchSessions();
  }

  void _selectSession(int sessionId) {
    setState(() => _selectedSessionId = sessionId);
  }

  void _goBackToList() {
    setState(() => _selectedSessionId = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return const Center(child: Text('Error fetching sessions'));
    }

    if (_selectedSessionId != null) {
      return SessionDetailsScreen(
        sessionID: _selectedSessionId!,
        onBack: _goBackToList,
      );
    }

    if (_sessions.isEmpty) {
      return const Center(child: Text('No sessions available'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 13),
      child: ListView.separated(
        itemCount: _sessions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final session = _sessions[index];
          final date = session['date'] ?? 'Unknown';
          final status = session['status'] ?? 'Unknown';
          final id = session['ID'];

          return ReusableCardWidget(
            child: ListTile(
              title: Text("Session on: $date"),
              subtitle: Text("Status: $status"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: id != null ? () => _selectSession(id) : null,
            ),
          );
        },
      ),
    );
  }
}
