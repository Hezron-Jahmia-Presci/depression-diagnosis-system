import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PatientService {
  final String baseUrl = "http://localhost:8080";
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<String?> _getAuthToken() async {
    return await storage.read(key: 'token');
  }

  Future<Map<String, dynamic>?> registerPatient(
    Map<String, dynamic> patientData,
  ) async {
    final token = await _getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl/patients/register'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(patientData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {'error': jsonDecode(response.body)['message']};
    }
  }

  Future<List<dynamic>?> getAllPatients() async {
    final token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/patients/all'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['patients'];
    } else {
      return [
        {'error': jsonDecode(response.body)['message']},
      ];
    }
  }

  Future<Map<String, dynamic>?> getPatientDetailsById(int patientId) async {
    final token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/patients/details/$patientId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['patient'];
    } else {
      return {'error': jsonDecode(response.body)['message']};
    }
  }

  Future<Map<String, dynamic>?> updatePatient(
    Map<String, dynamic> patientData,
  ) async {
    final token = await _getAuthToken();
    final response = await http.put(
      Uri.parse('$baseUrl/patients/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(patientData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'error': jsonDecode(response.body)['message']};
    }
  }

  Future<List<dynamic>?> getPatientsByPsychiatrist() async {
    final token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/patients/psych'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['patients'];
    } else {
      return [
        {'error': 'No authentication token found'},
      ];
    }
  }
}
