import '../../domain/entities/admin_user.dart';

class AdminUserModel extends AdminUser {
  const AdminUserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    required super.role,
    required super.status,
    super.imageUrl,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    final email = json['email'];
    final phone = json['phone'];
    
    return AdminUserModel(
      id: json['id'],
      name: "${json['first_name']} ${json['last_name']}",
      email: email ?? '',
      phone: phone,
      role: json['role'] ?? 'tenant',
      status: json['status'] ?? 'pending',
      imageUrl: json['profile_image'],
    );
  }
}

