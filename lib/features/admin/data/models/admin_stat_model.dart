import '../../domain/entities/admin_stat.dart';

class AdminStatModel extends AdminStat {
  const AdminStatModel({
    required super.totalUsers,
    required super.pendingUsers,
    required super.activeUsers,
    required super.totalBookings,
  });

  factory AdminStatModel.fromJson(Map<String, dynamic> json) {
    return AdminStatModel(
      totalUsers: json['total_users'] ?? 0,
      pendingUsers: json['pending_users'] ?? 0,
      activeUsers: json['active_users'] ?? 0,
      totalBookings: json['total_bookings'] ?? 0,
    );
  }
}

