import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/phq9_question_service.dart';
import '../../../../widget/widget_exporter.dart';

class AdminCreatePhq9QuestionScreen extends StatefulWidget {
  const AdminCreatePhq9QuestionScreen({super.key});

  @override
  State<AdminCreatePhq9QuestionScreen> createState() =>
      _AdminCreatePhq9QuestionScreenState();
}

class _AdminCreatePhq9QuestionScreenState
    extends State<AdminCreatePhq9QuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final Phq9QuestionService _phq9QuestionService = Phq9QuestionService();

  final _questionController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _createQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final response = await _phq9QuestionService.createQuestion({
      'question': _questionController.text.trim(),
    });

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (response != null && response['error'] == null) {
      ReusableSnackbarWidget.show(
        context,
        'PHQ-9 question created successfully!',
      );
      _formKey.currentState!.reset();
      _questionController.clear();
    } else {
      final error = response?['error'] ?? 'Failed to create PHQ-9 question';
      ReusableSnackbarWidget.show(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(55.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Create PHQ-9 Question",
                  style: TextStyle(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                ReusableTextFieldWidget(
                  controller: _questionController,
                  label: "Question",
                  autofillHints: const [],
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Question is required ⛔";
                    }
                    if (val.trim().length < 5) {
                      return "Question should be at least 5 characters";
                    }
                    return null;
                  },
                  maxLines: 1,
                ),

                const SizedBox(height: 33),

                ReusableButtonWidget(
                  isLoading: _isSubmitting,
                  onPressed: _createQuestion,
                  text: "Create PHQ-9 Question",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
