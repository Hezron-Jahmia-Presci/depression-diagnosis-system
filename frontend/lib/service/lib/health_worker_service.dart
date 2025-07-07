import 'dart:convert';
import 'package:http/http.dart' as http;
import '../base_service.dart';

class HealthWorkerService extends BaseService {
  // 1. Create Health Worker (Admin only)
  Future<Map<String, dynamic>?> createHealthWorker(
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await getAuthToken();
      final response = await http.post(
        url('health-workers/create'),
        headers: headersWithToken(token),
        body: jsonEncode(data),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 201
          ? body
          : {
            'error': body['message'] ?? 'Creation failed',
            'statusCode': response.statusCode,
          };
    } catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  // 2. Get Health Worker by ID (me)
  Future<Map<String, dynamic>?> getHealthWorkerById() async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('health-workers/me'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? body['health_worker']
          : {
            'error': body['message'] ?? 'Not found',
            'statusCode': response.statusCode,
          };
    } catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  // 3. Get All Health Workers
  Future<List<Map<String, dynamic>>> getAllHealthWorkers() async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('health-workers/all'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? List<Map<String, dynamic>>.from(body['health_workers'])
          : [];
    } catch (e) {
      return [];
    }
  }

  // 4. Update Health Worker by ID
  Future<Map<String, dynamic>?> updateHealthWorker(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await getAuthToken();
      final response = await http.put(
        url('health-workers/$id'),
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

  // 5. Delete Health Worker by ID
  Future<bool> deleteHealthWorker(int id) async {
    try {
      final token = await getAuthToken();
      final response = await http.delete(
        url('health-workers/$id'),
        headers: headersWithToken(token),
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // 6. Login (Email or Employee ID)
  Future<Map<String, dynamic>?> loginHealthWorker(
    String identifier,
    String password,
  ) async {
    try {
      final response = await http.post(
        url('health-workers/login'),
        headers: headersWithToken(null),
        body: jsonEncode({'identifier': identifier, 'password': password}),
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

  // 7. Logout
  Future<bool> logoutHealthWorker() async {
    try {
      final token = await getAuthToken();
      final response = await http.post(
        url('health-workers/logout'),
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

  // 8. Activate or Deactivate Health Worker by ID
  Future<Map<String, dynamic>?> setActiveStatus(int id, bool isActive) async {
    try {
      final token = await getAuthToken();
      final response = await http.put(
        url('health-workers/$id/active'),
        headers: headersWithToken(token),
        body: jsonEncode({'is_active': isActive}),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? body
          : {
            'error': body['message'] ?? 'Status update failed',
            'statusCode': response.statusCode,
          };
    } catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  // 9. Search Health Workers
  Future<List<Map<String, dynamic>>> searchHealthWorkers({
    String? name,
    String? email,
    String? employeeID,
    String? role,
    String? departmentID,
    bool? isActive,
  }) async {
    try {
      final token = await getAuthToken();

      final Map<String, String> queryParams = {};
      if (name != null && name.isNotEmpty) queryParams['name'] = name;
      if (email != null && email.isNotEmpty) queryParams['email'] = email;
      if (employeeID != null && employeeID.isNotEmpty)
        queryParams['employee_id'] = employeeID;
      if (role != null && role.isNotEmpty) queryParams['role'] = role;
      if (departmentID != null && departmentID.isNotEmpty)
        queryParams['department_id'] = departmentID;
      if (isActive != null) queryParams['is_active'] = isActive.toString();

      final uri = Uri.parse(
        url('health-workers/search').toString(),
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headersWithToken(token));

      final body = jsonDecode(response.body);

      return response.statusCode == 200
          ? List<Map<String, dynamic>>.from(body['health_workers'])
          : [];
    } catch (e) {
      return [];
    }
  }
}
