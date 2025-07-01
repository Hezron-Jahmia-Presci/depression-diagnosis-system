import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class BaseService {
  // TODO: Replace with your actual deployed URL in production
  final String baseUrl = "http://localhost:8080/api/v1/";

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<String?> getAuthToken() async {
    return await storage.read(key: 'token');
  }

  Future<void> saveAuthToken(String token) async {
    await storage.write(key: 'token', value: token);
  }

  Future<void> clearAuthToken() async {
    await storage.delete(key: 'token');
  }

  Map<String, String> headersWithToken(String? token) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Uri url(String path) => Uri.parse('$baseUrl$path');
}
