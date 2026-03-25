import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../../features/auth/auth_repository.dart';
import '../services/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  print('[PROVIDER] 🏗️ Создаю ApiClient (синглтон)');
  return ApiClient();
});

final authRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient);
});

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> login({
    required String username,
    required String password,
    String? role,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => _repository.login(
          username: username,
          password: password,
          role: role,
        ));
  }

  Future<void> register({
    required String username,
    required String password,
    required String role,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => _repository.register(
          username: username,
          password: password,
          role: role,
        ));
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }
}