import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class MotivationService {

  static Future<Map<String, dynamic>> getMotivations(int page) async {
    final response = await http.get(
      Uri.parse("${ApiConstants.motivations}?page=$page&per_page=10"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load motivations");
    }
  }

  static Future<void> generateMotivation(String theme, int total) async {
    final response = await http.post(
      Uri.parse(ApiConstants.generate),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "theme": theme,
        "total": total
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to generate");
    }
  }
}