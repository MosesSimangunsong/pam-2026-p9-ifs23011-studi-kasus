import '../../core/constants/api_constants.dart';
import 'api_client.dart';

class MotivationService {
  /// Fetch paginated list of motivations for the current user.
  static Future<Map<String, dynamic>> getMotivations(int page) async {
    final res = await ApiClient.get(
      ApiConstants.motivations,
      query: {'page': '$page', 'per_page': '10'},
    );
    return res;
  }

  /// Generate new motivations and persist them.
  static Future<void> generateMotivation(String theme, int total) async {
    await ApiClient.post(
      ApiConstants.generateMotivation,
      {'theme': theme, 'total': total},
    );
  }
}