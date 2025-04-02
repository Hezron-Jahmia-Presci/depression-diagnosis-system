import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminService {
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

  Future<Map<String, dynamic>?> registerAdmin(
    Map<String, dynamic> adminData,
  ) async {
    try {
      final token = await _getAuthToken();
      final response = await http.post(
        Uri.parse('$baseUrl/admin/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(adminData),
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

  Future<Map<String, dynamic>?> loginAdmin(
    String email,
    String password,
  ) async {
    try {
      final token = await _getAuthToken();
      final response = await http.post(
        Uri.parse('$baseUrl/admin/login'),
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

  Future<bool> logoutAdmin() async {
    try {
      final token = await _getAuthToken();
      final response = await http.post(
        Uri.parse('$baseUrl/admin/logout'),
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

  Future<Map<String, dynamic>?> getAdminDetails() async {
    try {
      final token = await _getAuthToken();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/details'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data['admin'];
      } else {
        return {'error': data['message'] ?? 'Failed to fetch details'};
      }
    } catch (e) {
      return {'error': 'An error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>?> updateAdmin(
    Map<String, dynamic> updatedData,
  ) async {
    try {
      final token = await _getAuthToken();
      final response = await http.put(
        Uri.parse('$baseUrl/admin/update'),
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
