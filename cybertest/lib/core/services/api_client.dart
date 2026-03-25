import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  late final Dio _dio;
  static const String baseUrl = 'http://localhost:8000';
  static const String _tokenKey = 'auth_token';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Dio get dio => _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          print('\n╔════════════════════════════════════════════');
          print('║ [API] 🚀 REQUEST: ${options.method.toUpperCase()} ${options.path}');
          print('╠════════════════════════════════════════════');
          
          final token = await _getToken();
          print('║ [STORAGE] 🔐 Токен прочитан: ${token != null ? "✅ ДА" : "❌ НЕТ"}');
          
          if (token != null && token.isNotEmpty) {
            print('║ [STORAGE] 📏 Длина токена: ${token.length} символов');
            print('║ [STORAGE] 🔤 Первые 30 символов: ${token.substring(0, (token.length > 30 ? 30 : token.length))}...');
            options.headers['Authorization'] = 'Bearer $token';
            print('║ [API] ✅ Authorization заголовок ДОБАВЛЕН!');
          } else {
            print('║ [API] ⚠️ Authorization заголовок НЕ ДОБАВЛЕН (токен пуст или null)');
          }
          
          print('║ [API] 📋 Все заголовки перед отправкой:');
          options.headers.forEach((key, value) {
            if (key == 'Authorization') {
              print('║   • $key: Bearer [TOKEN_${token?.length ?? 0}_СИМВОЛОВ]');
            } else {
              print('║   • $key: $value');
            }
          });
          print('╚════════════════════════════════════════════\n');
          
          return handler.next(options);
        },
        onError: (error, handler) {
          print('\n╔════════════════════════════════════════════');
          print('║ [API] ❌ ОШИБКА ЗАПРОСА');
          print('╠════════════════════════════════════════════');
          print('║ Status Code: ${error.response?.statusCode}');
          print('║ Message: ${error.message}');
          print('║ Response Data: ${error.response?.data}');
          print('╚════════════════════════════════════════════\n');
          
          if (error.response?.statusCode == 401) {
            print('[API] 🔓 Токен невалидный (401). Очищаю storage...');
            _clearToken();
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    String? role,
  }) async {
    try {
      print('\n╔════════════════════════════════════════════');
      print('║ [AUTH] 📝 ПОПЫТКА ЛОГИНА');
      print('╠════════════════════════════════════════════');
      print('║ Username: $username');
      print('║ Password: [скрыт]');
      print('║ Role: ${role ?? "не указана"}');
      
      final response = await _dio.post(
        '/users/login',
        data: {
          'name': username,
          'password': password,
          if (role != null) 'status': role,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        
        print('║ ✅ Логин успешен!');
        print('║ 📋 Полный ответ от сервера:');
        data.forEach((key, value) {
          if (key == 'access_token' && value != null) {
            print('║   • $key: [TOKEN_${value.toString().length}_СИМВОЛОВ]');
          } else {
            print('║   • $key: $value');
          }
        });
        
        // Сохраняем токен если он есть в ответе
        if (data.containsKey('access_token')) {
          await _saveToken(data['access_token']);
        } else {
          print('║ ⚠️ access_token не найден в ответе!');
        }
        
        print('╚════════════════════════════════════════════\n');
        return data;
      }
      throw Exception('Ошибка входа: ${response.statusCode}');
    } on DioException catch (e) {
      print('[AUTH] ❌ Ошибка логина: ${_handleError(e)}');
      print('╚════════════════════════════════════════════\n');
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String role,
  }) async {
    try {
      print('\n╔════════════════════════════════════════════');
      print('║ [AUTH] 📝 ПОПЫТКА РЕГИСТРАЦИИ');
      print('╠════════════════════════════════════════════');
      print('║ Username: $username');
      print('║ Password: [скрыт]');
      print('║ Role: $role');
      
      final response = await _dio.post(
        '/users/register',
        data: {
          'name': username,
          'password': password,
          'status': role,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        
        print('║ ✅ Регистрация успешна!');
        print('║ 📋 Полный ответ от сервера:');
        data.forEach((key, value) {
          if (key == 'access_token' && value != null) {
            print('║   • $key: [TOKEN_${value.toString().length}_СИМВОЛОВ]');
          } else {
            print('║   • $key: $value');
          }
        });
        
        // Сохраняем токен если он есть в ответе
        if (data.containsKey('access_token')) {
          await _saveToken(data['access_token']);
        } else {
          print('║ ⚠️ access_token не найден в ответе!');
        }
        
        print('╚════════════════════════════════════════════\n');
        return data;
      }
      throw Exception('Ошибка регистрации: ${response.statusCode}');
    } on DioException catch (e) {
      print('[AUTH] ❌ Ошибка регистрации: ${_handleError(e)}');
      print('╚════════════════════════════════════════════\n');
      throw Exception(_handleError(e));
    }
  }

  Future<void> logout() async {
    await _clearToken();
  }

  Future<void> _saveToken(String token) async {
    try {
      print('\n╔════════════════════════════════════════════');
      print('║ [STORAGE] 💾 СОХРАНЯЮ ТОКЕН');
      print('╠════════════════════════════════════════════');
      print('║ Длина токена: ${token.length} символов');
      print('║ Начало: ${token.substring(0, (token.length > 30 ? 30 : token.length))}...');
      print('║ Ключ: $_tokenKey');
      
      await _secureStorage.write(key: _tokenKey, value: token);
      
      print('║ ✅ Токен успешно сохранён в FlutterSecureStorage');
      print('╚════════════════════════════════════════════\n');
    } catch (e) {
      print('║ ❌ ОШИБКА при сохранении токена: $e');
      print('╚════════════════════════════════════════════\n');
    }
  }

  Future<String?> _getToken() async {
    try {
      print('[STORAGE] 🔍 Начинаю чтение токена из FlutterSecureStorage...');
      final token = await _secureStorage.read(key: _tokenKey);
      
      if (token != null && token.isNotEmpty) {
        print('[STORAGE] ✅ УСПЕШНО! Токен прочитан');
        print('[STORAGE] 📏 Длина: ${token.length} символов');
        print('[STORAGE] 🔤 Начало: ${token.substring(0, (token.length > 20 ? 20 : token.length))}...');
        return token;
      } else {
        print('[STORAGE] ⚠️ Токен пуст или null в storage');
        return null;
      }
    } catch (e) {
      print('[STORAGE] ❌ ОШИБКА при чтении токена: $e');
      return null;
    }
  }

  Future<void> _clearToken() async {
    try {
      print('[STORAGE] 🗑️ УДАЛЯЮ токен из FlutterSecureStorage...');
      await _secureStorage.delete(key: _tokenKey);
      print('[STORAGE] ✅ Токен успешно удалён');
    } catch (e) {
      print('[STORAGE] ❌ ОШИБКА при удалении токена: $e');
    }
  }

  String _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout) {
      return 'Истекло время подключения';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Истекло время ожидания ответа';
    } else if (error.type == DioExceptionType.badResponse) {
      final statusCode = error.response?.statusCode;
      final responseData = error.response?.data;
      final message = error.response?.data?['detail'] ?? 
                      error.response?.data?['message'] ??
                      'Ошибка сервера';
      print('[ERROR] 📡 Полный ответ сервера ($statusCode): $responseData');
      return 'Ошибка: $message (код $statusCode)';
    } else if (error.type == DioExceptionType.cancel) {
      return 'Запрос отменён';
    } else {
      return 'Ошибка сети: ${error.message}';
    }
  }
}
