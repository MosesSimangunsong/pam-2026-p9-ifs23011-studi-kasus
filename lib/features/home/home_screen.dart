import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/recommendation_provider.dart';
import '../../core/theme/theme_notifier.dart';
import '../result/result_screen.dart';
import '../history/history_screen.dart';
import '../widgets/shared_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _moodController = TextEditingController();
  final _formKey        = GlobalKey<FormState>();

  static const _quickMoods = [
    (label: 'Sedih',        icon: Icons.sentiment_dissatisfied_rounded),
    (label: 'Stres',        icon: Icons.mood_rounded),
    (label: 'Lelah',        icon: Icons.bedtime_outlined),
    (label: 'Tidak Semangat', icon: Icons.sentiment_neutral_rounded),
    (label: 'Cemas',        icon: Icons.psychology_rounded),
    (label: 'Marah',        icon: Icons.sentiment_very_dissatisfied_rounded),
    (label: 'Bosan',        icon: Icons.hourglass_empty_rounded),
    (label: 'Bahagia',      icon: Icons.sentiment_very_satisfied_rounded),
  ];

  @override
  void dispose() {
    _moodController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final mood   = _moodController.text.trim();
    final prov   = context.read<RecommendationProvider>();
    final result = await prov.generate(mood);

    if (!mounted) return;

    if (result != null) {
      _moodController.clear();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(recommendation: result)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(prov.error ?? 'Gagal generate rekomendasi.'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final prov   = context.watch<RecommendationProvider>();
    final theme  = context.watch<ThemeNotifier>();
    final isDark = theme.isDark;

    return LoadingOverlay(
      isLoading: prov.isGenerating,
      message:   '✨ AI sedang menganalisis\nsuasana hatimu...',
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Mood AI',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              tooltip: 'Riwayat',
              icon: const Icon(Icons.history_rounded),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              ),
            ),
            IconButton(
              tooltip: isDark ? 'Mode Terang' : 'Mode Gelap',
              icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
              onPressed: theme.toggleTheme,
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (v) {
                if (v == 'logout') {
                  _confirmLogout(context, auth);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.red.shade400, size: 20),
                      const SizedBox(width: 10),
                      const Text('Keluar'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Greeting ───────────────────────────────────────────────
                _Greeting(username: auth.user?.username ?? ''),
                const SizedBox(height: 28),

                // ── Input ──────────────────────────────────────────────────
                const Text(
                  'Bagaimana perasaanmu sekarang?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),

                AppTextField(
                  controller: _moodController,
                  label:      'Suasana Hati',
                  hint:       'Contoh: merasa sedih dan tidak bersemangat...',
                  prefixIcon: Icons.mood_rounded,
                  maxLines:   3,
                  maxLength:  100,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Ceritakan suasana hatimu dulu ya 😊'
                          : null,
                ),
                const SizedBox(height: 16),

                // ── Quick mood chips ───────────────────────────────────────
                const Text(
                  'Atau pilih cepat:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _quickMoods.map((m) => MoodChip(
                    label: m.label,
                    icon:  m.icon,
                    onTap: () => _moodController.text = m.label,
                  )).toList(),
                ),
                const SizedBox(height: 28),

                // ── Generate button ────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label:     'Dapatkan Rekomendasi',
                    icon:      Icons.auto_awesome_rounded,
                    isLoading: prov.isGenerating,
                    onPressed: _generate,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Recent history preview ─────────────────────────────────
                if (prov.history.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Riwayat Terakhir',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HistoryScreen()),
                        ),
                        child: const Text('Lihat Semua'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...prov.history
                      .take(3)
                      .map((rec) => _HistoryPreviewCard(
                            mood:      rec.mood,
                            createdAt: rec.createdAt,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ResultScreen(recommendation: rec)),
                            ),
                          )),
                ],

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar?'),
        content: const Text('Kamu yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              auth.logout();
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _Greeting extends StatelessWidget {
  final String username;
  const _Greeting({required this.username});

  String _timeGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Selamat Pagi';
    if (h < 15) return 'Selamat Siang';
    if (h < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_timeGreeting()}, $username! 👋',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ceritakan perasaanmu dan\nAI akan membantu rekomendasimu.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _HistoryPreviewCard extends StatelessWidget {
  final String   mood;
  final String   createdAt;
  final VoidCallback onTap;

  const _HistoryPreviewCard({
    required this.mood,
    required this.createdAt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF6366F1).withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.mood_rounded,
                  color: Color(0xFF6366F1), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mood,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    createdAt.substring(0, 10),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
