import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveRole(String role);
  Future<String?> getRole();
  Future<void> clearToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage storage;
  static const String _kTokenKey = 'admin_jwt_token';
  static const String _kRoleKey = 'admin_role';

  AuthLocalDataSourceImpl(this.storage);

  @override
  Future<void> saveToken(String token) async {
    await storage.write(key: _kTokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await storage.read(key: _kTokenKey);
  }

  @override
  Future<void> saveRole(String role) async {
    await storage.write(key: _kRoleKey, value: role);
  }

  @override
  Future<String?> getRole() async {
    return await storage.read(key: _kRoleKey);
  }

  @override
  Future<void> clearToken() async {
    await storage.delete(key: _kTokenKey);
    await storage.delete(key: _kRoleKey);
  }
}
