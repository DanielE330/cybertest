import '../../core/models/user.dart';
import '../../core/services/api_client.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<User> login({
    required String username,
    required String password,
    String? role,
  }) async {
    try {
      final response = await _apiClient.login(
        username: username,
        password: password,
        role: role,
      );

      // Добавляем данные пользователя в response, т.к. бэк может их не возвращать
      response['username'] = username;
      response['name'] = username;
      if (role != null) {
        response['status'] = role;
        response['role'] = role;
      }

      final user = User.fromJson(response);
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User> register({
    required String username,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _apiClient.register(
        username: username,
        password: password,
        role: role,
      );

      // Добавляем данные пользователя в response, т.к. бэк их не возвращает
      response['username'] = username;
      response['name'] = username;
      response['status'] = role;
      response['role'] = role;

      final user = User.fromJson(response);
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _apiClient.logout();
  }
}
