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
    try {
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phone, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic tokenRaw =
            data['Token'] ??
            data['token'] ??
            (data is Map && data['data'] is Map ? data['data']['token'] : null);

        final dynamic userMap = (data is Map)
            ? (data['user'] ??
                  data['User'] ??
                  (data['data'] is Map ? data['data']['user'] : null))
            : null;

        final dynamic roleRaw =
            data['role'] ??
            (userMap is Map ? (userMap['role'] ?? userMap['Role']) : null) ??
            'tenant';

        final String? token = tokenRaw?.toString();
        final String role = roleRaw?.toString().toLowerCase() ?? 'tenant';

        if (token == null || token.isEmpty) {
          throw Exception('Server returned success but no token found.');
        }
        return {'token': token, 'role': role};
      } else {
        // Try to get proper error message from server
        final msg = data['message'] ?? data['error'] ?? 'Login failed';
        throw Exception(msg);
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      throw Exception(msg);
    }
  }
}
