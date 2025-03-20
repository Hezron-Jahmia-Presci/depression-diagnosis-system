import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PsychiatristService {
  final String baseUrl = "http://localhost:8080";
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<String?> _getAuthToken() async {
    return await storage.read(key: 'token');
  }

  Future<void> _saveAuthToken(String token) async {
    await storage.write(key: 'token', value: token);
  }

  Future<void> _clearAuthToken() async {
    await storage.delete(key: 'token');
  }

  Future<Map<String, dynamic>?> registerPsychiatrist(
    Map<String, dynamic> psychiatristData,
  ) async {
    try {
      final token = await _getAuthToken();
      final response = await http.post(
        Uri.parse('$baseUrl/psych/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(psychiatristData),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return data;
      } else {
        return {'error': data['message'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'error': 'An error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>?> loginPsychiatrist(
    String email,
    String password,
  ) async {
    try {
      final token = await _getAuthToken();
      final response = await http.post(
        Uri.parse('$baseUrl/psych/login'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (data['token'] != null) {
          await _saveAuthToken(data['token']);
        }
        return data;
      } else {
        return {'error': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'error': 'An error occurred: $e'};
    }
  }

  Future<bool> logoutPsychiatrist() async {
    try {
      final token = await _getAuthToken();
      final response = await http.post(
        Uri.parse('$baseUrl/psych/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await _clearAuthToken();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getPsychiatristDetails() async {
    try {
      final token = await _getAuthToken();
      final response = await http.get(
        Uri.parse('$baseUrl/psych/details'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data['psych'];
      } else {
        return {'error': data['message'] ?? 'Failed to fetch details'};
      }
    } catch (e) {
      return {'error': 'An error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>?> updatePsychiatrist(
    Map<String, dynamic> updatedData,
  ) async {
    try {
      final token = await _getAuthToken();
      final response = await http.put(
        Uri.parse('$baseUrl/psych/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updatedData),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        return {'error': data['message'] ?? 'Update failed'};
      }
    } catch (e) {
      return {'error': 'An error occurred: $e'};
    }
  }
}
