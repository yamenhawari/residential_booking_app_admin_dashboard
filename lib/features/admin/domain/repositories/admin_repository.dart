import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_stat.dart';
import '../entities/admin_user.dart';

abstract class AdminRepository {
  Future<Either<Failure, AdminStat>> getStats();
  Future<Either<Failure, List<AdminUser>>> getUsers();
  Future<Either<Failure, Unit>> approveUser(int id);
  Future<Either<Failure, Unit>> deleteUser(int id);
}

