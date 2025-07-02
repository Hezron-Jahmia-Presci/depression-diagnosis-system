import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/session_service.dart';
import 'package:depression_diagnosis_system/service/lib/phq9_service.dart';
import 'package:depression_diagnosis_system/service/lib/diagnosis_service.dart';
import 'package:depression_diagnosis_system/service/lib/session_summary_service.dart';
import '../../../../widget/widget_exporter.dart';
import 'create_diagnosis_screen.dart';

class SessionDetailsScreen extends StatefulWidget {
  final int sessionID;
  final VoidCallback onBack;

  const SessionDetailsScreen({
    super.key,
    required this.sessionID,
    required this.onBack,
  });

  @override
  State<SessionDetailsScreen> createState() => _SessionDetailsScreenState();
}

class _SessionDetailsScreenState extends State<SessionDetailsScreen> {
  final _sessionService = SessionService();
  final _phq9Service = Phq9Service();
  final _diagnosisService = DiagnosisService();
  final _summaryService = SessionSummaryService();

  Map<String, dynamic>? _sessionDetails;
  Map<String, dynamic>? _diagnosisDetails;
  Map<String, dynamic>? _summaryDetails;
  List<Map<String, dynamic>> _questionResponses = [];

  bool _isLoading = true;
  bool _hasError = false;
  int? _diagnosingSessionId;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final session = await _sessionService.getSessionByID(widget.sessionID);
      final diagnosis = await _diagnosisService.getDiagnosisBySessionId(
        widget.sessionID,
      );
      final summary = await _summaryService.getSessionSummary(widget.sessionID);
      final questions = await _phq9Service.getAllQuestions();
      final responses = await _phq9Service.getResponsesForSession(
        widget.sessionID,
      );

      if (session == null) throw 'Session not found';

      final responseMap = {
        for (var r in responses)
          r['question_id']: int.tryParse(r['response'].toString()) ?? 0,
      };

      final responseData =
          questions.map((q) {
            final qID = q['ID'];
            return {
              'question': q['question'],
              'response': responseMap[qID] ?? 0, // default to 0 if no response
            };
          }).toList();

      setState(() {
        _sessionDetails = session;
        _diagnosisDetails = diagnosis?['diagnosis'];
        _summaryDetails = summary;
        _questionResponses = responseData;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _startDiagnosis() {
    setState(() {
      _diagnosingSessionId = widget.sessionID;
    });
  }

  bool _shouldShowFAB() => _sessionDetails?['status'] != 'completed';

  @override
  Widget build(BuildContext context) {
    if (_diagnosingSessionId != null) {
      return CreateDiagnosisScreen(
        sessionID: _diagnosingSessionId!,
        onBack: () => setState(() => _diagnosingSessionId = null),
        onComplete: () async {
          setState(() => _diagnosingSessionId = null);
          await _loadAllData();
        },
      );
    }

    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_hasError) {
      return const Center(child: Text("Failed to load session details."));
    }

    return Stack(
      children: [
        ListView(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: widget.onBack,
                ),
                const Text(
                  "Session Details",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_sessionDetails != null) _buildSessionHeader(_sessionDetails!),
            const SizedBox(height: 16),
            Text(
              "Diagnosis",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildDiagnosisResults(),
            const SizedBox(height: 55),
            Text(
              "PHQ-9 Responses",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildPhq9Responses(),
            const SizedBox(height: 55),

            Text(
              "Session Summary",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildSessionSummary(),
            const SizedBox(height: 80),
          ],
        ),
        if (_shouldShowFAB())
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton.extended(
              onPressed: _startDiagnosis,
              icon: const Icon(Icons.medical_services),
              label: const Text("Start Diagnosis"),
            ),
          ),
      ],
    );
  }

  Widget _buildSessionHeader(Map<String, dynamic> session) {
    final patient = session['Patient'];
    final psych = session['Psychiatrist'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "📅 ${session['date']} | 🟢 ${session['status']}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          "👩‍⚕️ Psychiatrist: ${psych?['first_name']} ${psych?['last_name']}",
        ),
        Text(
          "🧑‍🦱 Patient: ${patient?['first_name']} ${patient?['last_name']}",
        ),
        const Divider(height: 24),
      ],
    );
  }

  Widget _buildPhq9Responses() {
    if (_questionResponses.isEmpty) {
      return const Text("No PHQ-9 responses recorded.");
    }

    final responseLabels = {
      0: 'No response',
      1: 'Not at all',
      2: 'Several days',
      3: 'More than half',
      4: 'Nearly every day',
    };

    final responseColors = {
      0: Colors.grey,
      1: Colors.green,
      2: Colors.lightGreen,
      3: Colors.orange,
      4: Colors.red,
    };

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _questionResponses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = _questionResponses[index];
        final response = item['response'];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 33),
          child: ReusableCardWidget(
            child: ListTile(
              title: Text(
                item['question'],
                style: const TextStyle(fontSize: 15),
              ),
              subtitle: Text(responseLabels[response] ?? "Unknown"),
              trailing: CircleAvatar(
                backgroundColor: responseColors[response] ?? Colors.grey,
                radius: 10,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiagnosisResults() {
    if (_diagnosisDetails == null) {
      return const Text("No diagnosis data.");
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 33),
      child: ReusableCardWidget(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🔍 PHQ-9 Score: ${_diagnosisDetails!['phq9_score']}"),
            Text("💡 Severity: ${_diagnosisDetails!['severity']}"),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionSummary() {
    if (_summaryDetails == null) {
      return const Text("No summary available.");
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 33),
      child: ReusableCardWidget(
        child: Text(_summaryDetails!['notes'] ?? 'No notes.'),
      ),
    );
  }
}
