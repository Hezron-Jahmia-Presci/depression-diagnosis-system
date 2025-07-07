import 'dart:convert';
import 'package:http/http.dart' as http;
import '../base_service.dart';

class PersonnelTypeService extends BaseService {
  // 1. Create Personnel Type (Admin only)
  Future<Map<String, dynamic>?> createPersonnelType(
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await getAuthToken();
      final response = await http.post(
        url('personnel-types/create'),
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

  // 2. Get All Personnel Types
  Future<List<Map<String, dynamic>>> getAllPersonnelTypes() async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('personnel-types/all'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? List<Map<String, dynamic>>.from(body['personnel_types'])
          : [];
    } catch (e) {
      return [];
    }
  }

  // 3. Get Personnel Type by ID
  Future<Map<String, dynamic>?> getPersonnelTypeById(int id) async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('personnel-types/$id'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? body['personnel_type']
          : {
            'error': body['message'] ?? 'Not found',
            'statusCode': response.statusCode,
          };
    } catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  // 4. Delete Personnel Type (Admin only)
  Future<bool> deletePersonnelType(int id) async {
    try {
      final token = await getAuthToken();
      final response = await http.delete(
        url('personnel-types/$id'),
        headers: headersWithToken(token),
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // 5. Search PersonnelType
  Future<List<Map<String, dynamic>>> searchPersonnelTypes({
    String? name,
  }) async {
    try {
      final token = await getAuthToken();

      final Map<String, String> queryParams = {};
      if (name != null && name.isNotEmpty) queryParams['name'] = name;

      final uri = Uri.parse(
        url('personnel-types/search').toString(),
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headersWithToken(token));

      final body = jsonDecode(response.body);

      return response.statusCode == 200
          ? List<Map<String, dynamic>>.from(body['personnel_types'])
          : [];
    } catch (e) {
      return [];
    }
  }
}
