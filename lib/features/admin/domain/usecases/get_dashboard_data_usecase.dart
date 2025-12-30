import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_stat.dart';
import '../entities/admin_user.dart';
import '../repositories/admin_repository.dart';

class GetDashboardDataUseCase {
  final AdminRepository repository;
  GetDashboardDataUseCase(this.repository);

  Future<Either<Failure, ({AdminStat stats, List<AdminUser> users})>> call() async {
    final statsResult = await repository.getStats();
    final usersResult = await repository.getUsers();

    return statsResult.fold(
      (failure) => Left(failure),
      (stats) => usersResult.fold(
        (failure) => Left(failure),
        (users) => Right((stats: stats, users: users)),
      ),
    );
  }
}

