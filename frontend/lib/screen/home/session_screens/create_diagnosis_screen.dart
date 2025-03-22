import 'package:flutter/material.dart';

import '../../../widget/widget_exporter.dart';
import '../../../service/phq9_service.dart' show Phq9Service;
import '../../../service/session_service.dart' show SessionService;
import '../../../service/diagnosis_service.dart' show DiagnosisService;
import '../../../service/session_summary_service.dart'
    show SessionSummaryService;
import 'session_details_screen.dart' show SessionDetailsScreen;

class CreateDiagnosisScreen extends StatefulWidget {
  final int sessionID;
  const CreateDiagnosisScreen({super.key, required this.sessionID});

  @override
  State<CreateDiagnosisScreen> createState() => _CreateDiagnosisScreenState();
}

class _CreateDiagnosisScreenState extends State<CreateDiagnosisScreen> {
  final _formKey = GlobalKey<FormState>();
  final SessionSummaryService _sessionSummaryService = SessionSummaryService();
  final SessionService _sessionService = SessionService();
  final DiagnosisService _diagnosisService = DiagnosisService();
  final Phq9Service _phq9service = Phq9Service();
  final _notesController = TextEditingController();

  List<dynamic>? _phq9Questions;
  List<dynamic>? _phq9Responses;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isSubmitting = false;
  int _selectedStatus = 4;

  @override
  void initState() {
    super.initState();
    _fetchPhq9Questions();
  }

  final Map<int, String> statusMap = {4: 'ongoing', 1: 'cancelled'};

  void _handleStatusChange(int? newValue) async {
    if (newValue != null) {
      setState(() {
        _selectedStatus = newValue;
      });

      String newStatus = statusMap[newValue]!;
      if (newStatus == 'cancelled') {
        await _sessionService.updateSessionStatus(
          widget.sessionID,
          'cancelled',
        );
        _navigateToSessionDetailsScreen();
      }
    }
  }

  Future<void> _fetchPhq9Questions() async {
    try {
      final questions = await _phq9service.getAllQuestions();

      if (questions != null && questions.isNotEmpty) {
        setState(() {
          _phq9Questions = questions;
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

  Future<void> _submitResponse() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      final List<Map<String, dynamic>> responseData = [];

      if (_phq9Responses!.length != _phq9Questions!.length) {
        _phq9Responses = List.filled(_phq9Questions!.length, 1);
      }

      for (int i = 0; i < _phq9Questions!.length; i++) {
        responseData.add({
          "question_id": _phq9Questions![i]['ID'],
          "response": _phq9Responses![i],
        });
      }

      try {
        final result = await _phq9service.recordResponsesForSession(
          widget.sessionID,
          responseData,
        );
        await _diagnosisService.createDiagnosis(widget.sessionID);
        await _sessionSummaryService.createSessionSummary(
          widget.sessionID,
          _notesController.text,
        );
        await _sessionService.updateSessionStatus(
          widget.sessionID,
          'completed',
        );

        setState(() {
          _isSubmitting = false;
        });

        if (result != null && mounted) {
          ReusableSnackbarWidget.show(
            context,
            'Responses recorded successfully!',
          );
          _navigateToSessionDetailsScreen();
        } else {
          ReusableSnackbarWidget.show(context, 'Failed to record response!');
        }
      } catch (e) {
        setState(() {
          _isSubmitting = false;
          _hasError = true;
        });
      }
    }
  }

  void _navigateToSessionDetailsScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SessionDetailsScreen(sessionID: widget.sessionID),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _hasError
              ? Center(child: Text('Error fetching details'))
              : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 21,
                  vertical: 13,
                ),
                child: Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            SizedBox(height: 180, child: _buildColorKey()),
                            Expanded(child: _buildQuestionsList()),
                          ],
                        ),
                      ),
                      const SizedBox(width: 55),
                      Expanded(flex: 2, child: _buildNotesSection()),
                    ],
                  ),
                ),
              ),
      bottomNavigationBar: BottomAppBar(
        child: ReusableButtonWidget(
          isLoading: _isSubmitting,
          onPressed: _submitResponse,
          text: "Submit Responses",
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'CREATE DIAGNOSIS',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Session Status: ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ReusableRadioButtonWidget(
                selectedStatus: _selectedStatus,
                options: [4, 1],
                statusMap: statusMap,
                onChanged: (newValue) async {
                  _handleStatusChange(newValue);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorKey() {
    final List<String> labels = [
      'Strongly Disagree',
      'Disagree',
      'Neutral',
      'Agree',
      'Strongly Agree',
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          Center(
            child: Text(
              'Choose how accurately each statement reflects the patient',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(labels.length, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Column(
                  children: [
                    Container(
                      width: 32.8,
                      height: 32.8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScale[i].withAlpha(55),
                        border: Border.all(
                          color: colorScale[i].withAlpha(155),
                          width: 2.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      labels[i],
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList() {
    if (_phq9Questions == null || _phq9Questions!.isEmpty) {
      return const Center(child: Text("No PHQ-9 questions available"));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 21),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _phq9Questions?.length ?? 0,
        itemBuilder: (context, index) => _buildQuestionCard(index),
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    return ReusableCardWidget(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${index + 1}. ${_phq9Questions?[index]['question'] ?? 'Unknown Question'}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ReusableRadioButtonWidget(
              selectedStatus:
                  (_phq9Responses?.length ?? 0) > index
                      ? _phq9Responses![index]
                      : 0,
              options: [1, 2, 3, 4, 5],
              onChanged: (newValue) {
                setState(() {
                  if (_phq9Responses == null ||
                      _phq9Responses!.length != _phq9Questions!.length) {
                    _phq9Responses = List.filled(_phq9Questions!.length, 0);
                  }
                  _phq9Responses![index] = newValue!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 21),
      child: Column(
        children: [
          const Text(
            'NOTES',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ReusableTextFieldWidget(
              controller: _notesController,
              label: 'Write your session notes here...',
              expands: true,
            ),
          ),
        ],
      ),
    );
  }
}
