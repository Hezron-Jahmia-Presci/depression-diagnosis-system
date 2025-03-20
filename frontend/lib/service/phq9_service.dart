import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Phq9Service {
  final String baseUrl = "http://localhost:8080";
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<String?> _getAuthToken() async {
    return await storage.read(key: 'token');
  }

  Future<Map<String, dynamic>?> createQuestion(
    Map<String, dynamic> questionData,
  ) async {
    final token = await _getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl/phq9/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(questionData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      return {'error': jsonDecode(response.body)['message']};
    }
  }

  Future<List<dynamic>?> getAllQuestions() async {
    final token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/phq9/questions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['Phq9Questions'];
    } else {
      return [
        {'error': 'No authentication token found'},
      ];
    }
  }

  Future<Map<String, dynamic>?> getQuestionById(int questionId) async {
    final token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/phq9/question/$questionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['Phq9Question'];
    } else {
      return {'error': jsonDecode(response.body)['message']};
    }
  }

  Future<Map<String, dynamic>?> recordResponsesForSession(
    int sessionId,
    List<Map<String, dynamic>> responseData,
  ) async {
    final token = await _getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl/phq9/record/$sessionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(responseData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      return {'error': jsonDecode(response.body)['message']};
    }
  }

  Future<List<dynamic>?> getResponsesForSession(int sessionId) async {
    final token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/phq9/response/$sessionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['Phq9Responses'];
    } else {
      return [
        {'error': jsonDecode(response.body)['message']},
      ];
    }
  }
}
