import 'package:flutter/material.dart';

import '../../../../service/session_service.dart' show SessionService;
import '../../../../widget/widget_exporter.dart' show ReusableCardWidget;
import '../../psychiatrist/session_screens/session_details_screen.dart'
    show SessionDetailsScreen;

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final SessionService _sessonService = SessionService();
  List<Map<String, dynamic>>? _sessionDetails;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchPatientDetails();
  }

  Future<void> _fetchPatientDetails() async {
    try {
      final details = await _sessonService.getAllSessions();
      if (details != null && details.isNotEmpty) {
        setState(() {
          _sessionDetails = List<Map<String, dynamic>>.from(details);
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _hasError
        ? Center(child: Text('Error fetching details'))
        : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 13),
          child:
              _sessionDetails != null && _sessionDetails!.isNotEmpty
                  ? _buildPatientList()
                  : const Center(child: Text('No session available')),
        );
  }

  Widget _buildPatientList() {
    return ListView.builder(
      itemCount: _sessionDetails!.length,
      itemBuilder: (context, index) {
        final session = _sessionDetails![index];
        return ReusableCardWidget(
          child: ListTile(
            title: Text("Session on: ${session['date']}"),
            subtitle: Text("Status: ${session['status']}"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          SessionDetailsScreen(sessionID: session['ID']),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
