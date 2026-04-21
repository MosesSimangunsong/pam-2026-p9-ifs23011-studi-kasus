import '../models/user_model.dart';
import 'api_client.dart';
import '../../core/constants/api_constants.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final res = await ApiClient.post(
      ApiConstants.login,
      {'username': username, 'password': password},
      auth: false,
    );

    final data  = res['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final user  = UserModel.fromJson(data['user'] as Map<String, dynamic>);

    await ApiClient.saveToken(token);
    return {'token': token, 'user': user};
  }

  static Future<UserModel> getMe() async {
    final res  = await ApiClient.get(ApiConstants.me);
    final data = res['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  static Future<void> logout() async {
    await ApiClient.clearToken();
  }
}
