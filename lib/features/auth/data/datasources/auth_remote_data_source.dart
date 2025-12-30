import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String phone, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<Map<String, dynamic>> login(String phone, String password) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'phone': phone, 'password': password}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      // Attempt to read token from several possible keys (Token, token, nested)
      final dynamic tokenRaw =
          data['Token'] ??
          data['token'] ??
          (data is Map && data['data'] is Map ? data['data']['token'] : null);

      // Attempt to locate role in multiple possible shapes, including capitalized 'User'
      final dynamic userMap = (data is Map)
          ? (data['user'] ??
                data['User'] ??
                (data['data'] is Map ? data['data']['user'] : null) ??
                (data['data'] is Map ? data['data']['User'] : null))
          : null;

      final dynamic roleRaw =
          data['role'] ??
          data['Role'] ??
          (userMap is Map ? (userMap['role'] ?? userMap['Role']) : null) ??
          (data is Map && data['data'] is Map ? data['data']['role'] : null) ??
          'tenant';

      final String? token = tokenRaw is String
          ? tokenRaw
          : (tokenRaw?.toString());
      final String role = roleRaw is String
          ? roleRaw.toString().toLowerCase()
          : 'tenant';

      if (token == null || token.isEmpty) {
        throw Exception('Login response missing token');
      }
      return {'token': token, 'role': role};
    } else {
      throw Exception('Login failed');
    }
  }
}
