import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> login(
    String phone,
    String password,
  ) async {
    try {
      final data = await remoteDataSource.login(phone, password);
      final token = data['token'] as String?;
      final role = (data['role'] is String) ? data['role'] as String : 'tenant';
      if (token == null) return Left(ServerFailure('Invalid login response'));
      await localDataSource.saveToken(token);
      await localDataSource.saveRole(role);
      return Right({'token': token, 'role': role});
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkAuthStatus() async {
    try {
      final token = await localDataSource.getToken();
      return Right(token != null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await localDataSource.clearToken();
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
