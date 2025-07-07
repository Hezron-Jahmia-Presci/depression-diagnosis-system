import 'dart:convert';
import 'package:http/http.dart' as http;
import '../base_service.dart';

class DepartmentService extends BaseService {
  // 1. Create Department (Admin only)
  Future<Map<String, dynamic>?> createDepartment(
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await getAuthToken();
      final response = await http.post(
        url('departments/create'),
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

  // 2. Get Department by ID
  Future<Map<String, dynamic>?> getDepartmentById(int id) async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('departments/$id'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? body['department']
          : {
            'error': body['message'] ?? 'Not found',
            'statusCode': response.statusCode,
          };
    } catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  // 3. Get All Departments
  Future<List<Map<String, dynamic>>> getAllDepartments() async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('departments/all'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? List<Map<String, dynamic>>.from(body['departments'])
          : [];
    } catch (e) {
      return [];
    }
  }

  // 4. Update Department by ID
  Future<Map<String, dynamic>?> updateDepartment(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await getAuthToken();
      final response = await http.put(
        url('departments/$id'),
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

  // 5. Delete Department by ID
  Future<bool> deleteDepartment(int id) async {
    try {
      final token = await getAuthToken();
      final response = await http.delete(
        url('departments/$id'),
        headers: headersWithToken(token),
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // 6. Search Departments by query param (e.g., name)
  Future<List<Map<String, dynamic>>> searchDepartments({String? name}) async {
    try {
      final token = await getAuthToken();

      final Map<String, String> queryParams = {};
      if (name != null && name.isNotEmpty) queryParams['name'] = name;

      final uri = Uri.parse(
        url('departments/search').toString(),
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headersWithToken(token));
      final body = jsonDecode(response.body);

      return response.statusCode == 200
          ? List<Map<String, dynamic>>.from(body['departments'])
          : [];
    } catch (e) {
      return [];
    }
  }
}
