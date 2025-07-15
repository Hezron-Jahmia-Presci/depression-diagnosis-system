import 'dart:convert';
import 'package:http/http.dart' as http;
import '../base_service.dart';

class Phq9ResponseService extends BaseService {
  // 1. Create PHQ-9 response (open to authenticated users)
  Future<Map<String, dynamic>?> createResponse(
    int sessionId,
    List<Map<String, dynamic>> responseData,
  ) async {
    try {
      final token = await getAuthToken();
      final response = await http.post(
        url('phq9/responsess/create/$sessionId'),
        headers: headersWithToken(token),
        body: jsonEncode(responseData),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 201
          ? body
          : {
            'error': body['message'] ?? 'Failed to create PHQ-9 response',
            'statusCode': response.statusCode,
          };
    } catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  // 2. Get PHQ-9 response by session ID (open to authenticated users)
  Future<List<Map<String, dynamic>>> getResponseBySessionID(
    int sessionID,
  ) async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('phq9/responses/$sessionID'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? List<Map<String, dynamic>>.from(body['response'])
          : [];
    } catch (e) {
      return [];
    }
  }

  // 3. Update PHQ-9 response (admin or psychiatrist)
  Future<Map<String, dynamic>?> updateResponse(
    int responseID,
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await getAuthToken();
      final response = await http.put(
        url('phq9/responses/$responseID'),
        headers: headersWithToken(token),
        body: jsonEncode(data),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? body
          : {
            'error': body['message'] ?? 'Failed to update PHQ-9 response',
            'statusCode': response.statusCode,
          };
    } catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  // 4. Delete PHQ-9 response (admin only)
  Future<bool> deleteResponse(int responseID) async {
    try {
      final token = await getAuthToken();
      final response = await http.delete(
        url('phq9/responses/$responseID'),
        headers: headersWithToken(token),
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
