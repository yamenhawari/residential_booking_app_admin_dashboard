import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../domain/usecases/get_dashboard_data_usecase.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository repository;
  late final GetDashboardDataUseCase getDashboardDataUseCase;

  AdminCubit({required this.repository, required this.getDashboardDataUseCase})
    : super(AdminInitial());

  void loadDashboard() async {
    emit(AdminLoading());
    final result = await getDashboardDataUseCase();
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (data) => emit(DashboardLoaded(data.stats, data.users)),
    );
  }

  Future<bool> approveUser(int id) async {
    final result = await repository.approveUser(id);
    bool success = false;
    result.fold(
      (failure) {
        emit(AdminError(failure.message));
        success = false;
      },
      (_) {
        success = true;
        loadDashboard();
      },
    );
    return success;
  }

  Future<bool> deleteUser(int id) async {
    final result = await repository.deleteUser(id);
    bool success = false;
    result.fold(
      (failure) {
        emit(AdminError(failure.message));
        success = false;
      },
      (_) {
        success = true;
        loadDashboard();
      },
    );
    return success;
  }

  Future<bool> sendBroadcast(String title, String body) async {
    final result = await repository.sendBroadcast(title, body);
    bool success = false;
    result.fold(
      (failure) {
        emit(AdminError(failure.message));
        success = false;
      },
      (_) {
        success = true;
      },
    );
    return success;
  }
}
