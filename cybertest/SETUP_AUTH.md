# Логика аутентификации и регистрации - Инструкция по установке

## ✅ Что было реализовано

### 1. **API Client** (`lib/core/services/api_client.dart`)
- HTTP клиент на базе Dio
- Автоматическое сохранение и отправка токена авторизации
- Обработка ошибок с понятными сообщениями
- Перехват запросов (interceptors) для добавления Bearer token

### 2. **Модель User** (обновлена `lib/core/models/user.dart`)
- Добавлены поля: `name`, `accessToken`, `id`
- Методы конвертации: `fromJson()`, `toJson()`
- Правильная обработка статусов (student, reviewer, admin)

### 3. **Repository** (обновлен `lib/features/auth/auth_repository.dart`)
- Методы: `login()`, `register()`, `logout()`
- Взаимодействие с ApiClient
- Преобразование ответов в объекты User

### 4. **State Management** (обновлен `lib/core/providers/auth_provider.dart`)
- Использование Riverpod StateNotifier
- Управление состоянием загрузки (AsyncValue)
- Обработка ошибок в UI

### 5. **UI Экраны**
- `lib/features/auth/login_screen.dart` - экран входа с валидацией
- `lib/features/auth/registration_screen.dart` - экран регистрации
- Обработка ошибок и состояния загрузки

### 6. **Маршрутизация** (обновлена `lib/core/router.dart`)
- Добавлен маршрут для регистрации

## 🚀 Как начать использовать

### 1. Установите зависимости
```bash
flutter pub get
```

Были добавлены в `pubspec.yaml`:
- `dio: ^5.4.0` - HTTP клиент
- `shared_preferences: ^2.2.2` - локальное хранилище токена

### 2. Обновите базовый URL API
В файле `lib/core/services/api_client.dart` найдите:
```dart
static const String baseUrl = 'http://localhost:8000';
```

Измените на адрес вашего API сервера при необходимости.

### 3. API Endpoints

#### Регистрация
```
POST /users/register
Content-Type: application/json

Body:
{
  "name": "username",
  "status": "student|reviewer|admin",
  "password": "password"
}

Response (200/201):
{
  "id": "user_id",
  "name": "username",
  "email": "email@example.com",
  "status": "student",
  "access_token": "token_value"
}
```

#### Вход
```
POST /users/login
Content-Type: application/json

Body:
{
  "name": "username",
  "status": "student|reviewer|admin",
  "password": "password"
}

Response (200):
{
  "id": "user_id",
  "name": "username",
  "email": "email@example.com",
  "status": "student",
  "access_token": "token_value"
}
```

## 📝 Примеры использования в коде

### В ConsumerWidget или ConsumerStatefulWidget:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Вход
await ref.read(authProvider.notifier).login(
  name: 'da1n',
  password: '1234567890',
  status: 'student',
);

// Регистрация
await ref.read(authProvider.notifier).register(
  name: 'da1n',
  password: '1234567890',
  status: 'student',
);

// Получить текущего пользователя
final authState = ref.watch(authProvider);
authState.whenData((user) {
  if (user != null) {
    print('Вошли как: ${user.name}');
  }
});

// Выход
await ref.read(authProvider.notifier).logout();
```

## 🧪 Тестирование с curl

### Регистрация
```bash
curl -X 'POST' \
  'http://localhost:8000/users/register' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "name": "da1n",
  "status": "student",
  "password": "1234567890"
}'
```

### Вход
```bash
curl -X 'POST' \
  'http://localhost:8000/users/login' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "name": "da1n",
  "status": "student",
  "password": "1234567890"
}'
```

## 📂 Структура файлов

```
lib/
├── core/
│   ├── constants.dart (новый - константы приложения)
│   ├── models/
│   │   └── user.dart (обновлена)
│   ├── providers/
│   │   └── auth_provider.dart (обновлена)
│   ├── router.dart (обновлена)
│   └── services/
│       └── api_client.dart (новый - HTTP клиент)
└── features/
    └── auth/
        ├── auth_repository.dart (обновлена)
        ├── login_screen.dart (обновлена)
        ├── registration_screen.dart (новый)
        ├── example_api_usage.dart (справка)
        └── README_AUTH.md (документация)
```

## 🔐 Безопасность

- ✅ Пароли отправляются в HTTPS (используйте HTTPS в продакшене)
- ✅ Токен сохраняется в SharedPreferences
- ✅ Токен автоматически добавляется в заголовок Authorization для всех запросов
- ✅ При получении 401 ошибки токен автоматически удаляется
- ✅ Валидация пароля на клиенте (минимум 8 символов)

## ⚠️ Важно

1. **Убедитесь что API сервер запущен** на адресе из `baseUrl`
2. **Проверьте формат ответов API** - они должны содержать как минимум поля `name`, `status` и опционально `access_token`
3. **API должен возвращать access_token** для сохранения авторизации
4. **Используйте HTTPS в продакшене** для безопасной передачи пароля

## 🆘 Решение проблем

### Ошибка "Не удается подключиться к серверу"
- Проверьте что API запущен на `http://localhost:8000`
- Убедитесь что базовый URL правильный в `api_client.dart`

### Ошибка "Неверные учетные данные"
- Проверьте что отправляете правильные поля: `name`, `status`, `password`
- Убедитесь что поле `status` содержит одно из значений: `student`, `reviewer`, `admin`

### Токен не сохраняется
- Проверьте что API возвращает поле `access_token`
- Убедитесь что SharedPreferences правильно инициализирует (добавьте зависимость если еще не добавили)

### CORS ошибка
- Настройте CORS на бэкенде чтобы принимать запросы с фронтенда
- Добавьте нужные заголовки в ответы API

## 📚 Дополнительная информация

- [Документация Dio](https://pub.dev/packages/dio)
- [Документация Riverpod](https://riverpod.dev)
- [Документация SharedPreferences](https://pub.dev/packages/shared_preferences)
