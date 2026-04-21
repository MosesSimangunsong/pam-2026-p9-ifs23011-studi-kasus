class ApiConstants {
  // ── Base URL ──────────────────────────────────────────────────────────────
  // Change this to your backend's address (local dev or deployed).
  static const String baseUrl = "http://10.0.2.2:5000"; // Android emulator
  // static const String baseUrl = "http://localhost:5000"; // iOS simulator
  // static const String baseUrl = "https://your-deployed-backend.com"; // Production

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login = "$baseUrl/auth/login";
  static const String me    = "$baseUrl/auth/me";

  // ── Recommendations ───────────────────────────────────────────────────────
  static const String recommendations         = "$baseUrl/recommendations";
  static const String generateRecommendation  = "$baseUrl/recommendations/generate";

  static String recommendationById(int id)  => "$baseUrl/recommendations/$id";

  // ── Motivations ────────────────────────────────────────────────────────────
  static const String motivations             = "$baseUrl/motivations";
  static const String generateMotivation      = "$baseUrl/motivations/generate";

  static String motivationById(int id)      => "$baseUrl/motivations/$id";
}
