import 'dart:convert';
import 'package:http/http.dart' as http;
import '../base_service.dart';

class SessionSummaryService extends BaseService {
  Future<Map<String, dynamic>?> createSessionSummary(
    int sessionID,
    String notes,
  ) async {
    final token = await getAuthToken();
    final response = await http.post(
      url('session-summary/$sessionID'),
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

  Future<Map<String, dynamic>?> getSessionSummary(int sessionID) async {
    final token = await getAuthToken();
    final response = await http.get(
      url('session-summary/$sessionID'),
      headers: headersWithToken(token),
    );

    final body = jsonDecode(response.body);
    return response.statusCode == 200
        ? body['summary']
        : {
          'error': body['message'] ?? 'Summary not found',
          'statusCode': response.statusCode,
        };
  }
}
