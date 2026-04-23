import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service untuk Motivation feature.
///
/// FIX: Tidak lagi pakai ApiClient (yang otomatis attach JWT Bearer token).
/// Alasan: API ini adalah external API (higherlearn.xyz) yang tidak
/// membutuhkan autentikasi JWT — berbeda dengan backend kita sendiri.
/// Menggunakan ApiClient untuk endpoint ini menyebabkan request gagal
/// karena server external tidak mengenali/menerima token kita.
///
/// Solusi: pakai http.get/post langsung dengan URL external.
class MotivationService {
  // URL external API (bukan backend Flask kita)
  static const String _baseUrl =
      'https://pam-2026-p9-ifs18005-be.higherlearn.xyz:8080';

  /// Fetch daftar motivasi dengan pagination.
  static Future<Map<String, dynamic>> getMotivations(int page) async {
    try {
      final uri = Uri.parse('$_baseUrl/motivations').replace(
        queryParameters: {'page': '$page', 'per_page': '10'},
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      throw Exception('Server error: ${res.statusCode}');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Gagal memuat motivasi: $e');
    }
  }

  /// Generate motivasi baru berdasarkan tema.
  static Future<void> generateMotivation(String theme, int total) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/motivations/generate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'theme': theme, 'total': total}),
          )
          .timeout(const Duration(seconds: 60));

      if (res.statusCode != 200) {
        throw Exception('Generate gagal: ${res.statusCode}');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Gagal generate motivasi: $e');
    }
  }
}
