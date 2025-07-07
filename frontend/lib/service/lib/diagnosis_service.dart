import 'dart:convert';
import 'package:http/http.dart' as http;
import '../base_service.dart';

class DiagnosisService extends BaseService {
  // 1. Create Diagnosis by Session ID
  Future<Map<String, dynamic>?> createDiagnosis(int sessionId) async {
    try {
      final token = await getAuthToken();
      final response = await http.post(
        url('diagnosis/$sessionId'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 201
          ? body // Return entire response so you can access message + diagnosis
          : {
            'error': body['message'] ?? 'Failed to create diagnosis',
            'statusCode': response.statusCode,
          };
    } catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  // 2. Get Diagnosis by Session ID
  Future<Map<String, dynamic>?> getDiagnosisBySessionId(int sessionId) async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('diagnosis/$sessionId'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? body // Contains 'diagnosis' and optional status
          : {
            'error': body['message'] ?? 'Failed to fetch diagnosis',
            'statusCode': response.statusCode,
          };
    } catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }
}
