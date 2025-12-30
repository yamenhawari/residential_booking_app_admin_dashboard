import 'package:equatable/equatable.dart';

class AdminUser extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String status;
  final String? imageUrl;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.status,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, email, phone, role, status, imageUrl];
}

