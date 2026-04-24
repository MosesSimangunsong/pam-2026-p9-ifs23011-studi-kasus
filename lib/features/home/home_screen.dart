import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_notifier.dart';
import '../../data/models/recommendation_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recommendation_provider.dart';
import '../result/result_screen.dart';
import '../widgets/mood_input_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendationProvider>().fetchHistory(reset: true);
    });

    _scrollCtrl.addListener(() {
      final prov = context.read<RecommendationProvider>();
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 300) {
        prov.fetchHistory();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── FAB tap → bottom sheet → result screen ────────────────────────────────
  Future<void> _openMoodInput() async {
    final result = await showModalBottomSheet<RecommendationModel?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MoodInputBottomSheet(),
    );
    if (result != null && mounted) {
      Navigator.push(
        context,
        _fadeRoute(ResultScreen(recommendation: result)),
      );
    }
  }

  // ── Smooth fade page route ─────────────────────────────────────────────────
  Route<dynamic> _fadeRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 300),
  );

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final prov   = context.watch<RecommendationProvider>();
    final theme  = context.watch<ThemeNotifier>();
    final colors = Theme.of(context).colorScheme;
    final isDark = theme.isDark;

    return Scaffold(
      floatingActionButton: _buildFAB(colors),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: CustomScrollView(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Sliver App Bar ────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 210,
            pinned:  true,
            stretch: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            actions: [
              IconButton(
                onPressed: theme.toggleTheme,
                tooltip: 'Toggle theme',
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isDark ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                    key: ValueKey(isDark),
                    size: 22,
                  ),
                ),
              ),
              _buildMoreMenu(context, auth),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _GreetingHeader(
                username: auth.user?.username ?? 'Kamu',
              ),
              // Collapsed title
              title: Text(
                'Mood & Wellness',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              titlePadding:
              const EdgeInsetsDirectional.only(start: 20, bottom: 14),
            ),
          ),

          // ── Section header ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  Text(
                    'Riwayat Rekomendasi',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                  const Spacer(),
                  if (prov.history.isNotEmpty)
                    Text(
                      '${prov.history.length} sesi',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: colors.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ── History list ───────────────────────────────────────────────────
          if (prov.isLoading && prov.history.isEmpty)
            _ShimmerList()
          else if (prov.history.isEmpty && !prov.isLoading)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(onTap: _openMoodInput),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              sliver: SliverList.separated(
                itemCount: prov.history.length + (prov.hasMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  if (i == prov.history.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final rec = prov.history[i];
                  return _HistoryCard(
                    rec: rec,
                    onTap: () => Navigator.push(
                      context,
                      _fadeRoute(ResultScreen(recommendation: rec)),
                    ),
                    onDelete: () => _confirmDelete(context, prov, rec.id),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ── FAB ────────────────────────────────────────────────────────────────────
  Widget _buildFAB(ColorScheme colors) {
    return FloatingActionButton.extended(
      onPressed: _openMoodInput,
      elevation: 8,
      icon: const Icon(Icons.auto_awesome_rounded, size: 20),
      label: const Text('Ungkapkan Perasaanmu'),
    );
  }

  // ── More menu (logout) ─────────────────────────────────────────────────────
  Widget _buildMoreMenu(BuildContext ctx, AuthProvider auth) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, size: 22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      onSelected: (v) {
        if (v == 'logout') _showLogoutDialog(ctx, auth);
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'logout',
          child: Row(children: [
            Icon(Icons.logout_rounded, size: 18,
                color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 10),
            const Text('Keluar'),
          ]),
        ),
      ],
    );
  }

  // ── Delete confirm ─────────────────────────────────────────────────────────
  Future<void> _confirmDelete(
      BuildContext ctx, RecommendationProvider prov, int id) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hapus riwayat?'),
        content: const Text('Rekomendasi ini akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await prov.delete(id);
    }
  }

  // ── Logout dialog ──────────────────────────────────────────────────────────
  void _showLogoutDialog(BuildContext ctx, AuthProvider auth) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Keluar?'),
        content: const Text('Kamu yakin ingin keluar dari sesi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              auth.logout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Sub-widgets
// ═══════════════════════════════════════════════════════════════════════════════

/// Expanded header dalam SliverAppBar
class _GreetingHeader extends StatelessWidget {
  final String username;
  const _GreetingHeader({required this.username});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Selamat Pagi ☀️';
    if (h < 15) return 'Selamat Siang 🌤';
    if (h < 18) return 'Selamat Sore 🌅';
    return 'Selamat Malam 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final today  = DateFormat('EEEE, d MMMM', 'id').format(DateTime.now());

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + kToolbarHeight - 10, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Greeting badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              _greeting(),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Name — large display text
          Text(
            username.isNotEmpty
                ? username[0].toUpperCase() + username.substring(1)
                : 'Teman',
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),

          // Date
          Text(
            today,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu riwayat minimalis
class _HistoryCard extends StatelessWidget {
  final RecommendationModel rec;
  final VoidCallback         onTap;
  final VoidCallback         onDelete;

  const _HistoryCard({
    required this.rec,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors    = Theme.of(context).colorScheme;
    final dateStr   = rec.createdAt.length >= 10
        ? rec.createdAt.substring(0, 10)
        : rec.createdAt;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:        colors.surface,
          borderRadius: BorderRadius.circular(20),
          border:       Border.all(color: colors.outline, width: 1),
          boxShadow: [
            BoxShadow(
              color:  Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.self_improvement_rounded,
                      color: colors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _capitalize(rec.mood),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateStr,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: colors.onSurface.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Delete
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: colors.onSurface.withValues(alpha: 0.3),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32, minHeight: 32,
                    ),
                  ),

                  // Arrow
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colors.onSurface.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

/// Shimmer placeholder saat loading
class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      sliver: SliverList.separated(
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor:      isDark ? const Color(0xFF1E1D2E) : const Color(0xFFF0EFF8),
          highlightColor: isDark ? const Color(0xFF2A2838) : const Color(0xFFFFFFFF),
          child: Container(
            height: 74,
            decoration: BoxDecoration(
              color:        Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}

/// Empty state
class _EmptyState extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(
              color:        colors.primaryContainer,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              Icons.spa_outlined,
              size: 40,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Mulai Perjalananmu',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ceritakan perasaanmu dan biarkan AI\nmembantu rekomendasimu.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.6,
              color: colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: const Text('Ungkapkan Perasaanmu'),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}