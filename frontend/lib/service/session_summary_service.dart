import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionSummaryService {
  final String baseUrl = "http://localhost:8080";
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<String?> _getAuthToken() async {
    return await storage.read(key: 'token');
  }

  Future<Map<String, dynamic>?> createSessionSummary(
    int sessionID,
    String notes,
  ) async {
    final token = await _getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl/session/summary/create/$sessionID'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'notes': notes}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {'error': jsonDecode(response.body)['message']};
    }
  }

  Future<Map<String, dynamic>?> getSessionSummary(int sessionID) async {
    final token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/session/summary/$sessionID'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['sessionSummary'];
    } else {
      return {'error': jsonDecode(response.body)['message']};
    }
  }
}
