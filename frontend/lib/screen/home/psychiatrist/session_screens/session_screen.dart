import 'package:flutter/material.dart';

import '../../../../service/session_service.dart' show SessionService;
import '../../../../widget/widget_exporter.dart' show ReusableCardWidget;
import 'create_session_screen.dart' show CreateSessionScreen;
import 'session_details_screen.dart' show SessionDetailsScreen;

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final SessionService _sessionService = SessionService();
  List<dynamic>? _sessions;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      final sessions = await _sessionService.getSessionsByPsychiatrist();
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _navigateToCreateSessionScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateSessionScreen()),
    );
    _loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'SESSIONS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _hasError
              ? Center(child: Text('Error fetching sessions'))
              : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 21,
                  vertical: 13,
                ),
                child: _buildSessionList(),
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateSessionScreen,
        icon: const Icon(Icons.add_to_queue_outlined),
        label: const Text("Start New Session"),
      ),
    );
  }

  Widget _buildSessionList() {
    return ListView.builder(
      itemCount: _sessions!.length,
      itemBuilder: (context, index) {
        final session = _sessions![index];
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
