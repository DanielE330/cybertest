// Пример использования API в тестах или в коде
// Это файл для справки, его не нужно подключать к приложению

// ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ

void exampleUsage() {
  // 1. РЕГИСТРАЦИЯ
  // POST /users/register
  // Body:
  // {
  //   "name": "da1n",
  //   "status": "student",
  //   "password": "1234567890"
  // }

  // 2. ВХОД
  // POST /users/login
  // Body:
  // {
  //   "name": "da1n",
  //   "status": "student",
  //   "password": "1234567890"
  // }

  // 3. ИСПОЛЬЗОВАНИЕ В FLUTTER
  // final authNotifier = ref.read(authProvider.notifier);
  // await authNotifier.login(
  //   name: "da1n",
  //   password: "1234567890",
  //   status: "student",
  // );
}

// ВОЗМОЖНЫЕ СТАТУСЫ ПОЛЬЗОВАТЕЛЯ
class UserStatuses {
  static const String student = 'student';   // Студент
  static const String teacher = 'teacher';       // Преподаватель
}

// ПРИМЕРЫ CURL КОМАНД

const String curlRegister = '''
curl -X 'POST' \\
  'http://localhost:8000/users/register' \\
  -H 'accept: application/json' \\
  -H 'Content-Type: application/json' \\
  -d '{
  "name": "da1n",
  "status": "student",
  "password": "1234567890"
}'
''';

const String curlLogin = '''
curl -X 'POST' \\
  'http://localhost:8000/users/login' \\
  -H 'accept: application/json' \\
  -H 'Content-Type: application/json' \\
  -d '{
  "name": "da1n",
  "status": "student",
  "password": "1234567890"
}'
''';

// ОТВЕТЫ API (ожидаемые форматы)

// УСПЕШНАЯ РЕГИСТРАЦИЯ (200/201)
const Map<String, dynamic> registrationSuccess = {
  'id': 'user_123',
  'name': 'da1n',
  'email': 'da1n@example.com',
  'status': 'student',
  'access_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
};

// УСПЕШНЫЙ ВХОД (200)
const Map<String, dynamic> loginSuccess = {
  'id': 'user_123',
  'name': 'da1n',
  'email': 'da1n@example.com',
  'status': 'student',
  'access_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
};

// ОШИБКА - Пользователь уже существует (409 или 400)
const Map<String, dynamic> userAlreadyExists = {
  'detail': 'Пользователь с таким именем уже существует',
  'status': 409
};

// ОШИБКА - Неверные учетные данные (401)
const Map<String, dynamic> invalidCredentials = {
  'detail': 'Неверное имя пользователя или пароль',
  'status': 401
};

// ОШИБКА - Пользователь не найден (404)
const Map<String, dynamic> userNotFound = {
  'detail': 'Пользователь не найден',
  'status': 404
};
