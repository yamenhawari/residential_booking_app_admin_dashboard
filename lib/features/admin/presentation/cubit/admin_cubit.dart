import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../domain/usecases/get_dashboard_data_usecase.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository repository;
  late final GetDashboardDataUseCase getDashboardDataUseCase;

  AdminCubit({required this.repository})
    : getDashboardDataUseCase = GetDashboardDataUseCase(repository),
      super(AdminInitial());

  void loadDashboard() async {
    emit(AdminLoading());
    final result = await getDashboardDataUseCase();
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (data) => emit(DashboardLoaded(data.stats, data.users)),
    );
  }

  void approveUser(int id) async {
    final result = await repository.approveUser(id);
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (_) => loadDashboard(),
    );
  }

  void deleteUser(int id) async {
    final result = await repository.deleteUser(id);
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (_) => loadDashboard(),
    );
  }
}
