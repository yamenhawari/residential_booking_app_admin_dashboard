import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../widgets/dashboard_stats_sidebar.dart';
import '../widgets/user_management_table.dart';

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
      builder: (ctx) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
                        validator: (v) =>
                            v!.isEmpty ? 'Title is required' : null,
                        decoration: InputDecoration(
                          labelText: "Title",
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
                        validator: (v) =>
                            v!.isEmpty ? 'Message is required' : null,
                        decoration: InputDecoration(
                          labelText: "Message Body",
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
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                  child: const Text("Cancel"),
                ),
                ElevatedButton.icon(
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                  label: const Text("Send Broadcast"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setState(() => isLoading = true);

                            final success = await context
                                .read<AdminCubit>()
                                .sendBroadcast(titleCtrl.text, bodyCtrl.text);

                            if (!context.mounted) return;
                            setState(() => isLoading = false);
                            Navigator.pop(ctx);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success ? "Broadcast Sent" : "Failed to send",
                                ),
                                backgroundColor: success
                                    ? Colors.green[700]
                                    : Colors.red[700],
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 1000;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF3F4F6),
          drawer: !isDesktop ? const DashboardSidebar() : null,
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
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
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
              if (isDesktop)
                const SizedBox(width: 280, child: DashboardSidebar()),
              Expanded(
                child: BlocBuilder<AdminCubit, AdminState>(
                  builder: (context, state) {
                    if (state is AdminLoading) {
                      return const Center(child: CircularProgressIndicator());
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

                    if (state is DashboardLoaded) {
                      return RefreshIndicator(
                        onRefresh: () async =>
                            context.read<AdminCubit>().loadDashboard(),
                        child: ListView(
                          padding: EdgeInsets.all(isDesktop ? 40 : 20),
                          children: [
                            if (isDesktop) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    onPressed: () => context
                                        .read<AdminCubit>()
                                        .loadDashboard(),
                                    icon: const Icon(Icons.refresh),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                            ],
                            Wrap(
                              spacing: 20,
                              runSpacing: 20,
                              children: [
                                StatCard(
                                  title: "Total Users",
                                  value: "${state.stats.totalUsers}",
                                  icon: Icons.group_outlined,
                                  color: Colors.blue,
                                ),
                                StatCard(
                                  title: "Pending Approval",
                                  value: "${state.stats.pendingUsers}",
                                  icon: Icons.hourglass_top,
                                  color: Colors.orange,
                                ),
                                StatCard(
                                  title: "Active Users",
                                  value: "${state.stats.activeUsers}",
                                  icon: Icons.check_circle_outline,
                                  color: Colors.green,
                                ),
                                StatCard(
                                  title: "Total Bookings",
                                  value: "${state.stats.totalBookings}",
                                  icon: Icons.bookmark_border,
                                  color: Colors.purple,
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
                            const SizedBox(height: 20),
                            UserManagementTable(
                              users: state.users,
                              isDesktop: isDesktop,
                            ),
                            const SizedBox(height: 80),
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
}
