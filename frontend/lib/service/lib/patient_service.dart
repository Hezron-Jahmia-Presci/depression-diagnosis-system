import 'dart:convert';
import 'package:http/http.dart' as http;
import '../base_service.dart';

class PatientService extends BaseService {
  // 1. Create Patient
  Future<Map<String, dynamic>?> registerPatient(
    Map<String, dynamic> patientData,
  ) async {
    try {
      final token = await getAuthToken();
      final response = await http.post(
        url('patients/create'),
        headers: headersWithToken(token),
        body: jsonEncode(patientData),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 201
          ? body
          : {
            'error': body['message'] ?? 'Failed to register patient',
            'statusCode': response.statusCode,
          };
    } catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  // 2. Get Patient by ID
  Future<Map<String, dynamic>?> getPatientByID(int patientId) async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('patients/$patientId'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? body['patient']
          : {
            'error': body['message'] ?? 'Patient not found',
            'statusCode': response.statusCode,
          };
    } catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  // 3. Get All Patients
  Future<List<Map<String, dynamic>>> getAllPatients() async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('patients/all'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? List<Map<String, dynamic>>.from(body['patients'])
          : [];
    } catch (e) {
      return [];
    }
  }

  // 4. Update Patient
  Future<Map<String, dynamic>?> updatePatient(
    int id,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      final token = await getAuthToken();
      final response = await http.put(
        url('patients/$id'),
        headers: headersWithToken(token),
        body: jsonEncode(updatedData),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? body
          : {
            'error': body['message'] ?? 'Failed to update patient',
            'statusCode': response.statusCode,
          };
    } catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  // 5. Delete Patient (only allowed if patient is inactive server-side)
  Future<bool> deletePatient(int id) async {
    try {
      final token = await getAuthToken();
      final response = await http.delete(
        url('patients/$id'),
        headers: headersWithToken(token),
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // 6. Get Patients by Health Worker
  Future<List<Map<String, dynamic>>> getPatientsByHealthWorker() async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('patients/by-healthworker/me'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? List<Map<String, dynamic>>.from(body['patients'])
          : [];
    } catch (e) {
      return [];
    }
  }

  // 7. Get Specific Patient admitted by Health Worker (fix: patientId param usage)
  Future<Map<String, dynamic>?> getPatientByHealthWorker({
    required int patientId,
  }) async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('patients/by-healthworker-specific/$patientId'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200 ? body['patient'] : null;
    } catch (e) {
      return null;
    }
  }

  // 8. Get Patients by Department
  Future<List<Map<String, dynamic>>> getPatientsByDepartment(int deptId) async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('patients/by-department/$deptId'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? List<Map<String, dynamic>>.from(body['patients'])
          : [];
    } catch (e) {
      return [];
    }
  }

  // 9. Search Patients with query params
  Future<List<Map<String, dynamic>>> searchPatients({
    String? name,
    String? email,
    String? patientID,
    String? departmentID,
    bool? isActive,
  }) async {
    try {
      final token = await getAuthToken();

      final Map<String, String> queryParams = {};
      if (name != null && name.isNotEmpty) queryParams['name'] = name;
      if (email != null && email.isNotEmpty) queryParams['email'] = email;
      if (patientID != null && patientID.isNotEmpty) {
        queryParams['patient_id'] = patientID;
      }
      if (departmentID != null && departmentID.isNotEmpty) {
        queryParams['department_id'] = departmentID;
      }
      if (isActive != null) queryParams['is_active'] = isActive.toString();

      final uri = Uri.parse(
        url('patients/search').toString(),
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headersWithToken(token));

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? List<Map<String, dynamic>>.from(body['patients'])
          : [];
    } catch (e) {
      return [];
    }
  }

  // 10. Activate/Deactivate Patient (set active status)
  Future<Map<String, dynamic>?> setActiveStatus(
    int patientId,
    bool isActive,
  ) async {
    try {
      final token = await getAuthToken();
      final response = await http.put(
        url('patients/$patientId/active'),
        headers: headersWithToken(token),
        body: jsonEncode({'is_active': isActive}),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? body
          : {
            'error': body['message'] ?? 'Failed to update status',
            'statusCode': response.statusCode,
          };
    } catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }
}
