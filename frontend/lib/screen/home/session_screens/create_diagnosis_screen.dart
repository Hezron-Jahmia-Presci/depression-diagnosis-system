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
  String _selectedStatus = 'ongoing';

  @override
  void initState() {
    super.initState();
    _fetchPhq9Questions();
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
                      Expanded(flex: 3, child: _buildQuestionsList()),
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
        icon: Icon(Icons.arrow_back_ios_new_rounded),
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
                options: ['ongoing', 'cancelled'],
                onChanged: (newValue) async {
                  if (newValue != null) {
                    setState(() => _selectedStatus = newValue);
                    if (newValue == 'cancelled') {
                      await _sessionService.updateSessionStatus(
                        widget.sessionID,
                        'cancelled',
                      );
                      _navigateToSessionDetailsScreen();
                    }
                  }
                },
              ),
            ],
          ),
        ),
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
        itemCount: _phq9Questions?.length ?? 0,
        itemBuilder: (context, index) => _buildQuestionCard(index),
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${index + 1}. ${_phq9Questions?[index]['question'] ?? 'Unknown Question'}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                5,
                (i) => _buildRadioOption(index, i + 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(int index, int value) {
    return Row(
      children: [
        Radio<int>(
          value: value,
          groupValue:
              (_phq9Responses?.length ?? 0) > index
                  ? _phq9Responses![index]
                  : -1,
          onChanged: (newValue) {
            setState(() {
              if (_phq9Responses == null ||
                  _phq9Responses!.length != _phq9Questions!.length) {
                _phq9Responses = List.filled(_phq9Questions!.length, 1);
              }
              _phq9Responses![index] = newValue!;
            });
          },
        ),
        Text("$value"),
      ],
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
