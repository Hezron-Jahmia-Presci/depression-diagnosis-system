import 'dart:convert';
import 'package:http/http.dart' as http;
import '../base_service.dart';

class MessageService extends BaseService {
  // 1. Send a message
  Future<Map<String, dynamic>?> sendMessage({
    required int senderId,
    required int receiverId,
    required String message,
  }) async {
    try {
      final token = await getAuthToken();
      final data = {
        'sender_id': senderId,
        'receiver_id': receiverId,
        'message': message,
      };

      final response = await http.post(
        url('messages/send'),
        headers: headersWithToken(token),
        body: jsonEncode(data),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 201
          ? body
          : {
            'error': body['message'] ?? 'Failed to send message',
            'statusCode': response.statusCode,
          };
    } catch (e) {
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  // 2. Get messages between two health workers
  Future<List<Map<String, dynamic>>> getMessagesBetween({
    required int senderId,
    required int receiverId,
  }) async {
    try {
      final token = await getAuthToken();
      final uri = Uri.parse(url('messages/between').toString()).replace(
        queryParameters: {
          'sender_id': senderId.toString(),
          'receiver_id': receiverId.toString(),
        },
      );

      final response = await http.get(uri, headers: headersWithToken(token));
      final body = jsonDecode(response.body);

      return response.statusCode == 200
          ? List<Map<String, dynamic>>.from(body['messages'])
          : [];
    } catch (e) {
      return [];
    }
  }

  // 3. Get inbox messages for logged-in user
  Future<List<Map<String, dynamic>>> getInbox() async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        url('messages/inbox'),
        headers: headersWithToken(token),
      );

      final body = jsonDecode(response.body);
      return response.statusCode == 200
          ? List<Map<String, dynamic>>.from(body['inbox'])
          : [];
    } catch (e) {
      return [];
    }
  }
}
