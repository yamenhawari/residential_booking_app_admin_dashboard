import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_stat.dart';
import '../../domain/entities/admin_user.dart';

abstract class AdminState extends Equatable {
  @override
  List<Object> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class DashboardLoaded extends AdminState {
  final AdminStat stats;
  final List<AdminUser> users;
  DashboardLoaded(this.stats, this.users);
  @override
  List<Object> get props => [stats, users];
}

class AdminError extends AdminState {
  final String message;
  AdminError(this.message);
  @override
  List<Object> get props => [message];
}

