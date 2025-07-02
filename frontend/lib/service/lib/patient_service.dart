import 'dart:convert';
import 'package:http/http.dart' as http;
import '../base_service.dart';

class PatientService extends BaseService {
  Future<Map<String, dynamic>?> registerPatient(
    Map<String, dynamic> patientData,
  ) async {
    try {
      final token = await getAuthToken();
      final response = await http.post(
        url('patients/create'),
        headers: headersWithToken(token),
        body: jsonEncode(patientData),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 201
          ? body
          : {
            'error': body['message'] ?? 'Failed to register patient',
            'statusCode': response.statusCode,
          };
    } on Exception catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  Future<List<Map<String, dynamic>>> getAllPatients() async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('patients/all'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? List<Map<String, dynamic>>.from(body['patients'])
          : [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getPatientByID(int patientId) async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('patients/$patientId'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? body['patient']
          : {
            'error': body['message'] ?? 'Patient not found',
            'statusCode': response.statusCode,
          };
    } on Exception catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  Future<Map<String, dynamic>?> updatePatient(Map<String, dynamic> data) async {
    try {
      final token = await getAuthToken();
      final response = await http.put(
        url('patients/update'),
        headers: headersWithToken(token),
        body: jsonEncode(data),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? body
          : {
            'error': body['message'] ?? 'Failed to update patient',
            'statusCode': response.statusCode,
          };
    } on Exception catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  Future<List<Map<String, dynamic>>> getPatientsByPsychiatrist() async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('patients/mine'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? List<Map<String, dynamic>>.from(body['patients'])
          : [];
    } catch (e) {
      return [];
    }
  }
}
