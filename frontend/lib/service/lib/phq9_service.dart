import 'dart:convert';
import 'package:http/http.dart' as http;
import '../base_service.dart';

class Phq9Service extends BaseService {
  Future<Map<String, dynamic>?> createQuestion(
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await getAuthToken();
      final response = await http.post(
        url('phq9/questions'),
        headers: headersWithToken(token),
        body: jsonEncode(data),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 201
          ? body
          : {
            'error': body['message'] ?? 'Failed to create question',
            'statusCode': response.statusCode,
          };
    } on Exception catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  Future<List<Map<String, dynamic>>> getAllQuestions() async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('phq9/questions'),
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

  Future<Map<String, dynamic>?> getQuestionById(int questionId) async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('phq9/questions/$questionId'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? body['question']
          : {
            'error': body['message'] ?? 'Question not found',
            'statusCode': response.statusCode,
          };
    } on Exception catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  Future<Map<String, dynamic>?> recordResponsesForSession(
    int sessionId,
    List<Map<String, dynamic>> responses,
  ) async {
    try {
      final token = await getAuthToken();
      final response = await http.post(
        url('phq9/responses/$sessionId'),
        headers: headersWithToken(token),
        body: jsonEncode(responses),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 201
          ? body
          : {
            'error': body['message'] ?? 'Failed to record responses',
            'statusCode': response.statusCode,
          };
    } on Exception catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  Future<List<Map<String, dynamic>>> getResponsesForSession(
    int sessionId,
  ) async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('phq9/responses/$sessionId'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? List<Map<String, dynamic>>.from(body['responses'])
          : [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getResponseSummary(int sessionId) async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('phq9/summary/$sessionId'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? body
          : {
            'error': body['message'] ?? 'Failed to fetch summary',
            'statusCode': response.statusCode,
          };
    } on Exception catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }
}
