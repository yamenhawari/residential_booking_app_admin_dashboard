import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/admin_stat_model.dart';
import '../models/admin_user_model.dart';

abstract class AdminRemoteDataSource {
  Future<AdminStatModel> getStats();
  Future<List<AdminUserModel>> getUsers();
  Future<Unit> approveUser(int id);
  Future<Unit> deleteUser(int id);
  Future<Unit> rejectUser(int id);
  Future<Unit> sendBroadcast(String title, String body);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;

  AdminRemoteDataSourceImpl({
    required this.client,
    required this.authLocalDataSource,
  });

  Future<Map<String, String>> _getHeaders() async {
    final token = await authLocalDataSource.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<T> _handleRequest<T>(
    Future<http.Response> Function() request,
    T Function(dynamic data) onSuccess,
  ) async {
    try {
      final response = await request();
      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return onSuccess(body);
      } else {
        throw Exception(body['message'] ?? 'Request failed');
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      throw Exception(msg);
    }
  }

  @override
  Future<AdminStatModel> getStats() async {
    return _handleRequest(
      () async => client.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/stats'),
        headers: await _getHeaders(),
      ),
      (data) => AdminStatModel.fromJson(data),
    );
  }

  @override
  Future<List<AdminUserModel>> getUsers() async {
    return _handleRequest(
      () async => client.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/users'),
        headers: await _getHeaders(),
      ),
      (data) => (data['data'] as List)
          .map((e) => AdminUserModel.fromJson(e))
          .toList(),
    );
  }

  @override
  Future<Unit> approveUser(int id) async {
    return _handleRequest(
      () async => client.put(
        Uri.parse('${ApiConstants.baseUrl}/admin/users/$id/approve'),
        headers: await _getHeaders(),
      ),
      (_) => unit,
    );
  }

  @override
  Future<Unit> rejectUser(int id) async {
    return _handleRequest(
      () async => client.put(
        Uri.parse('${ApiConstants.baseUrl}/admin/users/$id/reject'),
        headers: await _getHeaders(),
      ),
      (_) => unit,
    );
  }

  @override
  Future<Unit> deleteUser(int id) async {
    return _handleRequest(
      () async => client.delete(
        Uri.parse('${ApiConstants.baseUrl}/admin/users/$id'),
        headers: await _getHeaders(),
      ),
      (_) => unit,
    );
  }

  @override
  Future<Unit> sendBroadcast(String title, String body) async {
    return _handleRequest(
      () async => client.post(
        Uri.parse('${ApiConstants.baseUrl}/admin/notifications/broadcast'),
        headers: await _getHeaders(),
        body: jsonEncode({'title': title, 'body': body}),
      ),
      (_) => unit,
    );
  }
}
