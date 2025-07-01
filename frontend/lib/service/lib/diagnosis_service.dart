import 'dart:convert';
import 'package:http/http.dart' as http;
import '../base_service.dart';

class DiagnosisService extends BaseService {
  Future<Map<String, dynamic>?> createDiagnosis(int sessionId) async {
    try {
      final token = await getAuthToken();
      final response = await http.post(
        url('diagnosis/$sessionId'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 201
          ? body
          : {
            'error': body['message'] ?? 'Failed to create diagnosis',
            'statusCode': response.statusCode,
          };
    } on Exception catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  Future<Map<String, dynamic>?> getDiagnosisBySessionId(int sessionId) async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('diagnosis/$sessionId'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? body
          : {
            'error': body['message'] ?? 'Failed to fetch diagnosis',
            'statusCode': response.statusCode,
          };
    } on Exception catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }
}
