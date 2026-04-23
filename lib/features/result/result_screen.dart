import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/recommendation_model.dart';
import '../../providers/recommendation_provider.dart';
import '../widgets/shared_widgets.dart';

class ResultScreen extends StatefulWidget {
  final RecommendationModel recommendation;

  const ResultScreen({super.key, required this.recommendation});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late RecommendationModel _rec;
  final _notesController = TextEditingController();
  bool  _editingNotes    = false;

  @override
  void initState() {
    super.initState();
    _rec = widget.recommendation;
    _notesController.text = _rec.notes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveNotes() async {
    final prov = context.read<RecommendationProvider>();
    final ok   = await prov.updateNotes(
        _rec.id, _notesController.text.trim());
    if (!mounted) return;

    if (ok) {
      setState(() {
        _rec          = _rec.copyWith(notes: _notesController.text.trim());
        _editingNotes = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Catatan disimpan ✓'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(prov.error ?? 'Gagal menyimpan catatan.'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // FIX: hapus variable isDark yang dideklarasi tapi tidak pernah dipakai.
    // Unused variable menyebabkan lint warning "unused_local_variable".
    final prov = context.watch<RecommendationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rekomendasi AI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MoodBadge(mood: _rec.mood, createdAt: _rec.createdAt),
            const SizedBox(height: 24),

            _SectionCard(
              title:    '🏃 Rekomendasi Olahraga',
              color:    const Color(0xFF10B981),
              items:    _rec.exercise,
              iconData: Icons.fitness_center_rounded,
            ),
            const SizedBox(height: 16),

            _SectionCard(
              title:    '✨ Kegiatan Positif',
              color:    const Color(0xFF6366F1),
              items:    _rec.activities,
              iconData: Icons.star_outline_rounded,
            ),
            const SizedBox(height: 24),

            _NotesSection(
              notes:        _rec.notes,
              controller:   _notesController,
              isEditing:    _editingNotes,
              isSaving:     prov.isSavingNotes,
              onEditToggle: () => setState(() {
                _editingNotes = !_editingNotes;
                if (!_editingNotes) {
                  _notesController.text = _rec.notes ?? '';
                }
              }),
              onSave: _saveNotes,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _MoodBadge extends StatelessWidget {
  final String mood;
  final String createdAt;
  const _MoodBadge({required this.mood, required this.createdAt});

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
            color: const Color(0xFF6366F1).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mood kamu:',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            mood,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            createdAt.length >= 10
                ? createdAt.substring(0, 10)
                : createdAt,
            style: const TextStyle(
                color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String       title;
  final Color        color;
  final List<String> items;
  final IconData     iconData;

  const _SectionCard({
    required this.title,
    required this.color,
    required this.items,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(iconData, color: color, size: 22),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: items.asMap().entries.map((e) {
                final idx  = e.key + 1;
                final text = e.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 26, height: 26,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$idx',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          text,
                          style: const TextStyle(
                              fontSize: 14, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Colors.orange.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.sticky_note_2_outlined,
                      color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Catatan Saya',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onEditToggle,
                icon: Icon(
                  isEditing
                      ? Icons.close_rounded
                      : Icons.edit_outlined,
                  size: 16,
                ),
                label: Text(isEditing ? 'Batal' : 'Edit'),
                style: TextButton.styleFrom(
                  foregroundColor:
                      isEditing ? Colors.red : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (isEditing) ...[
            TextFormField(
              controller: controller,
              maxLines:   4,
              maxLength:  500,
              decoration: InputDecoration(
                hintText: 'Tulis catatanmu di sini...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Colors.orange),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Colors.orange, width: 2),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label:     'Simpan Catatan',
                icon:      Icons.save_rounded,
                isLoading: isSaving,
                color:     Colors.orange,
                onPressed: onSave,
              ),
            ),
          ] else
            notes != null && notes!.isNotEmpty
                ? Text(notes!,
                    style: const TextStyle(
                        fontSize: 14, height: 1.5))
                : const Text(
                    'Belum ada catatan. Tekan "Edit" untuk menambahkan.',
                    style: TextStyle(
                        color: Colors.grey, fontSize: 13),
                  ),
        ],
      ),
    );
  }
}
