import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/phq9_response_service.dart';
import 'package:depression_diagnosis_system/service/lib/phq9_question_service.dart';
import 'package:depression_diagnosis_system/service/lib/session_service.dart';
import 'package:depression_diagnosis_system/service/lib/diagnosis_service.dart';
import 'package:depression_diagnosis_system/service/lib/session_summary_service.dart';

import '../../../../widget/widget_exporter.dart';

class CreateDiagnosisScreen extends StatefulWidget {
  final int sessionID;
  final VoidCallback onBack;
  final VoidCallback onComplete;

  const CreateDiagnosisScreen({
    super.key,
    required this.sessionID,
    required this.onBack,
    required this.onComplete,
  });

  @override
  State<CreateDiagnosisScreen> createState() => _CreateDiagnosisScreenState();
}

class _CreateDiagnosisScreenState extends State<CreateDiagnosisScreen> {
  final _formKey = GlobalKey<FormState>();

  final _notesController = TextEditingController();
  final _phq9QuestionService = Phq9QuestionService();
  final _phq9ResponseService = Phq9ResponseService();
  final _diagnosisService = DiagnosisService();
  final _summaryService = SessionSummaryService();
  final _sessionService = SessionService();

  List<dynamic>? _questions;
  List<int?>? _responses;

  bool _isLoading = true;
  bool _isSubmitting = false;
  int _selectedStatus = 4;

  final _statusMap = {4: 'ongoing', 1: 'cancelled'};

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final questions = await _phq9QuestionService.getAllQuestions();
      if (questions.isEmpty) throw Exception("Empty question list");

      setState(() {
        _questions = questions;
        _responses = List.filled(questions.length, null, growable: false);

        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _questions = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final responsePayload = List.generate(
        _questions!.length,
        (i) => {
          "question_id": _questions![i]['ID'],
          "response": _responses![i],
        },
      );

      final recorded = await _phq9ResponseService.createResponse(
        widget.sessionID,
        responsePayload,
      );
      if (recorded == null || recorded['error'] != null) {
        if (mounted) {
          ReusableSnackbarWidget.show(context, 'Failed to record response!');
        }
        return;
      }

      if (_responses!.any((r) => r == null)) {
        if (mounted) {
          ReusableSnackbarWidget.show(context, 'Please answer all questions.');
        }

        return;
      }

      await _diagnosisService.createDiagnosis(widget.sessionID);
      await _summaryService.createSessionSummary(
        widget.sessionID,
        _notesController.text,
      );
      await _sessionService.updateSessionStatus(widget.sessionID, 'completed');

      if (mounted) {
        ReusableSnackbarWidget.show(
          context,
          'Responses recorded successfully!',
        );
        widget.onComplete();
      }
    } catch (_) {
      if (mounted) {
        ReusableSnackbarWidget.show(
          context,
          'An error occurred during submission.',
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleStatusChange(int? value) async {
    if (value == null) return;

    setState(() => _selectedStatus = value);

    if (_statusMap[value] == 'cancelled') {
      await _sessionService.updateSessionStatus(widget.sessionID, 'cancelled');
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_questions == null) {
      return const Center(child: Text('Error fetching PHQ-9 questions'));
    }

    return Scaffold(
      body: Stack(
        children: [
          // Scrollable questions behind
          Padding(
            padding: const EdgeInsets.only(
              bottom: 250,
            ), // room for sticky panel
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildQuestionListWithColorKey(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Bottom panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ReusableCardWidget(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notes field
                  const Text(
                    'Session Notes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ReusableTextFieldWidget(
                      controller: _notesController,
                      label: 'Write your session notes here...',
                      expands: true,
                      autofillHints: const [],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status & Submit
                  Row(
                    children: [
                      const Text('Status:'),
                      const SizedBox(width: 8),
                      ReusableRadioButtonWidget(
                        selectedStatus: _selectedStatus,
                        options: _statusMap.keys.toList(),
                        statusMap: _statusMap,
                        onChanged: _handleStatusChange,
                      ),
                      const Spacer(),
                      ReusableButtonWidget(
                        isLoading: _isSubmitting,
                        onPressed: _submit,
                        text: 'Submit Diagnosis',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: widget.onBack,
        ),
        const SizedBox(width: 8),
        const Text(
          'Create Diagnosis',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildQuestionListWithColorKey() {
    const labels = [
      'Strongly Disagree',
      'Disagree',
      'Neutral',
      'Agree',
      'Strongly Agree',
    ];

    return Column(
      children: [
        const Text(
          'Choose how accurately each statement reflects the patient',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 33),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(labels.length, (i) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScale[i].withAlpha(55),
                    border: Border.all(
                      color: colorScale[i].withAlpha(155),
                      width: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(labels[i], style: const TextStyle(fontSize: 12)),
              ],
            );
          }),
        ),
        const SizedBox(height: 89),
        ...List.generate(_questions!.length, (i) {
          return ReusableCardWidget(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${i + 1}. ${_questions![i]['question']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ReusableRadioButtonWidget(
                  selectedStatus:
                      _responses![i] ?? 0, // provide a default value if null
                  options: [1, 2, 3, 4, 5],
                  onChanged: (val) => setState(() => _responses![i] = val!),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
