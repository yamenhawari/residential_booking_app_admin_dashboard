import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/admin_user.dart';
import '../cubit/admin_cubit.dart';

class UserManagementTable extends StatelessWidget {
  final List<AdminUser> users;
  final bool isDesktop;

  const UserManagementTable({
    super.key,
    required this.users,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: isDesktop ? 800 : MediaQuery.of(context).size.width,
            ),
            child: DataTable(
              // ignore: deprecated_member_use
              dataRowHeight: 80.0,
              headingRowHeight: 56.0,
              horizontalMargin: 24,
              columnSpacing: 24,
              // ignore: deprecated_member_use
              headingRowColor: MaterialStateProperty.all(
                const Color(0xFFF9FAFB),
              ),
              columns: const [
                DataColumn(label: Text("User Info")),
                DataColumn(label: Text("Role")),
                DataColumn(label: Text("Status")),
                DataColumn(label: Text("Actions")),
              ],
              rows: users.map((user) {
                return DataRow(
                  cells: [
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: user.imageUrl != null
                                  ? NetworkImage(
                                      "${ApiConstants.imageUrl}${user.imageUrl}",
                                    )
                                  : null,
                              child: user.imageUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 24,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.email.isEmpty
                                      ? (user.phone ?? 'N/A')
                                      : user.email,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(_RoleBadge(role: user.role)),
                    DataCell(_StatusBadge(status: user.status)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (user.status != 'active')
                            IconButton(
                              icon: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                              ),
                              tooltip: "Approve User",
                              onPressed: () => _showActionDialog(
                                context,
                                title: "Approve User",
                                message:
                                    "Are you sure you want to approve ${user.name}?",
                                onConfirm: () => context
                                    .read<AdminCubit>()
                                    .approveUser(user.id),
                              ),
                            ),

                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            tooltip: "Delete User",
                            onPressed: () => _showActionDialog(
                              context,
                              title: "Delete User",
                              message:
                                  "Permanently delete ${user.name}? This cannot be undone.",
                              onConfirm: () => context
                                  .read<AdminCubit>()
                                  .deleteUser(user.id),
                              isDestructive: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _showActionDialog(
    BuildContext context, {
    required String title,
    required String message,
    required Future<bool> Function() onConfirm,
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive
                  ? Colors.red
                  : const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);

              final success = await onConfirm();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success ? "Action Successful" : "Action Failed",
                  ),
                  backgroundColor: success
                      ? Colors.green[700]
                      : Colors.red[700],
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        border: Border.all(color: const Color(0xFFBFDBFE)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF1E40AF),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData icon;

    if (status == 'active') {
      backgroundColor = const Color(0xFFECFDF5);
      borderColor = const Color(0xFFA7F3D0);
      textColor = const Color(0xFF047857);
      icon = Icons.check_circle_rounded;
    } else if (status == 'inactive' || status == 'pending') {
      backgroundColor = const Color(0xFFFFFBEB);
      borderColor = const Color(0xFFFDE68A);
      textColor = const Color(0xFFB45309);
      icon = Icons.access_time_filled_rounded;
    } else {
      backgroundColor = const Color(0xFFFEF2F2);
      borderColor = const Color(0xFFFECACA);
      textColor = const Color(0xFFB91C1C);
      icon = Icons.block_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
