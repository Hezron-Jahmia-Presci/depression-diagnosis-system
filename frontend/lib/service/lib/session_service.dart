import 'dart:convert';
import 'package:http/http.dart' as http;
import '../base_service.dart';

class SessionService extends BaseService {
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

  Future<List<Map<String, dynamic>>> getSessionsByPsychiatrist() async {
    final token = await getAuthToken();
    final response = await http.get(
      url('sessions/mine'),
      headers: headersWithToken(token),
    );

    final body = jsonDecode(response.body);
    return response.statusCode == 200
        ? List<Map<String, dynamic>>.from(body['sessions'])
        : [
          {'error': body['message'] ?? 'Failed to fetch sessions'},
        ];
  }

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
          {'error': body['message'] ?? 'Failed to fetch all sessions'},
        ];
  }

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
}
