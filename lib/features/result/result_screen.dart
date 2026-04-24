import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/recommendation_model.dart';
import '../../providers/recommendation_provider.dart';

class ResultScreen extends StatefulWidget {
  final RecommendationModel recommendation;
  const ResultScreen({super.key, required this.recommendation});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {

  late RecommendationModel _rec;
  late AnimationController _animCtrl;
  late Animation<double>    _fadeAnim;

  final _notesCtrl    = TextEditingController();
  bool  _editingNotes = false;

  @override
  void initState() {
    super.initState();
    _rec = widget.recommendation;
    _notesCtrl.text = _rec.notes ?? '';

    // Fade-in the whole body
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveNotes() async {
    final prov = context.read<RecommendationProvider>();
    final ok   = await prov.updateNotes(_rec.id, _notesCtrl.text.trim());
    if (!mounted) return;
    if (ok) {
      setState(() {
        _rec          = _rec.copyWith(notes: _notesCtrl.text.trim());
        _editingNotes = false;
      });
      _showSnack('Catatan tersimpan ✓', isError: false);
    } else {
      _showSnack(prov.error ?? 'Gagal menyimpan.', isError: true);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins()),
      backgroundColor: isError
          ? Theme.of(context).colorScheme.error
          : const Color(0xFF3E9E78),
      behavior:       SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final prov   = context.watch<RecommendationProvider>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rekomendasimu',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Mood Header ───────────────────────────────────────────────
              _MoodHeader(rec: _rec),
              const SizedBox(height: 28),

              // ── Exercise section ──────────────────────────────────────────
              _SectionLabel(
                icon:  Icons.directions_run_rounded,
                label: 'Olahraga Ringan',
                color: colors.brightness == Brightness.light
                    ? AppColors.lGreen
                    : AppColors.dGreen,
              ),
              const SizedBox(height: 12),
              ..._rec.exercise.asMap().entries.map((e) => _RecommendationItem(
                index:  e.key,
                text:   e.value,
                color:  colors.brightness == Brightness.light
                    ? AppColors.lGreen
                    : AppColors.dGreen,
              )),

              const SizedBox(height: 24),

              // ── Activities section ────────────────────────────────────────
              _SectionLabel(
                icon:  Icons.star_outline_rounded,
                label: 'Aktivitas Positif',
                color: colors.primary,
              ),
              const SizedBox(height: 12),
              ..._rec.activities.asMap().entries.map((e) => _RecommendationItem(
                index: e.key,
                text:  e.value,
                color: colors.primary,
              )),

              const SizedBox(height: 28),

              // ── Notes section ─────────────────────────────────────────────
              _NotesSection(
                notes:        _rec.notes,
                controller:   _notesCtrl,
                isEditing:    _editingNotes,
                isSaving:     prov.isSavingNotes,
                onEditToggle: () => setState(() {
                  _editingNotes = !_editingNotes;
                  if (!_editingNotes) _notesCtrl.text = _rec.notes ?? '';
                }),
                onSave: _saveNotes,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Sub-widgets
// ═══════════════════════════════════════════════════════════════════════════════

/// Header besar menampilkan mood secara elegan — tanpa gradien kasar.
class _MoodHeader extends StatelessWidget {
  final RecommendationModel rec;
  const _MoodHeader({required this.rec});

  @override
  Widget build(BuildContext context) {
    final colors  = Theme.of(context).colorScheme;
    final dateStr = rec.createdAt.length >= 10
        ? rec.createdAt.substring(0, 10)
        : rec.createdAt;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:        colors.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Row(children: [
            Icon(Icons.self_improvement_rounded,
                size: 16, color: colors.primary),
            const SizedBox(width: 6),
            Text(
              'Mood kamu',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colors.primary,
              ),
            ),
          ]),
          const SizedBox(height: 10),

          // Mood text — large, bold, calm
          Text(
            _capitalize(rec.mood),
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),

          // Date chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              dateStr,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: colors.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

/// Label section header
class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;

  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color:        color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
      const SizedBox(width: 10),
      Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    ]);
  }
}

/// Item rekomendasi dengan numbered circle
class _RecommendationItem extends StatelessWidget {
  final int    index;
  final String text;
  final Color  color;

  const _RecommendationItem({
    required this.index,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Split nama & deskripsi jika ada " — "
    final parts = text.split(' — ');
    final name  = parts.isNotEmpty ? parts[0] : text;
    final desc  = parts.length > 1 ? parts.sublist(1).join(' — ') : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Numbered circle
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color:  color.withValues(alpha: 0.12),
              shape:  BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                if (desc != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: colors.onSurface.withValues(alpha: 0.55),
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Section catatan dengan edit toggle
class _NotesSection extends StatelessWidget {
  final String?               notes;
  final TextEditingController controller;
  final bool                  isEditing;
  final bool                  isSaving;
  final VoidCallback          onEditToggle;
  final VoidCallback          onSave;

  const _NotesSection({
    required this.notes,
    required this.controller,
    required this.isEditing,
    required this.isSaving,
    required this.onEditToggle,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        colors.surface,
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: colors.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                size: 20,
                color: colors.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Text(
                'Catatan Pribadi',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onEditToggle,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  isEditing ? 'Batal' : 'Edit',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isEditing
                        ? colors.error
                        : colors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: isEditing
                ? Column(
              key: const ValueKey('editing'),
              children: [
                TextField(
                  controller: controller,
                  maxLines:   4,
                  maxLength:  500,
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: colors.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Tulis refleksimu di sini...',
                    counterStyle: GoogleFonts.poppins(
                      fontSize: 11,
                      color: colors.onSurface.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton.icon(
                    onPressed: isSaving ? null : onSave,
                    icon: isSaving
                        ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: Text(
                      isSaving ? 'Menyimpan...' : 'Simpan Catatan',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            )
                : SizedBox(
              key: const ValueKey('viewing'),
              width: double.infinity,
              child: notes != null && notes!.isNotEmpty
                  ? Text(
                notes!,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: colors.onSurface,
                  height: 1.6,
                ),
              )
                  : Text(
                'Belum ada catatan.\nTekan "Edit" untuk menambahkan refleksimu.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: colors.onSurface.withValues(alpha: 0.4),
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}