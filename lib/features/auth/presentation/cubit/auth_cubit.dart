import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;

  AuthCubit({required this.repository}) : super(AuthInitial());

  void checkAuth() async {
    emit(AuthLoading());
    final result = await repository.checkAuthStatus();
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (isAuthenticated) => isAuthenticated
          ? emit(AuthAuthenticated())
          : emit(AuthUnauthenticated()),
    );
  }

  void login(String phone, String password) async {
    emit(AuthLoading());
    final result = await repository.login(phone, password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (token) => emit(AuthAuthenticated()),
    );
  }

  void logout() async {
    final result = await repository.logout();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }
}

