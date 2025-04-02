import 'package:flutter/material.dart';
import 'package:frontend/service/diagnosis_service.dart';
import 'package:frontend/service/phq9_service.dart';
import 'package:frontend/service/session_summary_service.dart';

import '../../../../widget/widget_exporter.dart';
import '../../../../service/session_service.dart' show SessionService;
import 'create_diagnosis_screen.dart' show CreateDiagnosisScreen;

class SessionDetailsScreen extends StatefulWidget {
  final int sessionID;

  const SessionDetailsScreen({super.key, required this.sessionID});

  @override
  State<SessionDetailsScreen> createState() => _SessionDetailsScreenState();
}

class _SessionDetailsScreenState extends State<SessionDetailsScreen> {
  final SessionSummaryService _sessionSummaryService = SessionSummaryService();
  final SessionService _sessionService = SessionService();
  final DiagnosisService _diagnosisService = DiagnosisService();
  final Phq9Service _phq9service = Phq9Service();

  Map<String, dynamic>? _sessionDetails;
  Map<String, dynamic>? _sessionSummaryDetails;
  Map<String, dynamic>? _diagnosisDetails;
  List<dynamic>? _phq9QuestionsAndResponses;
  List<dynamic>? _phq9Questions;
  List<dynamic>? _phq9Responses;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchSessionDetails();
    _fetchSessionSummaryDetails();
    _fetchDiagnosisDetails();
    _fetchPhQResponseDetails();
  }

  Future<void> _fetchSessionDetails() async {
    try {
      final sessionDetails = await _sessionService.getSessionByID(
        widget.sessionID,
      );
      if (sessionDetails != null) {
        setState(() {
          _sessionDetails = sessionDetails;
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

  Future<void> _fetchSessionSummaryDetails() async {
    try {
      final summaryDetails = await _sessionSummaryService.getSessionSummary(
        widget.sessionID,
      );
      if (summaryDetails != null) {
        setState(() {
          _sessionSummaryDetails = summaryDetails;
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

  Future<void> _fetchDiagnosisDetails() async {
    try {
      final response = await _diagnosisService.getDiagnosisBySessionId(
        widget.sessionID,
      );
      if (response != null && response.containsKey('diagnosis')) {
        setState(() {
          _diagnosisDetails = response['diagnosis'];
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

  Future<void> _fetchPhQResponseDetails() async {
    try {
      final questions = await _phq9service.getAllQuestions();
      final answers = await _phq9service.getResponsesForSession(
        widget.sessionID,
      );
      if (questions != null && answers != null) {
        setState(() {
          _phq9Questions = questions;
          _phq9Responses = answers;
          _isLoading = false;
          Map<int, String> questionMap = {
            for (var q in _phq9Questions!) q['ID']: q['question'],
          };
          _phq9QuestionsAndResponses =
              _phq9Responses!.map((resp) {
                return {
                  'question':
                      questionMap[resp['question_id']] ??
                      'Create a diagnosis first',
                  'responses': resp['response'] ?? 'No Response recorded yet',
                };
              }).toList();
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

  void _navigateToCreateDiagnosisScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CreateDiagnosisScreen(sessionID: widget.sessionID),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SESSION DETAILS",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child:
                _sessionDetails != null
                    ? _buildSessionDetails(_sessionDetails!)
                    : const Center(child: Text("Loading session details...")),
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _hasError
              ? const Center(child: Text('Start a diagnosis first'))
              : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 21,
                  vertical: 13,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 21,
                    vertical: 13,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                "PHQ9 RESPONSE SUMMARY",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Divider(),
                            Expanded(child: _buildPhq9Responses(colorScheme)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 55),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                "DIAGNOSTIC SUMMARY",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Divider(),
                            _buildDiagnosisResults(_diagnosisDetails),
                            Center(
                              child: Text(
                                "SESSION SUMMARY",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Divider(),
                            _buildSessionSummaryDetails(_sessionSummaryDetails),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      floatingActionButton:
          (_sessionDetails != null && _sessionDetails?['status'] == "completed")
              ? null
              : FloatingActionButton.extended(
                onPressed: _navigateToCreateDiagnosisScreen,
                icon: const Icon(Icons.medical_services),
                label: const Text("Start Diagnosis"),
              ),
    );
  }

  Widget _buildSessionDetails(Map<String, dynamic>? sessionData) {
    if (sessionData == null) {
      return const Center(child: Text("Failed to load session details."));
    }

    final psychiatristName =
        "${sessionData['Psychiatrist']?['first_name'] ?? 'Unknown'} ${sessionData['Psychiatrist']?['last_name'] ?? ''}";
    final patientName =
        "${sessionData['Patient']?['first_name'] ?? 'Unknown'} ${sessionData['Patient']?['last_name'] ?? ''}";

    return Table(
      border: TableBorder.all(
        color: Colors.transparent, // Border color
        width: 1.0,
      ),
      children: [
        TableRow(
          children: [
            Center(
              child: Text(
                "📅 Date: ${sessionData['date'] ?? 'Unknown'}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Center(
              child: Text(
                "🟢 Status: ${sessionData['status'] ?? 'Unknown'}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color:
                      sessionData['status'] == "completed"
                          ? Colors.green
                          : Colors.orange,
                ),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Center(
              child: Text(
                "👩‍⚕️ Psychiatrist: $psychiatristName",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Center(
              child: Text(
                "🧑‍🦱 Patient: $patientName",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhq9Responses(ColorScheme colorScheme) {
    if (_phq9QuestionsAndResponses == null ||
        _phq9QuestionsAndResponses!.isEmpty) {
      return const Center(child: Text("No PHQ-9 responses recorded."));
    }

    final Map<int, Color> responseColors = {
      1: Colors.red,
      2: Colors.orange,
      3: Colors.grey,
      4: Colors.lightGreen,
      5: Colors.green,
    };

    final Map<int, String> responseLabels = {
      1: 'Strongly Disagree',
      2: 'Disagree',
      3: 'Neutral',
      4: 'Agree',
      5: 'Strongly Agree',
    };

    return ListView.builder(
      itemCount: _phq9QuestionsAndResponses!.length,
      itemBuilder: (context, index) {
        final phq9QuestionAndAnswer = _phq9QuestionsAndResponses![index];
        final int response =
            int.tryParse(phq9QuestionAndAnswer['responses'].toString()) ?? 0;

        final responseColor = responseColors[response] ?? Colors.grey;
        final responseLabel = responseLabels[response] ?? 'No Response';

        return ReusableCardWidget(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${phq9QuestionAndAnswer['question'] ?? 'Unknown Question'}",
                  style: const TextStyle(fontSize: 16),
                ),
                Divider(color: colorScheme.primaryContainer),
                SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 32.8,
                      height: 32.8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: responseColor.withAlpha(55),
                        border: Border.all(
                          color: responseColor.withAlpha(155),
                          width: 2.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      responseLabel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiagnosisResults(Map<String, dynamic>? diagnosisData) {
    if (diagnosisData == null || diagnosisData.isEmpty) {
      return const Center(child: Text('No diagnosis details available'));
    }

    final int? phq9Score = diagnosisData['phq9_score'];
    final String severity = diagnosisData['severity'] ?? 'Unknown';

    return ReusableCardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "🔍 PHQ-9 Score: ${phq9Score ?? 'N/A'}",
            style: const TextStyle(fontSize: 16),
          ),
          Text("💡 Severity: $severity", style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildSessionSummaryDetails(Map<String, dynamic>? sessionSummaryData) {
    if (sessionSummaryData == null) {
      return const Center(child: Text('No session summary details available'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: ReusableCardWidget(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "${sessionSummaryData['notes'] ?? 'No psychiatrist notes available'}",
            ),
          ],
        ),
      ),
    );
  }
}
