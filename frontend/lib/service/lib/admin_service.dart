import 'dart:convert';
import 'package:http/http.dart' as http;
import '../base_service.dart';

class AdminService extends BaseService {
  Future<Map<String, dynamic>?> createAdmin(Map<String, dynamic> data) async {
    try {
      final token = await getAuthToken();
      final response = await http.post(
        url('admin/create'),
        headers: headersWithToken(token),
        body: jsonEncode(data),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 201
          ? body
          : {
            'error': body['message'] ?? 'Failed to register admin',
            'statusCode': response.statusCode,
          };
    } on Exception catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  Future<Map<String, dynamic>?> loginAdmin(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        url('admin/login'),
        headers: headersWithToken(null),
        body: jsonEncode(data),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await saveAuthToken(body['token']);
        return body;
      } else {
        return {
          'error': body['message'] ?? 'Failed to login',
          'statusCode': response.statusCode,
        };
      }
    } on Exception catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  Future<bool> logoutAdmin() async {
    try {
      final token = await getAuthToken();
      final response = await http.post(
        url('admin/logout'),
        headers: headersWithToken(token),
      );
      if (response.statusCode == 200) {
        await clearAuthToken();
        return true;
      }
      return false;
    } on Exception catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getAdminDetails() async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('admin/me'),
        headers: headersWithToken(token),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['admin'];
      } else {
        return {
          'error': 'Failed to fetch admin details',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  Future<Map<String, dynamic>?> updateAdmin(Map<String, dynamic> data) async {
    try {
      final token = await getAuthToken();
      final response = await http.put(
        url('admin/update'),
        headers: headersWithToken(token),
        body: jsonEncode(data),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return body;
      } else {
        return {
          'error': body['message'] ?? 'Failed to update admin',
          'statusCode': response.statusCode,
        };
      }
    } on Exception catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  Future<Map<String, dynamic>?> deleteAdmin() async {
    try {
      final token = await getAuthToken();
      final response = await http.delete(
        url('admin/delete'),
        headers: headersWithToken(token),
      );

      if (response.statusCode == 200) {
        await clearAuthToken();
        return {'message': 'Admin deleted successfully'};
      } else {
        final body = jsonDecode(response.body);
        return {
          'error': body['message'] ?? 'Failed to delete admin',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }
}
