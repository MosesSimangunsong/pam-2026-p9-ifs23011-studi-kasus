import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../data/models/recommendation_model.dart';
import '../../providers/recommendation_provider.dart';
import '../result/result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendationProvider>().fetchHistory(reset: true);
    });
    _scroll.addListener(() {
      if (_scroll.position.pixels >=
          _scroll.position.maxScrollExtent - 200) {
        context.read<RecommendationProvider>().fetchHistory();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov   = context.watch<RecommendationProvider>();
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: () =>
                context.read<RecommendationProvider>().fetchHistory(reset: true),
          ),
        ],
      ),
      body: prov.isLoading && prov.history.isEmpty
          ? _buildShimmer(isDark)
          : prov.history.isEmpty
          ? _buildEmpty(context, colors)
          : RefreshIndicator(
        onRefresh: () =>
            context.read<RecommendationProvider>().fetchHistory(reset: true),
        child: ListView.separated(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          itemCount: prov.history.length + (prov.hasMore ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (ctx, i) {
            if (i == prov.history.length) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final rec = prov.history[i];
            return _HistoryCard(
              rec: rec,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ResultScreen(recommendation: rec),
                ),
              ),
              onDelete: () => _confirmDelete(ctx, prov, rec.id),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      itemCount: 8,
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
    );
  }

  Widget _buildEmpty(BuildContext ctx, ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.history_rounded,
                  size: 36, color: colors.primary),
            ),
            const SizedBox(height: 20),
            Text('Belum ada riwayat',
                style: GoogleFonts.poppins(
                    fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Riwayat rekomendasimu akan muncul di sini.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: colors.onSurface.withValues(alpha: 0.5))),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext ctx, RecommendationProvider prov, int id) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hapus riwayat?'),
        content: const Text('Data ini akan dihapus permanen.'),
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
    if (ok == true && mounted) await prov.delete(id);
  }
}

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
    final colors  = Theme.of(context).colorScheme;
    final dateStr = rec.createdAt.length >= 10
        ? rec.createdAt.substring(0, 10)
        : rec.createdAt;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.self_improvement_rounded,
                  color: colors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _cap(rec.mood),
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
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: colors.onSurface.withValues(alpha: 0.3),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colors.onSurface.withValues(alpha: 0.3),
            ),
          ]),
        ),
      ),
    );
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}