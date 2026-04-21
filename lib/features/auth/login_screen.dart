import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../widgets/shared_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey            = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool  _obscurePassword    = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth    = context.read<AuthProvider>();
    final success = await auth.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    // Navigation is handled by AuthWrapper — no need to push here.
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Login failed'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth      = context.watch<AuthProvider>();
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Logo / Header ──────────────────────────────────────────
                Center(
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.psychology_rounded,
                        color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  'Selamat Datang 👋',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Masuk untuk mendapatkan rekomendasi\nberdasarkan suasana hatimu.',
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withValues(alpha: 0.6),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // ── Username ───────────────────────────────────────────────
                AppTextField(
                  controller: _usernameController,
                  label:      'Username',
                  hint:       'Masukkan username kamu',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Username wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // ── Password ───────────────────────────────────────────────
                AppTextField(
                  controller: _passwordController,
                  label:      'Password',
                  hint:       'Masukkan password kamu',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscure:    _obscurePassword,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Password wajib diisi' : null,
                ),
                const SizedBox(height: 32),

                // ── Login button ───────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label:     'Masuk',
                    isLoading: auth.isLoading,
                    icon:      Icons.login_rounded,
                    onPressed: _submit,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Hint ───────────────────────────────────────────────────
                Center(
                  child: Text(
                    'Demo: username admin / password admin123',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
