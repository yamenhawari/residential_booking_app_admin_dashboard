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

  @override
  Future<AdminStatModel> getStats() async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/stats'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return AdminStatModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load stats');
    }
  }

  @override
  Future<List<AdminUserModel>> getUsers() async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/users'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List).map((e) => AdminUserModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  @override
  Future<Unit> approveUser(int id) async {
    final response = await client.put(
      Uri.parse('${ApiConstants.baseUrl}/admin/users/$id/approve'),
      headers: await _getHeaders(),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) return unit;
    throw Exception('Failed to approve');
  }

  @override
  Future<Unit> deleteUser(int id) async {
    final response = await client.delete(
      Uri.parse('${ApiConstants.baseUrl}/admin/users/$id'),
      headers: await _getHeaders(),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) return unit;
    throw Exception('Failed to delete');
  }
}

