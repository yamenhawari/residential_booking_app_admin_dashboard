import 'package:equatable/equatable.dart';

class AdminStat extends Equatable {
  final int totalUsers;
  final int pendingUsers;
  final int activeUsers;
  final int totalBookings;

  const AdminStat({
    required this.totalUsers,
    required this.pendingUsers,
    required this.activeUsers,
    required this.totalBookings,
  });

  @override
  List<Object> get props => [totalUsers, pendingUsers, activeUsers, totalBookings];
}

