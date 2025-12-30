// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    context.read<AdminCubit>().loadDashboard();
  }

  void _showBroadcastDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.campaign, color: Color(0xFF4F46E5)),
            ),
            const SizedBox(width: 12),
            const Text("Broadcast Notification"),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(
          width: 500,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Send a push notification to all registered users.",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: titleCtrl,
                  validator: (v) => v!.isEmpty ? 'Title is required' : null,
                  decoration: InputDecoration(
                    labelText: "Notification Title",
                    hintText: "e.g., Summer Sale!",
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: bodyCtrl,
                  maxLines: 4,
                  validator: (v) => v!.isEmpty ? 'Message is required' : null,
                  decoration: InputDecoration(
                    labelText: "Message Body",
                    hintText: "Type your message here...",
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.all(20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            child: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.send_rounded, size: 18),
            label: const Text("Send Broadcast"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                final success = await context.read<AdminCubit>().sendBroadcast(
                  titleCtrl.text,
                  bodyCtrl.text,
                );
                if (!context.mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text("Broadcast Sent Successfully"),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.white),
                          SizedBox(width: 12),
                          Text("Failed to send broadcast"),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.red[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF3F4F6),
          // Drawer for Mobile/Tablet
          drawer: !isDesktop ? const _SideBar() : null,
          appBar: !isDesktop
              ? AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  title: const Text(
                    "DreamStay Admin",
                    style: TextStyle(color: Colors.black),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.campaign,
                        color: Color(0xFF4F46E5),
                      ),
                      onPressed: () => _showBroadcastDialog(context),
                    ),
                  ],
                )
              : null,
          floatingActionButton: isDesktop
              ? FloatingActionButton.extended(
                  onPressed: () => _showBroadcastDialog(context),
                  backgroundColor: const Color(0xFF4F46E5),
                  elevation: 4,
                  icon: const Icon(Icons.campaign, color: Colors.white),
                  label: const Text(
                    "New Broadcast",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : null,
          body: Row(
            children: [
              // Sidebar for Desktop
              if (isDesktop) const SizedBox(width: 260, child: _SideBar()),

              // Main Content
              Expanded(
                child: BlocBuilder<AdminCubit, AdminState>(
                  builder: (context, state) {
                    if (state is AdminLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is DashboardLoaded) {
                      return _buildContent(context, state, isDesktop);
                    }
                    if (state is AdminError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  context.read<AdminCubit>().loadDashboard(),
                              icon: const Icon(Icons.refresh),
                              label: const Text("Retry"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    DashboardLoaded state,
    bool isDesktop,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdminCubit>().loadDashboard();
      },
      child: ListView(
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
        children: [
          if (isDesktop)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dashboard Overview",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Welcome back, Admin",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => context.read<AdminCubit>().loadDashboard(),
                  icon: const Icon(Icons.refresh),
                  tooltip: "Refresh Data",
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),

          // Responsive Grid for Stats
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.start,
            children: [
              _StatCard(
                "Total Users",
                "${state.stats.totalUsers}",
                Icons.group_outlined,
                Colors.blue,
              ),
              _StatCard(
                "Pending Approval",
                "${state.stats.pendingUsers}",
                Icons.hourglass_top,
                Colors.orange,
              ),
              _StatCard(
                "Active Users",
                "${state.stats.activeUsers}",
                Icons.check_circle_outline,
                Colors.green,
              ),
              _StatCard(
                "Total Bookings",
                "${state.stats.totalBookings}",
                Icons.bookmark_border,
                Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 40),

          const Text(
            "User Management",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),

          // Table Container
          Container(
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
                    minWidth: isDesktop
                        ? 800
                        : MediaQuery.of(context).size.width,
                  ),
                  child: DataTable(
                    // Ensure rows are tall enough to contain larger avatars without overflow.
                    dataRowHeight: isDesktop ? 96.0 : 72.0,
                    headingRowHeight: 56.0,
                    horizontalMargin: 24,
                    columnSpacing: 24,
                    headingRowColor: MaterialStateProperty.all(
                      const Color(0xFFF9FAFB),
                    ),
                    columns: const [
                      DataColumn(label: Text("User Info")),
                      DataColumn(label: Text("Role")),
                      DataColumn(label: Text("Status")),
                      DataColumn(label: Text("Actions")),
                    ],
                    rows: state.users.map((user) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: isDesktop ? 72 : 56,
                                    height: isDesktop ? 72 : 56,
                                    child: CircleAvatar(
                                      radius: isDesktop ? 36 : 28,
                                      backgroundColor: Colors.grey[200],
                                      backgroundImage: user.imageUrl != null
                                          ? NetworkImage(
                                              "${ApiConstants.imageUrl}${user.imageUrl}",
                                            )
                                          : null,
                                      child: user.imageUrl == null
                                          ? Icon(
                                              Icons.person,
                                              size: isDesktop ? 32 : 24,
                                              color: Colors.grey,
                                            )
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Allow the text column to take the remaining space and wrap if needed.
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          user.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          user.email.isEmpty
                                              ? (user.phone ?? "")
                                              : user.email,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
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
                                // Action rules:
                                // - Pending: allow Approve and Delete
                                // - Active: allow Delete only
                                // - Other: allow Delete only
                                if (user.status == 'pending') ...[
                                  IconButton(
                                    icon: const Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green,
                                    ),
                                    onPressed: () => _showConfirmDialog(
                                      context,
                                      title: "Approve User",
                                      message:
                                          "Approve access for ${user.name}?",
                                      onConfirm: () async {
                                        final success = await context
                                            .read<AdminCubit>()
                                            .approveUser(user.id);
                                        if (!context.mounted) return;
                                        if (success) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: const Row(
                                                children: [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text("User approved"),
                                                ],
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              backgroundColor:
                                                  Colors.green[700],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: const Row(
                                                children: [
                                                  Icon(
                                                    Icons.error_outline,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text(
                                                    "Failed to approve user",
                                                  ),
                                                ],
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              backgroundColor: Colors.red[700],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    tooltip: "Approve",
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _showConfirmDialog(
                                      context,
                                      title: "Delete User",
                                      message:
                                          "Permanently delete ${user.name}? This cannot be undone.",
                                      onConfirm: () async {
                                        final success = await context
                                            .read<AdminCubit>()
                                            .deleteUser(user.id);
                                        if (!context.mounted) return;
                                        if (success) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: const Row(
                                                children: [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text("User deleted"),
                                                ],
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              backgroundColor:
                                                  Colors.green[700],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: const Row(
                                                children: [
                                                  Icon(
                                                    Icons.error_outline,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text("Failed to delete user"),
                                                ],
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              backgroundColor: Colors.red[700],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      isDestructive: true,
                                    ),
                                    tooltip: "Delete",
                                  ),
                                ] else ...[
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _showConfirmDialog(
                                      context,
                                      title: "Delete User",
                                      message:
                                          "Permanently delete ${user.name}? This cannot be undone.",
                                      onConfirm: () async {
                                        final success = await context
                                            .read<AdminCubit>()
                                            .deleteUser(user.id);
                                        if (!context.mounted) return;
                                        if (success) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: const Row(
                                                children: [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text("User deleted"),
                                                ],
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              backgroundColor:
                                                  Colors.green[700],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: const Row(
                                                children: [
                                                  Icon(
                                                    Icons.error_outline,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text("Failed to delete user"),
                                                ],
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              backgroundColor: Colors.red[700],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      isDestructive: true,
                                    ),
                                    tooltip: "Delete",
                                  ),
                                ],
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
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive
                  ? Colors.red[600]
                  : const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }
}

class _SideBar extends StatelessWidget {
  const _SideBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Logo Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "DREAMSTAY",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      "ADMIN PORTAL",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Menu Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.dashboard_rounded,
                    color: Color(0xFF4F46E5),
                  ),
                  title: const Text(
                    "Overview",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  tileColor: const Color(0xFF4F46E5).withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.people_outline, color: Colors.grey),
                  title: const Text(
                    "Users",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              onTap: () => context.read<AuthCubit>().logout(),
              hoverColor: Colors.red.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    // Responsive width logic
    double width = 260;

    return Container(
      width: width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
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
    } else if (status == 'blocked') {
      backgroundColor = const Color(0xFFFEF2F2);
      borderColor = const Color(0xFFFECACA);
      textColor = const Color(0xFFB91C1C);
      icon = Icons.block_rounded;
    } else {
      backgroundColor = Colors.grey[50]!;
      borderColor = Colors.grey[300]!;
      textColor = Colors.grey[600]!;
      icon = Icons.help_outline;
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
