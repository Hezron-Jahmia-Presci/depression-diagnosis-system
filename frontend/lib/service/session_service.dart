import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionService {
  final String baseUrl = "http://localhost:8080";
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<String?> _getAuthToken() async {
    return await storage.read(key: 'token');
  }

  Future<Map<String, dynamic>> createSession(
    Map<String, dynamic> sessionData,
  ) async {
    String? token = await _getAuthToken();
    if (token == null) {
      return {'error': 'No authentication token found'};
    }

    final response = await http.post(
      Uri.parse('$baseUrl/sessions/create'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(sessionData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {'error': jsonDecode(response.body)['message']};
    }
  }

  Future<Map<String, dynamic>> createFollowUpSession(
    String originalSessionID,
    String date,
  ) async {
    String? token = await _getAuthToken();
    if (token == null) {
      return {'error': 'No authentication token found'};
    }

    final response = await http.post(
      Uri.parse('$baseUrl/sessions/follow-up'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'originalSessionID': originalSessionID, 'date': date}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {'error': jsonDecode(response.body)['message']};
    }
  }

  Future<Map<String, dynamic>?> updateSessionStatus(
    int sessionID,
    String status,
  ) async {
    final token = await _getAuthToken();
    final response = await http.put(
      Uri.parse('$baseUrl/sessions/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'sessionID': sessionID, 'status': status}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'error': jsonDecode(response.body)['message']};
    }
  }

  Future<List<dynamic>?> getSessionsByPsychiatrist() async {
    final token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/sessions/psych'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['sessions'];
    } else {
      return [
        {'error': jsonDecode(response.body)['message']},
      ];
    }
  }

  Future<List<dynamic>?> getAllSessions() async {
    final token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/sessions/all'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['sessions'];
    } else {
      return [
        {'error': jsonDecode(response.body)['message']},
      ];
    }
  }

  Future<Map<String, dynamic>?> getSessionByID(int sessionID) async {
    final token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/sessions/$sessionID'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['session'];
    } else {
      return {'error': jsonDecode(response.body)['message']};
    }
  }
}
