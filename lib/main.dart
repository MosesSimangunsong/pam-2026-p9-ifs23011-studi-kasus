import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'providers/auth_provider.dart';
import 'providers/motivation_provider.dart';
import 'providers/recommendation_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';

// FIX 1: tambah WidgetsFlutterBinding.ensureInitialized() karena main() async.
// Tanpa ini, SharedPreferences (dan plugin lain) bisa crash di beberapa device.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// FIX 2: tambah {super.key} agar tidak ada lint warning "prefer_const_constructors"
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RecommendationProvider()),
        ChangeNotifierProvider(create: (_) => MotivationProvider()),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'Mood AI',
            debugShowCheckedModeBanner: false,
            theme:     AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: theme.themeMode,
            home: const _AppRouter(),
          );
        },
      ),
    );
  }
}

/// Auth guard: cek token saat app start, arahkan ke Login atau Home.
class _AppRouter extends StatefulWidget {
  const _AppRouter();

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  @override
  void initState() {
    super.initState();
    // Jalankan setelah frame pertama selesai render.
    // Ini penting agar context.read tersedia.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return switch (auth.status) {
      // Splash / loading saat cek token
      AuthStatus.unknown => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF6366F1)),
          ),
        ),
      // Token valid → langsung ke HomeScreen
      AuthStatus.authenticated => const HomeScreen(),
      // Belum login atau token expired → LoginScreen
      AuthStatus.unauthenticated => const LoginScreen(),
    };
  }
}
