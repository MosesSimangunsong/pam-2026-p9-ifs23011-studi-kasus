import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 1. TAMBAHKAN IMPORT INI
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'providers/auth_provider.dart';
import 'providers/motivation_provider.dart';
import 'providers/recommendation_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. TAMBAHKAN BARIS INI UNTUK MENCEGAH ERROR LOCALE DATE
  await initializeDateFormatting('id_ID', null);

  runApp(const MoodApp());
}

class MoodApp extends StatelessWidget {
  const MoodApp({super.key});

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
        builder: (_, theme, __) => MaterialApp(
          title:                      'Mood & Wellness AI',
          debugShowCheckedModeBanner: false,
          theme:     AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: theme.themeMode,
          home:      const _AppRouter(),
        ),
      ),
    );
  }
}

class _AppRouter extends StatefulWidget {
  const _AppRouter();
  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return switch (auth.status) {
      AuthStatus.unknown => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      AuthStatus.authenticated   => const HomeScreen(),
      AuthStatus.unauthenticated => const LoginScreen(),
    };
  }
}