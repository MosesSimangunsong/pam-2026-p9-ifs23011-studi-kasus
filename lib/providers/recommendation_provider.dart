import 'package:flutter/material.dart';
import '../data/models/recommendation_model.dart';
import '../data/services/recommendation_service.dart';
import '../data/services/api_client.dart';

class RecommendationProvider extends ChangeNotifier {
  // ── History state ─────────────────────────────────────────────────────────
  final List<RecommendationModel> history = [];
  int  _page       = 1;
  bool hasMore     = true;
  bool isLoading   = false;

  // ── Generate state ────────────────────────────────────────────────────────
  bool                  isGenerating  = false;
  RecommendationModel?  latestResult;

  // ── Edit state ────────────────────────────────────────────────────────────
  bool isSavingNotes = false;

  String? error;

  // ── Generate ──────────────────────────────────────────────────────────────

  Future<RecommendationModel?> generate(String mood) async {
    isGenerating = true;
    error        = null;
    notifyListeners();

    try {
      final rec     = await RecommendationService.generate(mood);
      latestResult  = rec;

      // Prepend to history so it appears at top
      history.insert(0, rec);

      isGenerating = false;
      notifyListeners();
      return rec;
    } on ApiException catch (e) {
      error        = e.message;
      isGenerating = false;
      notifyListeners();
      return null;
    } catch (e) {
      error        = 'Unexpected error: $e';
      isGenerating = false;
      notifyListeners();
      return null;
    }
  }

  // ── History / Pagination ──────────────────────────────────────────────────

  Future<void> fetchHistory({bool reset = false}) async {
    if (isLoading) return;
    if (!reset && !hasMore) return;

    if (reset) {
      history.clear();
      _page   = 1;
      hasMore = true;
    }

    isLoading = true;
    error     = null;
    notifyListeners();

    try {
      final result = await RecommendationService.getHistory(page: _page);

      final items = result['items'] as List<RecommendationModel>;
      history.addAll(items);
      hasMore = result['has_more'] as bool;
      if (items.isNotEmpty) _page++;
    } on ApiException catch (e) {
      error = e.message;
    } catch (e) {
      error = 'Unexpected error: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  // ── Update notes ──────────────────────────────────────────────────────────

  Future<bool> updateNotes(int id, String notes) async {
    isSavingNotes = true;
    error         = null;
    notifyListeners();

    try {
      final updated = await RecommendationService.updateNotes(id, notes);

      final idx = history.indexWhere((r) => r.id == id);
      if (idx != -1) history[idx] = updated;
      if (latestResult?.id == id) latestResult = updated;

      isSavingNotes = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      error         = e.message;
      isSavingNotes = false;
      notifyListeners();
      return false;
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<bool> delete(int id) async {
    error = null;
    try {
      await RecommendationService.delete(id);
      history.removeWhere((r) => r.id == id);
      if (latestResult?.id == id) latestResult = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      error = e.message;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}
