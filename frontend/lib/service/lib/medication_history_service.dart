import 'dart:convert';
import 'package:http/http.dart' as http;
import '../base_service.dart';

class MedicationHistoryService extends BaseService {
  // 1. Create medication history
  Future<Map<String, dynamic>?> createMedicationHistory(
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await getAuthToken();
      final response = await http.post(
        url('medication-history/create'),
        headers: headersWithToken(token),
        body: jsonEncode(data),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 201
          ? body
          : {
            'error': body['message'] ?? 'Failed to create medication history',
            'statusCode': response.statusCode,
          };
    } catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  // 2. Get medication history by ID
  Future<Map<String, dynamic>?> getMedicationHistoryByID(int id) async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('medication-history/$id'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? body['medication_history']
          : {
            'error': body['message'] ?? 'Medication history not found',
            'statusCode': response.statusCode,
          };
    } catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  // 3. Get all medication histories
  Future<List<Map<String, dynamic>>> getAllMedicationHistories() async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('medication-history/all'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? List<Map<String, dynamic>>.from(body['medication_histories'])
          : [
            {
              'error':
                  body['message'] ?? 'Failed to fetch medication histories',
            },
          ];
    } catch (e) {
      return [
        {'error': e.toString()},
      ];
    }
  }

  // // 4. Get medication histories by patient ID
  // Future<List<Map<String, dynamic>>> getMedicationHistoriesByPatient(
  //   int patientID,
  // ) async {
  //   try {
  //     final token = await getAuthToken();
  //     final response = await http.get(
  //       url('medication-history/patient/$patientID'),
  //       headers: headersWithToken(token),
  //     );

  //     final body = jsonDecode(response.body);
  //     return response.statusCode == 200
  //         ? List<Map<String, dynamic>>.from(body['medication_histories'])
  //         : [
  //           {
  //             'error':
  //                 body['message'] ?? 'Failed to fetch medication histories',
  //           },
  //         ];
  //   } catch (e) {
  //     return [
  //       {'error': e.toString()},
  //     ];
  //   }
  // }

  // 5. Update medication history
  Future<Map<String, dynamic>?> updateMedicationHistory(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await getAuthToken();
      final response = await http.put(
        url('medication-history/$id'),
        headers: headersWithToken(token),
        body: jsonEncode(data),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? body
          : {
            'error': body['message'] ?? 'Failed to update medication history',
            'statusCode': response.statusCode,
          };
    } catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  // 6. Delete medication history
  Future<bool> deleteMedicationHistory(int id) async {
    try {
      final token = await getAuthToken();
      final response = await http.delete(
        url('medication-history/$id'),
        headers: headersWithToken(token),
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // 7. Search medication histories
  Future<List<Map<String, dynamic>>> searchMedicationHistories({
    String? patientID,
    String? prescribingDoctorID,
    String? healthCenter,
    String? externalDoctorName,
  }) async {
    try {
      final token = await getAuthToken();

      final Map<String, String> queryParams = {};
      if (patientID != null && patientID.isNotEmpty) {
        queryParams['patient_id'] = patientID;
      }
      if (prescribingDoctorID != null && prescribingDoctorID.isNotEmpty) {
        queryParams['prescribing_doctor_id'] = prescribingDoctorID;
      }
      if (healthCenter != null && healthCenter.isNotEmpty) {
        queryParams['health_center'] = healthCenter;
      }
      if (externalDoctorName != null && externalDoctorName.isNotEmpty) {
        queryParams['external_doctor_name'] = externalDoctorName;
      }

      final uri = Uri.parse(
        url('medication-history/search').toString(),
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headersWithToken(token));
      final body = jsonDecode(response.body);

      return response.statusCode == 200
          ? List<Map<String, dynamic>>.from(body['medication_histories'])
          : [];
    } catch (e) {
      return [];
    }
  }
}
