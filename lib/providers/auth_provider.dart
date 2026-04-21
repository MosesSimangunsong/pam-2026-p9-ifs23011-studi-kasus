import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';
import '../data/services/api_client.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus status = AuthStatus.unknown;
  UserModel? user;
  String?   error;
  bool      isLoading = false;

  // ── Bootstrap ─────────────────────────────────────────────────────────────

  /// Called at app start to check if a saved token is still valid.
  Future<void> checkAuth() async {
    final token = await ApiClient.getToken();
    if (token == null) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      user   = await AuthService.getMe();
      status = AuthStatus.authenticated;
    } catch (_) {
      await ApiClient.clearToken();
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<bool> login(String username, String password) async {
    isLoading = true;
    error     = null;
    notifyListeners();

    try {
      final result = await AuthService.login(username, password);
      user   = result['user'] as UserModel;
      status = AuthStatus.authenticated;
      isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      error     = e.message;
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      error     = 'An unexpected error occurred.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await AuthService.logout();
    user   = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}
