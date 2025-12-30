import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> login(String phone, String password);
  Future<Either<Failure, bool>> checkAuthStatus();
  Future<Either<Failure, Unit>> logout();
}

