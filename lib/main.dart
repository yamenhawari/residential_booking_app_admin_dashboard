import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/di/injection_container.dart' as di;
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/admin/presentation/cubit/admin_cubit.dart';
import 'features/admin/presentation/pages/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1440, 900),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => di.sl<AuthCubit>()),
            BlocProvider(create: (_) => di.sl<AdminCubit>()),
          ],
          child: MaterialApp(
            title: 'DreamStay Admin',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4F46E5),
                surface: const Color(0xFFF3F4F6),
              ),
              textTheme: GoogleFonts.interTextTheme(),
            ),
            home: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthAuthenticated) {
                  context.read<AdminCubit>().loadDashboard();
                }
              },
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  // Only allow access to the dashboard for admin users
                  if (state.role == 'admin') {
                    return const DashboardScreen();
                  }
                  // Authenticated but not admin - show a minimal access denied screen
                  return Scaffold(
                    body: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.lock_outline,
                              size: 56,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Access denied',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Your account does not have admin permissions.',
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () =>
                                  context.read<AuthCubit>().logout(),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return const LoginScreen();
              },
            ),
          ),
        );
      },
    );
  }
}
