import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/phq9_question_service.dart';
import '../../../../widget/widget_exporter.dart';

class Phq9QuestionScreen extends StatefulWidget {
  final void Function(bool isVisible)? onFabVisibilityChanged;
  const Phq9QuestionScreen({super.key, this.onFabVisibilityChanged});

  @override
  State<Phq9QuestionScreen> createState() => Phq9QuestionScreenState();
}

class Phq9QuestionScreenState extends State<Phq9QuestionScreen> {
  final Phq9QuestionService _phq9QuestionService = Phq9QuestionService();

  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> _filteredQuestions = [];

  bool _isLoading = true;
  bool _hasError = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final list = await _phq9QuestionService.getAllQuestions();
      setState(() {
        _questions = list;
        _filteredQuestions = list;
        _hasError = list.isEmpty;
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
        _questions.where((q) {
          final question = (q['question'] ?? '').toLowerCase();
          return question.contains(lowerQuery);
        }).toList();

    setState(() {
      _filteredQuestions = filtered;
    });
  }

  Future<void> reload() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    await _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return const Center(child: Text("Error fetching PHQ-9 questions"));
    }

    if (_questions.isEmpty) {
      return const Center(child: Text("No PHQ-9 questions available"));
    }

    return ListView.separated(
      itemCount: _filteredQuestions.length,
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final question = _filteredQuestions[index];
        return ReusableCardWidget(
          child: ListTile(
            title: Text(question['question'] ?? 'Unnamed Question'),
            leading: const Icon(Icons.help_outline),
            onTap: () {}, // no edit function as per your instruction
          ),
        );
      },
    );
  }
}
