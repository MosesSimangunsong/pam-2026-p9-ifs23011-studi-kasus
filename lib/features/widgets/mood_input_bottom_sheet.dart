import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../data/models/recommendation_model.dart';
import '../../../providers/recommendation_provider.dart';

/// Bottom Sheet untuk input mood.
/// Me-return [RecommendationModel] via Navigator.pop saat generate berhasil.
class MoodInputBottomSheet extends StatefulWidget {
  const MoodInputBottomSheet({super.key});

  @override
  State<MoodInputBottomSheet> createState() => _MoodInputBottomSheetState();
}

class _MoodInputBottomSheetState extends State<MoodInputBottomSheet>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode  = FocusNode();
  String? _errorText;

  // Quick mood options
  static const _quickMoods = [
    ('Sedih',         '😢'),
    ('Stres',         '😤'),
    ('Lelah',         '😴'),
    ('Tidak Semangat','😶'),
    ('Cemas',         '😰'),
    ('Marah',         '😠'),
    ('Bosan',         '🥱'),
    ('Bahagia',       '😊'),
  ];

  @override
  void initState() {
    super.initState();
    // Auto-focus setelah sheet terbuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _focusNode.requestFocus();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final mood = _controller.text.trim();
    if (mood.isEmpty) {
      setState(() => _errorText = 'Ceritakan perasaanmu dulu ya 😊');
      return;
    }
    if (mood.length > 100) {
      setState(() => _errorText = 'Maks. 100 karakter');
      return;
    }

    setState(() => _errorText = null);
    _focusNode.unfocus();

    final prov   = context.read<RecommendationProvider>();
    final result = await prov.generate(mood);

    if (!mounted) return;

    if (result != null) {
      Navigator.pop(context, result);      // return result ke HomeScreen
    } else {
      setState(() => _errorText = prov.error ?? 'Gagal generate. Coba lagi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov   = context.watch<RecommendationProvider>();
    final colors = Theme.of(context).colorScheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color:        Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Drag handle ────────────────────────────────────────────────────
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: colors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Title ──────────────────────────────────────────────────────────
          Text(
            'Apa yang kamu rasakan?',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ketik dengan bebas — tidak ada jawaban yang salah.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),

          // ── Text Field ─────────────────────────────────────────────────────
          TextField(
            controller:  _controller,
            focusNode:   _focusNode,
            maxLines:    4,
            maxLength:   100,
            enabled:     !prov.isGenerating,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: colors.onSurface,
              height: 1.6,
            ),
            decoration: InputDecoration(
              hintText: 'Contoh: hari ini aku merasa sangat lelah dan tidak termotivasi...',
              counterStyle: GoogleFonts.poppins(
                fontSize: 11,
                color: colors.onSurface.withValues(alpha: 0.35),
              ),
              errorText: _errorText,
              errorStyle: GoogleFonts.poppins(fontSize: 12, height: 1.4),
            ),
            onChanged: (_) {
              if (_errorText != null) setState(() => _errorText = null);
            },
          ),
          const SizedBox(height: 16),

          // ── Quick mood chips ───────────────────────────────────────────────
          Text(
            'Atau pilih suasana hati:',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _quickMoods.map((m) {
                final (label, emoji) = m;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: prov.isGenerating
                        ? null
                        : () => _controller.text = label,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        '$emoji  $label',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // ── Generate button ────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: prov.isGenerating ? null : _generate,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: prov.isGenerating
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI sedang berpikir...',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Dapatkan Rekomendasi',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}