import 'dart:convert';
import 'package:http/http.dart' as http;
import '../base_service.dart';

class SessionSummaryService extends BaseService {
  // 1. Create Session Summary
  Future<Map<String, dynamic>?> createSessionSummary(
    int sessionID,
    String notes,
  ) async {
    final token = await getAuthToken();
    final response = await http.post(
      url('session-summaries/$sessionID'),
      headers: headersWithToken(token),
      body: jsonEncode({'notes': notes}),
    );

    final body = jsonDecode(response.body);
    return response.statusCode == 201
        ? body
        : {
          'error': body['message'] ?? 'Failed to create summary',
          'statusCode': response.statusCode,
        };
  }

  // 2. Get Session Summary by Session ID
  Future<Map<String, dynamic>?> getSessionSummary(int sessionID) async {
    final token = await getAuthToken();
    final response = await http.get(
      url('session-summaries/$sessionID'),
      headers: headersWithToken(token),
    );

    final body = jsonDecode(response.body);
    return response.statusCode == 200
        ? body['session_summary']
        : {
          'error': body['message'] ?? 'Summary not found',
          'statusCode': response.statusCode,
        };
  }

  // 3. Update Session Summary
  Future<Map<String, dynamic>?> updateSessionSummary(
    int summaryID,
    Map<String, dynamic> updatedData,
  ) async {
    final token = await getAuthToken();
    final response = await http.put(
      url('session-summaries/$summaryID'),
      headers: headersWithToken(token),
      body: jsonEncode(updatedData),
    );

    final body = jsonDecode(response.body);
    return response.statusCode == 200
        ? body
        : {
          'error': body['message'] ?? 'Failed to update session summary',
          'statusCode': response.statusCode,
        };
  }

  // 4. Delete Session Summary
  Future<bool> deleteSessionSummary(int summaryID) async {
    final token = await getAuthToken();
    final response = await http.delete(
      url('session-summaries/$summaryID'),
      headers: headersWithToken(token),
    );

    return response.statusCode == 200;
  }
}
