import 'dart:convert';
import 'package:http/http.dart' as http;
import '../base_service.dart';

class Phq9QuestionService extends BaseService {
  // 1. Create PHQ-9 Question (admin only)
  Future<Map<String, dynamic>?> createQuestion(
    Map<String, dynamic> questionData,
  ) async {
    try {
      final token = await getAuthToken();
      final response = await http.post(
        url('phq9/questions/create'),
        headers: headersWithToken(token),
        body: jsonEncode(questionData),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 201
          ? body
          : {
            'error': body['message'] ?? 'Failed to create PHQ-9 question',
            'statusCode': response.statusCode,
          };
    } catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  // 2. Get all PHQ-9 Questions (open to authenticated users)
  Future<List<Map<String, dynamic>>> getAllQuestions() async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('phq9/questions/all'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? List<Map<String, dynamic>>.from(body['questions'])
          : [];
    } catch (e) {
      return [];
    }
  }

  // 3. Get PHQ-9 Question by ID
  Future<Map<String, dynamic>?> getQuestionByID(int questionID) async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('phq9/questions/$questionID'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? body['question']
          : {
            'error': body['message'] ?? 'Question not found',
            'statusCode': response.statusCode,
          };
    } catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  // 4. Delete PHQ-9 Question (admin only)
  Future<bool> deleteQuestion(int questionID) async {
    try {
      final token = await getAuthToken();
      final response = await http.delete(
        url('phq9/questions/$questionID'),
        headers: headersWithToken(token),
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
