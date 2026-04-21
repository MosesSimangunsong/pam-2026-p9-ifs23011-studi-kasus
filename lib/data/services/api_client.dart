import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Centralised HTTP helper.
/// - Attaches Bearer token automatically when available.
/// - Throws [ApiException] on non-2xx responses.
class ApiClient {
  static const Duration _timeout = Duration(seconds: 30);

  // ── Token management ──────────────────────────────────────────────────────

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // ── Request helpers ───────────────────────────────────────────────────────

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Map<String, dynamic> _parse(http.Response res) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    final msg = body['message'] as String? ?? 'Unknown error';
    throw ApiException(msg, res.statusCode);
  }

  // ── Public methods ────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse(url).replace(queryParameters: query);
    try {
      final res = await http
          .get(uri, headers: await _headers())
          .timeout(_timeout);
      return _parse(res);
    } on SocketException {
      throw ApiException('No internet connection.', 0);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Request failed: $e', 0);
    }
  }

  static Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse(url),
            headers: await _headers(auth: auth),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _parse(res);
    } on SocketException {
      throw ApiException('No internet connection.', 0);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Request failed: $e', 0);
    }
  }

  static Future<Map<String, dynamic>> put(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await http
          .put(
            Uri.parse(url),
            headers: await _headers(),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _parse(res);
    } on SocketException {
      throw ApiException('No internet connection.', 0);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Request failed: $e', 0);
    }
  }

  static Future<Map<String, dynamic>> delete(String url) async {
    try {
      final res = await http
          .delete(Uri.parse(url), headers: await _headers())
          .timeout(_timeout);
      return _parse(res);
    } on SocketException {
      throw ApiException('No internet connection.', 0);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Request failed: $e', 0);
    }
  }
}

/// Typed exception from API calls.
class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException(this.message, this.statusCode);

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
