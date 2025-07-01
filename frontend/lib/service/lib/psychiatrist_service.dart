import 'dart:convert';
import 'package:http/http.dart' as http;
import '../base_service.dart';

class PsychiatristService extends BaseService {
  Future<Map<String, dynamic>?> registerPsychiatrist(
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await getAuthToken();
      final response = await http.post(
        url('psychiatrists/create'),
        headers: headersWithToken(token),
        body: jsonEncode(data),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 201
          ? body
          : {
            'error': body['message'] ?? 'Registration failed',
            'statusCode': response.statusCode,
          };
    } catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  Future<Map<String, dynamic>?> loginPsychiatrist(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        url('psychiatrists/login'),
        headers: headersWithToken(null),
        body: jsonEncode({'email': email, 'password': password}),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (body['token'] != null) {
          await saveAuthToken(body['token']);
        }
        return body;
      } else {
        return {
          'error': body['message'] ?? 'Login failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  Future<bool> logoutPsychiatrist() async {
    try {
      final token = await getAuthToken();
      final response = await http.post(
        url('psychiatrists/logout'),
        headers: headersWithToken(token),
      );

      if (response.statusCode == 200) {
        await clearAuthToken();
        return true;
      } else {
        return false;
      }
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getPsychiatristDetails() async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('psychiatrists/me'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? body['psychiatrist']
          : {
            'error': body['message'] ?? 'Failed to fetch details',
            'statusCode': response.statusCode,
          };
    } catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  Future<Map<String, dynamic>?> updatePsychiatrist(
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await getAuthToken();
      final response = await http.put(
        url('psychiatrists/'),
        headers: headersWithToken(token),
        body: jsonEncode(data),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? body
          : {
            'error': body['message'] ?? 'Update failed',
            'statusCode': response.statusCode,
          };
    } catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  Future<List<Map<String, dynamic>>> getAllPsychiatrists() async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('psychiatrists/'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? List<Map<String, dynamic>>.from(body['psychiatrists'])
          : [];
    } catch (e) {
      return [];
    }
  }
}
