import 'package:flutter/material.dart';

import 'package:depression_diagnosis_system/service/lib/phq9_response_service.dart';
import 'package:depression_diagnosis_system/service/lib/session_service.dart';
import 'package:depression_diagnosis_system/service/lib/phq9_question_service.dart';
import 'package:depression_diagnosis_system/service/lib/diagnosis_service.dart';
import 'package:depression_diagnosis_system/service/lib/session_summary_service.dart';

import '../../../../widget/widget_exporter.dart';
import '../../../screens_exporter.dart';

class SessionDetailsScreen extends StatefulWidget {
  final int sessionID;
  final VoidCallback onBack;
  final void Function(bool isVisible)? onFabVisibilityChanged;

  const SessionDetailsScreen({
    super.key,
    required this.sessionID,
    required this.onBack,
    this.onFabVisibilityChanged,
  });

  @override
  State<SessionDetailsScreen> createState() => _SessionDetailsScreenState();
}

class _SessionDetailsScreenState extends State<SessionDetailsScreen> {
  final SessionService _sessionService = SessionService();
  final Phq9QuestionService _phq9QuestionService = Phq9QuestionService();
  final Phq9ResponseService _phq9ResponseService = Phq9ResponseService();
  final DiagnosisService _diagnosisService = DiagnosisService();
  final SessionSummaryService _summaryService = SessionSummaryService();

  Map<String, dynamic>? _sessionDetails;
  Map<String, dynamic>? _diagnosisDetails;
  Map<String, dynamic>? _summaryDetails;
  List<Map<String, dynamic>> _questionResponses = [];

  bool _isLoading = true;
  bool _hasError = false;
  int? _diagnosingSessionId;
  int? _selectedHealthWorkerID;
  int? _selectedPatientID;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      final session = await _sessionService.getSessionByID(widget.sessionID);
      if (session == null) throw 'Session not found';

      // Start setting state early with session
      setState(() {
        _sessionDetails = session;
      });

      // Attempt to fetch optional resources without breaking on failure
      Map<String, dynamic>? diagnosis;
      Map<String, dynamic>? summary;
      List<Map<String, dynamic>> responses = [];
      List<dynamic> questions = [];

      try {
        diagnosis = await _diagnosisService.getDiagnosisBySessionId(
          widget.sessionID,
        );
      } catch (_) {}

      try {
        summary = await _summaryService.getSessionSummary(widget.sessionID);
      } catch (_) {}

      try {
        questions = await _phq9QuestionService.getAllQuestions();
        final rawResponses = await _phq9ResponseService.getResponseBySessionID(
          widget.sessionID,
        );
        final responseMap = {
          for (var r in rawResponses)
            r['question_id']: int.tryParse(r['response'].toString()) ?? 0,
        };
        responses =
            questions.map<Map<String, dynamic>>((q) {
              final qID = q['ID'];
              return {
                'question': q['question'],
                'response': responseMap[qID] ?? 0,
              };
            }).toList();
      } catch (_) {}

      setState(() {
        _diagnosisDetails = diagnosis?['diagnosis'];
        _summaryDetails = summary;
        _questionResponses = responses;
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
      _selectedHealthWorkerID = null;
    });
    await _loadAllData();
  }

  void _startDiagnosis() {
    setState(() {
      _diagnosingSessionId = widget.sessionID;
    });
  }

  void _openHealthWorkerDetails(int id) {
    widget.onFabVisibilityChanged?.call(false); // 👈 hide FAB
    setState(() {
      _selectedHealthWorkerID = id;
    });
  }

  void _openPatientDetails(int patientID) {
    widget.onFabVisibilityChanged?.call(false); // 👈 hide FAB
    setState(() {
      _selectedPatientID = patientID;
    });
  }

  void _goBackToList() {
    widget.onFabVisibilityChanged?.call(true); // 👈 show FAB
    setState(() {
      _selectedHealthWorkerID = null;
      _selectedPatientID = null;
    });
  }

  void resetToListView() {
    if (_selectedHealthWorkerID != null || _selectedPatientID != null) {
      _goBackToList();
    }
  }

  bool _shouldShowFAB() => _sessionDetails?['status'] != 'completed';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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

    if (_selectedHealthWorkerID != null) {
      return HealthWorkerDetailsScreen(
        healthWorkerID: _selectedHealthWorkerID!,
        onBack: _goBackToList,
      );
    }

    if (_selectedPatientID != null) {
      return PatientDetailsScreen(
        patientID: _selectedPatientID!,
        onBack: _goBackToList,
      );
    }

    final session = _sessionDetails!;

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: widget.onBack,
            ),
            const Text(
              'Sesson Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),

        const SizedBox(height: 55),

        Expanded(
          child: Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      children: [
                        Text(
                          session['session_code'],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        _sectionHeader("Health Worker", Icons.person_outline),
                        _buildDetailTile(
                          "Name",
                          "${session['HealthWorker']?['first_name'] ?? ''} ${session['HealthWorker']?['last_name'] ?? ''}"
                              .trim(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 26.0),
                          child: ReusableButtonWidget(
                            isLoading: _isLoading,
                            onPressed:
                                () => _openHealthWorkerDetails(
                                  session['HealthWorker']['ID'],
                                ),
                            text: 'View Details',
                          ),
                        ),
                        const SizedBox(height: 55),

                        _sectionHeader("Patient", Icons.person),
                        _buildDetailTile(
                          "Name",
                          "${session['Patient']?['first_name'] ?? ''} ${session['Patient']?['last_name'] ?? ''}",
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 26.0),
                          child: ReusableButtonWidget(
                            isLoading: _isLoading,
                            onPressed:
                                () => _openPatientDetails(
                                  session['Patient']['ID'],
                                ),
                            text: 'View Details',
                          ),
                        ),
                        const SizedBox(height: 55),

                        _sectionHeader("Session Info", Icons.info_outline),
                        _buildDetailTile("Session Date", session['date']),

                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 16.0,
                            left: 24.0,
                            right: 24.0,
                          ),
                          child: ReusableCardWidget(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
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

                                SizedBox(width: 16),

                                Text('Status: ${session['status']}'),
                              ],
                            ),
                          ),
                        ),

                        _buildDetailTile(
                          "State at Registration",
                          session['patient_state'],
                        ),
                        _buildDetailTile("Issue", session['session_issue']),
                        _buildDetailTile("Description", session['description']),
                        _buildDetailTile(
                          "Previous Session",
                          session['PreviousSession']?['session_code'],
                        ),
                        _buildDetailTile(
                          "Next Session Date",
                          session['next_session_date'],
                        ),
                        _buildDetailTile(
                          "Current Prescription",
                          session['current_prescription'],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),

                  const SizedBox(width: 34),

                  Expanded(
                    flex: 2,
                    child: ListView(
                      children: [
                        Text(
                          "Diagnosis",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDiagnosisResults(),
                        const SizedBox(height: 55),
                        Text(
                          "PHQ-9 Responses",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildPhq9Responses(),
                        const SizedBox(height: 55),

                        Text(
                          "Session Summary",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildSessionSummary(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
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
          ),
        ),
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
              subtitle: Text(responseLabels[response] ?? "N/A"),
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

  Widget _buildDetailTile(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 24.0, right: 24.0),
      child: ReusableCardWidget(child: Text('$title: ${value ?? 'N/A'}')),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
