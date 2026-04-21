import '../models/recommendation_model.dart';
import 'api_client.dart';
import '../../core/constants/api_constants.dart';

class RecommendationService {
  /// Generate a new recommendation from Gemini and persist it.
  static Future<RecommendationModel> generate(String mood) async {
    final res  = await ApiClient.post(
      ApiConstants.generateRecommendation,
      {'mood': mood},
    );
    return RecommendationModel.fromJson(
      res['data'] as Map<String, dynamic>,
    );
  }

  /// Paginated history for the current user.
  static Future<Map<String, dynamic>> getHistory({
    int page = 1,
    int perPage = 10,
  }) async {
    final res = await ApiClient.get(
      ApiConstants.recommendations,
      query: {'page': '$page', 'per_page': '$perPage'},
    );
    final items = (res['data'] as List)
        .map((e) => RecommendationModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return {
      'items':    items,
      'total':    res['total']    as int,
      'has_more': res['has_more'] as bool,
    };
  }

  /// Fetch a single recommendation by id.
  static Future<RecommendationModel> getById(int id) async {
    final res = await ApiClient.get(ApiConstants.recommendationById(id));
    return RecommendationModel.fromJson(
      res['data'] as Map<String, dynamic>,
    );
  }

  /// Update only the `notes` field of a recommendation.
  static Future<RecommendationModel> updateNotes(int id, String notes) async {
    final res = await ApiClient.put(
      ApiConstants.recommendationById(id),
      {'notes': notes},
    );
    return RecommendationModel.fromJson(
      res['data'] as Map<String, dynamic>,
    );
  }

  /// Permanently delete a recommendation.
  static Future<void> delete(int id) async {
    await ApiClient.delete(ApiConstants.recommendationById(id));
  }
}
