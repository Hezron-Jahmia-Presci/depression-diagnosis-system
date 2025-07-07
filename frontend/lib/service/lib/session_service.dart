import 'dart:convert';
import 'package:http/http.dart' as http;
import '../base_service.dart';

class SessionService extends BaseService {
  // 1. Create Session
  Future<Map<String, dynamic>> createSession(Map<String, dynamic> data) async {
    final token = await getAuthToken();
    final response = await http.post(
      url('sessions/create'),
      headers: headersWithToken(token),
      body: jsonEncode(data),
    );

    final body = jsonDecode(response.body);
    return response.statusCode == 201
        ? body
        : {
          'error': body['message'] ?? 'Failed to create session',
          'statusCode': response.statusCode,
        };
  }

  // 2. Get Session by ID
  Future<Map<String, dynamic>?> getSessionByID(int sessionID) async {
    final token = await getAuthToken();
    final response = await http.get(
      url('sessions/$sessionID'),
      headers: headersWithToken(token),
    );

    final body = jsonDecode(response.body);
    return response.statusCode == 200
        ? body['session']
        : {
          'error': body['message'] ?? 'Session not found',
          'statusCode': response.statusCode,
        };
  }

  // 3. Get All Sessions
  Future<List<Map<String, dynamic>>> getAllSessions() async {
    final token = await getAuthToken();
    final response = await http.get(
      url('sessions/all'),
      headers: headersWithToken(token),
    );

    final body = jsonDecode(response.body);
    return response.statusCode == 200
        ? List<Map<String, dynamic>>.from(body['sessions'])
        : [
          {'error': body['message'] ?? 'Failed to fetch sessions'},
        ];
  }

  // 4. Update Session
  Future<Map<String, dynamic>?> updateSession(
    int id,
    Map<String, dynamic> updatedData,
  ) async {
    final token = await getAuthToken();
    final response = await http.put(
      url('sessions/$id'),
      headers: headersWithToken(token),
      body: jsonEncode(updatedData),
    );

    final body = jsonDecode(response.body);
    return response.statusCode == 200
        ? body
        : {
          'error': body['message'] ?? 'Failed to update session',
          'statusCode': response.statusCode,
        };
  }

  // 5. Delete Session
  Future<bool> deleteSession(int id) async {
    final token = await getAuthToken();
    final response = await http.delete(
      url('sessions/$id'),
      headers: headersWithToken(token),
    );

    return response.statusCode == 200;
  }

  // 6. Get Session by Code
  Future<Map<String, dynamic>?> getSessionByCode(String code) async {
    final token = await getAuthToken();
    final response = await http.get(
      url('sessions/code/$code'),
      headers: headersWithToken(token),
    );

    final body = jsonDecode(response.body);
    return response.statusCode == 200
        ? body['session']
        : {
          'error': body['message'] ?? 'Session not found by code',
          'statusCode': response.statusCode,
        };
  }

  // 7. Get Sessions by Patient ID
  Future<List<Map<String, dynamic>>> getSessionsByPatient(int patientId) async {
    final token = await getAuthToken();
    final response = await http.get(
      url('sessions/patient/$patientId'),
      headers: headersWithToken(token),
    );

    final body = jsonDecode(response.body);
    return response.statusCode == 200
        ? List<Map<String, dynamic>>.from(body['sessions'])
        : [
          {'error': body['message'] ?? 'Failed to fetch patient sessions'},
        ];
  }

  // 8. Get Sessions by Health Worker ID
  Future<List<Map<String, dynamic>>> getSessionsByHealthWorker() async {
    final token = await getAuthToken();
    final response = await http.get(
      url('sessions/healthworker/me'),
      headers: headersWithToken(token),
    );

    final body = jsonDecode(response.body);
    return response.statusCode == 200
        ? List<Map<String, dynamic>>.from(body['sessions'])
        : [
          {'error': body['message'] ?? 'Failed to fetch sessions'},
        ];
  }

  // 9. Update Sessions byrID
  Future<Map<String, dynamic>?> updateSessionStatus(
    int sessionID,
    String status,
  ) async {
    final token = await getAuthToken();
    final response = await http.put(
      url('sessions/status'),
      headers: headersWithToken(token),
      body: jsonEncode({'sessionID': sessionID, 'status': status}),
    );

    final body = jsonDecode(response.body);
    return response.statusCode == 200
        ? body
        : {
          'error': body['message'] ?? 'Failed to update status',
          'statusCode': response.statusCode,
        };
  }

  // 10. Search sessions
  Future<List<Map<String, dynamic>>> searchSessions({
    String? sessionCode,
    String? healthWorkerID,
    String? patientID,
    String? status,
    bool? isActive,
  }) async {
    try {
      final token = await getAuthToken();

      final Map<String, String> queryParams = {};
      if (sessionCode != null && sessionCode.isNotEmpty) {
        queryParams['session_code'] = sessionCode;
      }
      if (healthWorkerID != null && healthWorkerID.isNotEmpty) {
        queryParams['health_worker_id'] = healthWorkerID;
      }
      if (patientID != null && patientID.isNotEmpty) {
        queryParams['patient_id'] = patientID;
      }
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final uri = Uri.parse(
        url('sessions/search').toString(),
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headersWithToken(token));

      final body = jsonDecode(response.body);

      return response.statusCode == 200
          ? List<Map<String, dynamic>>.from(body['sessons'])
          : [];
    } catch (e) {
      return [];
    }
  }
}
