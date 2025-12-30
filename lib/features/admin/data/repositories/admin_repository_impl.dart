import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/admin_stat.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AdminStat>> getStats() async {
    try {
      final result = await remoteDataSource.getStats();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AdminUser>>> getUsers() async {
    try {
      final result = await remoteDataSource.getUsers();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> approveUser(int id) async {
    try {
      await remoteDataSource.approveUser(id);
      return const Right(unit);
    } catch (e) {
      return const Left(ServerFailure("Approve Failed"));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteUser(int id) async {
    try {
      await remoteDataSource.deleteUser(id);
      return const Right(unit);
    } catch (e) {
      return const Left(ServerFailure("Delete Failed"));
    }
  }
}

