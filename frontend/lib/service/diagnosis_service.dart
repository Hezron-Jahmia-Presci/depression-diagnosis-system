import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DiagnosisService {
  final String baseUrl = "http://localhost:8080";
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<String?> _getAuthToken() async {
    return await storage.read(key: 'token');
  }

  Future<Map<String, dynamic>?> createDiagnosis(int sessionId) async {
    final token = await _getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl/diagnosis/create/$sessionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      return {'error': jsonDecode(response.body)['message']};
    }
  }

  Future<Map<String, dynamic>?> getDiagnosisBySessionId(int sessionId) async {
    final token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/diagnosis/session/$sessionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {'error': jsonDecode(response.body)['message']};
    }
  }
}
