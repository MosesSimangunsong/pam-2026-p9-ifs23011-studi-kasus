import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/recommendation_model.dart';
import '../../providers/recommendation_provider.dart';
import '../result/result_screen.dart';
import '../widgets/shared_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final prov = context.read<RecommendationProvider>();

    // Fetch fresh history when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      prov.fetchHistory(reset: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        prov.fetchHistory();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(
      BuildContext context, RecommendationProvider prov, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Riwayat?'),
        content: const Text(
            'Data rekomendasi ini akan dihapus secara permanen. Yakin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade500,
              foregroundColor: Colors.white,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final ok = await prov.delete(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Riwayat dihapus.' : (prov.error ?? 'Gagal menghapus.')),
          backgroundColor: ok ? Colors.green.shade600 : Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<RecommendationProvider>();

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Riwayat', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => prov.fetchHistory(reset: true),
          ),
        ],
      ),
      body: prov.history.isEmpty && prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : prov.history.isEmpty
              ? _EmptyState(onGenerate: () => Navigator.pop(context))
              : RefreshIndicator(
                  onRefresh: () => prov.fetchHistory(reset: true),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: prov.history.length + 1,
                    itemBuilder: (context, index) {
                      if (index == prov.history.length) {
                        return prov.isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                    child: CircularProgressIndicator()),
                              )
                            : const SizedBox.shrink();
                      }

                      final rec = prov.history[index];
                      return _HistoryCard(
                        rec:      rec,
                        number:   index + 1,
                        onTap:    () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ResultScreen(recommendation: rec)),
                        ),
                        onDelete: () => _confirmDelete(context, prov, rec.id),
                      );
                    },
                  ),
                ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final RecommendationModel rec;
  final int                 number;
  final VoidCallback        onTap;
  final VoidCallback        onDelete;

  const _HistoryCard({
    required this.rec,
    required this.number,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#$number',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    rec.createdAt.length >= 10
                        ? rec.createdAt.substring(0, 10)
                        : rec.createdAt,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 11),
                  ),
                  const SizedBox(width: 10),

                  // Delete button
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Mood
              Row(
                children: [
                  const Icon(Icons.mood_rounded,
                      color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rec.mood,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Exercise preview
              _PreviewRow(
                icon:  Icons.fitness_center_rounded,
                label: rec.exercise.isNotEmpty ? rec.exercise.first : '—',
              ),
              const SizedBox(height: 6),

              // Activity preview
              _PreviewRow(
                icon:  Icons.star_outline_rounded,
                label: rec.activities.isNotEmpty ? rec.activities.first : '—',
              ),

              if (rec.notes != null && rec.notes!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sticky_note_2_outlined,
                          color: Colors.white70, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          rec.notes!,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Lihat detail',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 12)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white70, size: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _PreviewRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white54, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onGenerate;
  const _EmptyState({required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 60,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Riwayat',
              style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Mulai ceritakan suasana hatimu\ndan dapatkan rekomendasi AI pertamamu!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 28),
            AppButton(
              label:     'Generate Sekarang',
              icon:      Icons.auto_awesome_rounded,
              onPressed: onGenerate,
            ),
          ],
        ),
      ),
    );
  }
}
