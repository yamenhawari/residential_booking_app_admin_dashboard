import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage storage;
  static const String _kTokenKey = 'admin_jwt_token';

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
  Future<void> clearToken() async {
    await storage.delete(key: _kTokenKey);
  }
}

