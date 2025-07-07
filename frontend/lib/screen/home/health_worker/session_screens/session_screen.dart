import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/session_service.dart';
import '../../../../widget/widget_exporter.dart';
import '../../../screens_exporter.dart';

class SessionScreen extends StatefulWidget {
  final void Function(bool isVisible)? onFabVisibilityChanged;

  const SessionScreen({super.key, this.onFabVisibilityChanged});

  @override
  State<SessionScreen> createState() => SessionScreenState();
}

class SessionScreenState extends State<SessionScreen> {
  final SessionService _sessionService = SessionService();

  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _filteredSessoins = [];

  bool _isLoading = true;
  bool _hasError = false;
  int? _selectedSessionId;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSessions();
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSessions() async {
    try {
      final results = await _sessionService.getSessionsByHealthWorker();
      setState(() {
        _sessions = results;
        _filteredSessoins = results;
        _hasError = false;
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
        _sessions.where((session) {
          final sessionCode = session['session_code'];
          final healthWorker =
              '${session['HealthWorker']?['first_name'] ?? ''} ${session['HealthWorker']?['last_name'] ?? ''}'
                  .toLowerCase();
          final patient =
              '${session['Patient']?['first_name'] ?? ''} ${session['Patient']?['last_name'] ?? ''}'
                  .toLowerCase();

          return sessionCode.contains(lowerQuery) ||
              healthWorker.contains(lowerQuery) ||
              patient.contains(lowerQuery);
        }).toList();

    setState(() {
      _filteredSessoins = filtered;
    });
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
    widget.onFabVisibilityChanged?.call(false); // 👈 hide FAB
    setState(() => _selectedSessionId = sessionId);
  }

  void _goBackToList() {
    widget.onFabVisibilityChanged?.call(true); // 👈 show FAB again
    setState(() => _selectedSessionId = null);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_hasError) return const Center(child: Text('Failed to load sessions.'));

    if (_selectedSessionId != null) {
      return SessionDetailsScreen(
        sessionID: _selectedSessionId!,
        onBack: _goBackToList,
      );
    }

    if (_filteredSessoins.isEmpty) {
      final hasSearch = _searchController.text.trim().isNotEmpty;
      return Center(
        child: Text(
          hasSearch
              ? 'No sessions match your search.'
              : 'No sessions found. Tap the "+" button to add one.',
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return Column(
      children: [
        ReusableSearchBarWidget(
          controller: _searchController,
          label: 'Search by session code or patient name',
        ),

        SizedBox(height: 55),

        Expanded(
          child: ListView.separated(
            itemCount: _filteredSessoins.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final session = _filteredSessoins[index];

              return ReusableCardWidget(
                child: ListTile(
                  title: Text(session['session_code'] ?? 'Unknown'),
                  subtitle: Text(session['session_issue'] ?? 'Unknown'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              (session['status'] == 'complete')
                                  ? colorScheme.primary
                                  : (session['status'] == 'ongoing')
                                  ? Colors.orange
                                  : colorScheme.error,
                          border: Border.all(color: Colors.black26),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.arrow_forward_ios_rounded),
                    ],
                  ),
                  onTap: () => _selectSession(session['ID']),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
