import 'package:flutter/material.dart';
import '../data/models/motivation_model.dart';
import '../data/services/motivation_service.dart';

class MotivationProvider extends ChangeNotifier {
  List<Motivation> motivations = [];
  int page = 1;
  bool isLoading = false;
  bool hasMore = true;

  // 🔥 NEW
  bool isGenerating = false;

  Future<void> fetchMotivations() async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    notifyListeners();

    final result = await MotivationService.getMotivations(page);

    List data = result["data"];

    if (data.isEmpty) {
      hasMore = false;
    } else {
      motivations.addAll(
        data.map((e) => Motivation.fromJson(e)).toList(),
      );
      page++;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> generate(String theme, int total) async {
    isGenerating = true;
    notifyListeners();

    try {
      await MotivationService.generateMotivation(theme, total);

      motivations.clear();
      page = 1;
      hasMore = true;

      await fetchMotivations();
    } finally {
      isGenerating = false;
      notifyListeners();
    }
  }
}