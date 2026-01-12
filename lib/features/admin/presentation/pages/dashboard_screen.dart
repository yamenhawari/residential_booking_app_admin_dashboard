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
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.campaign_rounded,
                      color: Color(0xFF4F46E5),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Broadcast Message",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: SizedBox(
                width: 500,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Send a push notification to all users. This action cannot be undone.",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: titleCtrl,
                        validator: (v) =>
                            v!.isEmpty ? 'Title is required' : null,
                        decoration: InputDecoration(
                          labelText: "Notification Title",
                          alignLabelWithHint: true,
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
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
                          labelText: "Message Content",
                          alignLabelWithHint: true,
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.all(24),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
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
                  label: const Text("Send Now"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: const EdgeInsets.all(20),
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
          backgroundColor: const Color(0xFFF8FAFC),
          drawer: !isDesktop ? const DashboardSidebar() : null,
          appBar: !isDesktop
              ? AppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 0,
                  centerTitle: true,
                  leading: IconButton(
                    icon: const Icon(Icons.menu_rounded, color: Colors.black),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  title: const Text(
                    "Overview",
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.campaign_outlined,
                        color: Color(0xFF4F46E5),
                      ),
                      onPressed: () => _showBroadcastDialog(context),
                    ),
                    const SizedBox(width: 8),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(1),
                    child: Container(color: Colors.grey.shade200, height: 1),
                  ),
                )
              : null,
          floatingActionButton: isDesktop
              ? FloatingActionButton.extended(
                  onPressed: () => _showBroadcastDialog(context),
                  backgroundColor: const Color(0xFF4F46E5),
                  elevation: 2,
                  icon: const Icon(Icons.campaign_rounded, color: Colors.white),
                  label: const Text(
                    "New Broadcast",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
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
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF4F46E5),
                        ),
                      );
                    }

                    if (state is AdminError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.cloud_off_rounded,
                                size: 48,
                                color: Colors.red.shade400,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  context.read<AdminCubit>().loadDashboard(),
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text("Try Again"),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is DashboardLoaded) {
                      return RefreshIndicator(
                        onRefresh: () async =>
                            context.read<AdminCubit>().loadDashboard(),
                        color: const Color(0xFF4F46E5),
                        child: ListView(
                          padding: EdgeInsets.all(isDesktop ? 40 : 20),
                          children: [
                            if (isDesktop) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Dashboard Overview",
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF1E293B),
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Welcome back, here's what's happening today.",
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    onPressed: () => context
                                        .read<AdminCubit>()
                                        .loadDashboard(),
                                    icon: const Icon(Icons.refresh_rounded),
                                    tooltip: "Refresh Data",
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      padding: const EdgeInsets.all(12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                            ],

                            // Stats Grid
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final width = constraints.maxWidth;
                                // Calculate ideal item width (min 240)
                                int crossAxisCount = (width / 240).floor();
                                if (crossAxisCount < 1) crossAxisCount = 1;
                                if (crossAxisCount > 4) crossAxisCount = 4;

                                return Wrap(
                                  spacing: 20,
                                  runSpacing: 20,
                                  children: [
                                    _buildStatWrapper(
                                      StatCard(
                                        title: "Total Users",
                                        value: "${state.stats.totalUsers}",
                                        icon: Icons.group_outlined,
                                        color: const Color(0xFF3B82F6),
                                      ),
                                      width,
                                      crossAxisCount,
                                    ),
                                    _buildStatWrapper(
                                      StatCard(
                                        title: "Pending Approval",
                                        value: "${state.stats.pendingUsers}",
                                        icon: Icons.hourglass_top_rounded,
                                        color: const Color(0xFFF59E0B),
                                      ),
                                      width,
                                      crossAxisCount,
                                    ),
                                    _buildStatWrapper(
                                      StatCard(
                                        title: "Active Users",
                                        value: "${state.stats.activeUsers}",
                                        icon:
                                            Icons.check_circle_outline_rounded,
                                        color: const Color(0xFF10B981),
                                      ),
                                      width,
                                      crossAxisCount,
                                    ),
                                    _buildStatWrapper(
                                      StatCard(
                                        title: "Total Bookings",
                                        value: "${state.stats.totalBookings}",
                                        icon: Icons.bookmark_border_rounded,
                                        color: const Color(0xFF8B5CF6),
                                      ),
                                      width,
                                      crossAxisCount,
                                    ),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: 40),

                            // Table Section
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4F46E5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "User Management",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
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

  Widget _buildStatWrapper(Widget child, double parentWidth, int count) {
    final gapTotal = (count - 1) * 20.0;
    final itemWidth = (parentWidth - gapTotal) / count;
    return SizedBox(width: itemWidth, child: child);
  }
}
