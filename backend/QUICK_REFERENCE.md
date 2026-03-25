# Справка по эндпоинтам API

## Быстрая ссылка по всем методам

### 🔐 Аутентификация (3 методов)
| № | Метод | Эндпоинт | Аутентификация | Статус |
|---|-------|----------|----------------|--------|
| 1 | POST | `/users/register` | ❌ Не требуется | ✅ Готов |
| 2 | POST | `/users/login` | ❌ Не требуется | ✅ Готов |
| 3 | GET | `/users/me` | ✅ Требуется | ✅ Готов |

### 👨‍🏫 Преподаватель - Управление тестами (4 методов)
| № | Метод | Эндпоинт | Аутентификация | Статус |
|---|-------|----------|----------------|--------|
| 4 | GET | `/tests` | ✅ Требуется | ✨ Новый |
| 5 | POST | `/tests` | ✅ Требуется | ✅ Готов |
| 6 | POST | `/tests/{test_id}/questions` | ✅ Требуется | ⚠️ Переделать |
| 7 | POST | `/tests/{test_id}/questions/{question_id}/answers` | ✅ Требуется | ✅ Готов |
| 8 | GET | `/tests/{test_id}/results` | ✅ Требуется | ✨ Новый |

### 📝 Студент - Прохождение тестов (5 методов)
| № | Метод | Эндпоинт | Аутентификация | Статус |
|---|-------|----------|----------------|--------|
| 9 | GET | `/tests/access?access_code={code}` | ✅ Требуется | ✨ Новый |
| 10 | GET | `/tests/{test_id}` | ✅ Требуется | ✅ Готов |
| 11 | POST | `/tests/attempts` | ✅ Требуется | ✨ Новый |
| 12 | POST | `/tests/attempts/{attempt_id}/answers` | ✅ Требуется | ✨ Новый |
| 13 | POST | `/tests/attempts/{attempt_id}/complete` | ✅ Требуется | ✨ Новый |

---

## Группировка по ролям

### 👨‍🏫 Для преподавателя
- **Просмотр:** GET /tests, GET /tests/{test_id}/results
- **Создание:** POST /tests, POST /tests/{test_id}/questions
- **Добавление:** POST /tests/{test_id}/questions/{question_id}/answers

### 👨‍🎓 Для студента
- **Получение:** GET /tests/access, GET /tests/{test_id}
- **Прохождение:** POST /tests/attempts, POST /tests/attempts/{attempt_id}/answers
- **Завершение:** POST /tests/attempts/{attempt_id}/complete

### 🔑 Для обоих
- **Аутентификация:** POST /users/register, POST /users/login, GET /users/me

---

## Порядок вызовов

### 🔄 Поток регистрации → создание теста → добавление вопроса
```
1. POST /users/register          → получить token
2. POST /tests                    → создать тест (вернёт test_id)
3. POST /tests/{test_id}/questions  → добавить вопрос с ответами
```

### 🔄 Поток студента
```
1. POST /users/register          → получить token
2. GET /tests/access?access_code={code}  → получить test_id
3. POST /tests/attempts          → начать попытку (вернёт attempt_id)
4. POST /tests/attempts/{attempt_id}/answers  → отправить ответы
5. POST /tests/attempts/{attempt_id}/complete  → завершить и получить результат
```

### 🔄 Поток отчётности преподавателя
```
1. GET /tests               → получить список тестов
2. GET /tests/{test_id}/results  → см. результаты по каждому тесту
```

---

## Коды ошибок

| Код | Значение | Решение |
|-----|----------|---------|
| 200 | OK | Запрос успешен |
| 400 | Bad Request | Проверить данные запроса |
| 401 | Unauthorized | Нужна авторизация (отсутствует/невалидный токен) |
| 403 | Forbidden | У пользователя нет прав на операцию (не преподаватель/студент) |
| 404 | Not Found | Ресурс не найден (тест, попытка, вопрос) |
| 422 | Unprocessable Entity | Ошибка валидации данных (например, нет правильного ответа) |
| 500 | Internal Server Error | Ошибка сервера |

---

## Headers по умолчанию

### Все запросы с аутентификацией
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

### Без аутентификации (только register и login)
```
Content-Type: application/json
```

---

## Примеры curl команд

### Регистрация
```bash
curl -X POST http://localhost:8000/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "john_teacher",
    "password": "password123",
    "status": "teacher"
  }'
```

### Создание теста
```bash
curl -X POST http://localhost:8000/tests \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Математика 10 класс",
    "description": "Контрольная работа"
  }'
```

### Добавление вопроса с ответами
```bash
curl -X POST http://localhost:8000/tests/1/questions \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Сколько будет 2 + 2?",
    "type": "single",
    "question_order": 1,
    "answers": [
      {"text": "3", "is_correct": false},
      {"text": "4", "is_correct": true},
      {"text": "5", "is_correct": false}
    ]
  }'
```

### Получение теста по коду доступа
```bash
curl -X GET 'http://localhost:8000/tests/access?access_code=ABC123XY' \
  -H "Authorization: Bearer {token}"
```

### Отправка ответов студента
```bash
curl -X POST http://localhost:8000/tests/attempts/1/answers \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "answers": [
      {"question_id": 1, "answer_id": 5},
      {"question_id": 2, "answer_id": 7}
    ]
  }'
```

---

**Обновлено:** 20 марта 2026 г.
