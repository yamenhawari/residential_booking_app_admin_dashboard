import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, Map<String, dynamic>>> login(
    String phone,
    String password,
  );
  Future<Either<Failure, String?>> checkAuthStatus();
  Future<Either<Failure, Unit>> logout();
}
