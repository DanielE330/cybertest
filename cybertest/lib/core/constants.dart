// API Configuration
class ApiConstants {
  static const String apiBaseUrl = 'http://localhost:8000';
  
  // Auth endpoints
  static const String loginEndpoint = '/users/login';
  static const String registerEndpoint = '/users/register';
  static const String logoutEndpoint = '/users/logout';
}

// Error messages
class ErrorMessages {
  static const String connectionTimeout = 'Истекло время подключения';
  static const String receiveTimeout = 'Истекло время ожидания ответа';
  static const String invalidCredentials = 'Неверные учетные данные';
  static const String userNotFound = 'Пользователь не найден';
  static const String userAlreadyExists = 'Пользователь уже существует';
  static const String networkError = 'Ошибка сети';
  static const String serverError = 'Ошибка сервера';
  static const String unknownError = 'Неизвестная ошибка';
}

// Storage keys
class StorageKeys {
  static const String authToken = 'auth_token';
  static const String userId = 'user_id';
  static const String userName = 'user_name';
  static const String userRole = 'user_role';
}
