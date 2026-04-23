import 'package:flutter/material.dart';
import '../data/models/motivation_model.dart';
import '../data/services/motivation_service.dart';

/// Provider untuk Motivation feature (fitur original dari repo).
///
/// FIX: tambah try-catch di fetchMotivations() dan generate().
/// Sebelumnya tidak ada error handling sama sekali → jika API gagal
/// (timeout, server down, JSON parsing error), app langsung crash
/// dengan unhandled exception. Sekarang error ditangkap dan disimpan
/// di field `error` agar UI bisa menampilkan pesan yang sesuai.
class MotivationProvider extends ChangeNotifier {
  List<Motivation> motivations = [];
  int     page        = 1;
  bool    isLoading   = false;
  bool    isGenerating = false;
  bool    hasMore     = true;
  String? error;  // FIX: tambah field error untuk ditampilkan di UI

  Future<void> fetchMotivations() async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    error     = null;  // reset error setiap kali fetch
    notifyListeners();

    try {
      // FIX: wrap dalam try-catch
      final result = await MotivationService.getMotivations(page);
      final List data = (result['data'] as List?) ?? [];

      if (data.isEmpty) {
        hasMore = false;
      } else {
        motivations.addAll(
          data
              .map((e) => Motivation.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
        page++;
      }
    } catch (e) {
      // Simpan pesan error, jangan crash
      error = 'Gagal memuat motivasi. Coba lagi.';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> generate(String theme, int total) async {
    isGenerating = true;
    error        = null;
    notifyListeners();

    try {
      // FIX: wrap dalam try-catch
      await MotivationService.generateMotivation(theme, total);

      // Reset dan fetch ulang setelah generate
      motivations.clear();
      page    = 1;
      hasMore = true;
      await fetchMotivations();
    } catch (e) {
      error = 'Gagal generate motivasi. Coba lagi.';
    } finally {
      // finally memastikan isGenerating selalu false meski ada error
      isGenerating = false;
      notifyListeners();
    }
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}
