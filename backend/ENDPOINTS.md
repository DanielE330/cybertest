# API Endpoints Documentation

## Authentication Endpoints

### 1. Register User
- **URL:** `POST /users/register`
- **Description:** Создание нового пользователя и автоматический вход
- **Request Body:**
  ```json
  {
    "name": "string",
    "password": "string",
    "status": "student" | "teacher"
  }
  ```
- **Response:** 
  ```json
  {
    "access_token": "string",
    "token_type": "bearer"
  }
  ```
- **Status Codes:** 
  - `200`: Успешная регистрация
  - `400`: Username уже зарегистрирован
- **Notes:** После регистрации пользователь автоматически получает токен доступа

---

### 2. Login
- **URL:** `POST /users/login`
- **Description:** Вход пользователя в систему
- **Request Body:**
  ```json
  {
    "name": "string",
    "password": "string",
    "status": "student" | "teacher"
  }
  ```
- **Response:**
  ```json
  {
    "access_token": "string",
    "token_type": "bearer"
  }
  ```
- **Status Codes:**
  - `200`: Успешный вход
  - `401`: Неправильное имя пользователя или пароль
- **Authentication:** Not required

---

### 3. Get Current User Info
- **URL:** `GET /users/me`
- **Description:** Получить информацию о текущем авторизованном пользователе
- **Headers:**
  ```
  Authorization: Bearer {access_token}
  ```
- **Response:**
  ```json
  {
    "id": "integer",
    "name": "string",
    "status": "student" | "teacher",
    "password": "string"
  }
  ```
- **Status Codes:**
  - `200`: Успешное получение информации
  - `401`: Не авторизован
- **Authentication:** Required (Bearer token)

---

## Test Management (Teacher Endpoints)

### 4. Get My Tests
- **URL:** `GET /tests`
- **Description:** Получить список всех тестов преподавателя (только для преподавателей)
- **Headers:**
  ```
  Authorization: Bearer {access_token}
  ```
- **Response:**
  ```json
  [
    {
      "id": "integer",
      "name": "string",
      "description": "string",
      "access_code": "string",
      "teacher_id": "integer",
      "questions": [
        {
          "id": "integer",
          "test_id": "integer",
          "text": "string",
          "type": "single" | "multiple",
          "question_order": "integer",
          "answers": [
            { "id": "integer", "question_id": "integer", "text": "string", "is_correct": boolean }
          ]
        }
      ]
    }
  ]
  ```
- **Status Codes:**
  - `200`: Список тестов успешно получен
  - `403`: Пользователь не является преподавателем
- **Authentication:** Required (Bearer token, only for teachers)

---

### 5. Create Test
- **URL:** `POST /tests`
- **Description:** Создать новый тест (только для преподавателей)
- **Headers:**
  ```
  Authorization: Bearer {access_token}
  ```
- **Request Body:**
  ```json
  {
    "name": "string",
    "description": "string"
  }
  ```
- **Response:**
  ```json
  {
    "id": "integer",
    "teacher_id": "integer",
    "name": "string",
    "description": "string",
    "access_code": "string"
  }
  ```
- **Status Codes:**
  - `200`: Тест успешно создан
  - `403`: Пользователь не является преподавателем
  - `500`: Ошибка при создании теста
- **Authentication:** Required (Bearer token, only for teachers)
- **Notes:** `access_code` генерируется автоматически на сервере (8 символов, уникальный) и возвращается в ответе

---

### 6. Add Question with Answers
- **URL:** `POST /tests/{test_id}/questions`
- **Description:** Добавить вопрос с вариантами ответов в существующий тест (только для преподавателей). При создании вопроса необходимо сразу указать варианты ответов и отметить правильный(е).
- **Headers:**
  ```
  Authorization: Bearer {access_token}
  ```
- **Path Parameters:**
  - `test_id` (integer): ID теста
- **Request Body:**
  ```json
  {
    "text": "string",
    "type": "single" | "multiple",
    "question_order": "integer",
    "answers": [
      { "text": "string", "is_correct": false },
      { "text": "string", "is_correct": true }
    ]
  }
  ```
- **Response:**
  ```json
  {
    "id": "integer",
    "test_id": "integer",
    "text": "string",
    "type": "string",
    "question_order": "integer",
    "answers": [
      { "id": "integer", "question_id": "integer", "text": "string", "is_correct": false },
      { "id": "integer", "question_id": "integer", "text": "string", "is_correct": true }
    ]
  }
  ```
- **Validation:**
  - Список `answers` не может быть пустым
  - Хотя бы один ответ должен иметь `is_correct: true`
- **Status Codes:**
  - `200`: Вопрос успешно добавлен
  - `403`: Пользователь не является преподавателем или не владеет тестом
  - `404`: Тест не найден
  - `422`: Ошибка валидации (нет ответов или ни один не отмечен как правильный)
- **Authentication:** Required (Bearer token, only for teachers)

---

### 7. Add Answer to Question
- **URL:** `POST /tests/{test_id}/questions/{question_id}/answers`
- **Description:** Добавить вариант ответа к вопросу (только для преподавателей)
- **Headers:**
  ```
  Authorization: Bearer {access_token}
  ```
- **Path Parameters:**
  - `test_id` (integer): ID теста
  - `question_id` (integer): ID вопроса
- **Request Body:**
  ```json
  {
    "text": "string",
    "is_correct": "boolean"
  }
  ```
- **Response:**
  ```json
  {
    "id": "integer",
    "question_id": "integer",
    "text": "string",
    "is_correct": "boolean"
  }
  ```
- **Status Codes:**
  - `200`: Ответ успешно добавлен
  - `403`: Пользователь не является преподавателем или не владеет тестом
  - `404`: Тест или вопрос не найден
- **Authentication:** Required (Bearer token, only for teachers)

---

### 8. Get Test Results
- **URL:** `GET /tests/{test_id}/results`
- **Description:** Получить результаты всех попыток студентов по тесту (только для преподавателя, который его создал)
- **Headers:**
  ```
  Authorization: Bearer {access_token}
  ```
- **Path Parameters:**
  - `test_id` (integer): ID теста
- **Response:**
  ```json
  [
    {
      "attempt_id": "integer",
      "student_id": "integer",
      "student_name": "string",
      "started_at": "datetime",
      "completed_at": "datetime",
      "total_questions": "integer",
      "correct_answers": "integer",
      "score": "number"
    }
  ]
  ```
- **Status Codes:**
  - `200`: Результаты успешно получены
  - `403`: Пользователь не является преподавателем
  - `404`: Тест не найден или не принадлежит преподавателю
- **Authentication:** Required (Bearer token, only for teachers)
- **Notes:** Возвращаются только завершённые попытки (с `completed_at` не null)

---

## Test Access (Student Endpoints)

### 9. Get Test by Access Code
- **URL:** `GET /tests/access?access_code={code}`
- **Description:** Получить тест по коду доступа (только для студентов)
- **Headers:**
  ```
  Authorization: Bearer {access_token}
  ```
- **Query Parameters:**
  - `access_code` (string, required): Код доступа к тесту
- **Response:**
  ```json
  {
    "id": "integer",
    "name": "string",
    "description": "string",
    "access_code": "string",
    "questions": [
      {
        "id": "integer",
        "text": "string",
        "type": "single" | "multiple",
        "question_order": "integer",
        "answers": [
          { "id": "integer", "text": "string" }
        ]
      }
    ]
  }
  ```
- **Status Codes:**
  - `200`: Тест успешно получен
  - `403`: Пользователь не является студентом
  - `404`: Тест с таким кодом доступа не найден
- **Authentication:** Required (Bearer token, only for students)
- **Notes:** Студент видит только текст вопросов и текст ответов, но НЕ видит какой ответ правильный (`is_correct` не возвращается)

---

### 10. Get Test by ID
- **URL:** `GET /tests/{test_id}`
- **Description:** Получить информацию о тесте по ID и его вопросы (только для студентов)
- **Headers:**
  ```
  Authorization: Bearer {access_token}
  ```
- **Path Parameters:**
  - `test_id` (integer): ID теста
- **Response:**
  ```json
  {
    "id": "integer",
    "name": "string",
    "description": "string",
    "access_code": "string",
    "questions": [
      {
        "id": "integer",
        "text": "string",
        "type": "single" | "multiple",
        "question_order": "integer",
        "answers": [
          { "id": "integer", "text": "string" }
        ]
      }
    ]
  }
  ```
- **Status Codes:**
  - `200`: Тест успешно получен
  - `404`: Тест не найден
- **Authentication:** Required (Bearer token)
- **Notes:** Студент видит только текст вопросов и текст ответов, но НЕ видит какой ответ правильный

---

## Test Attempts (Student Endpoints)

### 11. Start Test Attempt
- **URL:** `POST /tests/attempts`
- **Description:** Начать попытку прохождения теста (только для студентов)
- **Headers:**
  ```
  Authorization: Bearer {access_token}
  ```
- **Request Body:**
  ```json
  {
    "test_id": "integer"
  }
  ```
- **Response:**
  ```json
  {
    "id": "integer",
    "student_id": "integer",
    "test_id": "integer",
    "started_at": "datetime",
    "completed_at": "datetime or null"
  }
  ```
- **Status Codes:**
  - `200`: Попытка успешно начата
  - `403`: Пользователь не является студентом
  - `404`: Тест не найден
- **Authentication:** Required (Bearer token, only for students)

---

### 12. Submit Answers
- **URL:** `POST /tests/attempts/{attempt_id}/answers`
- **Description:** Отправить ответы на вопросы теста (только для студентов)
- **Headers:**
  ```
  Authorization: Bearer {access_token}
  ```
- **Path Parameters:**
  - `attempt_id` (integer): ID попытки
- **Request Body:**
  ```json
  {
    "answers": [
      {
        "question_id": "integer",
        "answer_id": "integer"
      }
    ]
  }
  ```
- **Response:**
  ```json
  {
    "message": "Answers submitted"
  }
  ```
- **Status Codes:**
  - `200`: Ответы успешно отправлены
  - `403`: Пользователь не является студентом
  - `404`: Попытка не найдена или не принадлежит пользователю
- **Authentication:** Required (Bearer token, only for students)

---

### 13. Complete Test
- **URL:** `POST /tests/attempts/{attempt_id}/complete`
- **Description:** Завершить тест и получить результаты (только для студентов)
- **Headers:**
  ```
  Authorization: Bearer {access_token}
  ```
- **Path Parameters:**
  - `attempt_id` (integer): ID попытки
- **Response:**
  ```json
  {
    "attempt_id": "integer",
    "total_questions": "integer",
    "correct_answers": "integer",
    "score": "number"
  }
  ```
- **Status Codes:**
  - `200`: Тест успешно завершен и результаты получены
  - `403`: Пользователь не является студентом
  - `404`: Попытка не найдена или не принадлежит пользователю
- **Authentication:** Required (Bearer token, only for students)

---

## Error Responses

Все endpoints могут возвращать следующие ошибки:

- **401 Unauthorized:** Отсутствует или недействителен токен доступа
  ```json
  {
    "detail": "Не авторизован"
  }
  ```

- **403 Forbidden:** Пользователь не имеет прав для выполнения операции
  ```json
  {
    "detail": "Только [студент/преподаватель] может [действие]"
  }
  ```

- **404 Not Found:** Ресурс не найден
  ```json
  {
    "detail": "[Ресурс] не найден"
  }
  ```

- **500 Internal Server Error:** Ошибка сервера
  ```json
  {
    "detail": "Failed to [действие]: [описание ошибки]"
  }
  ```

---

## Authentication

Все endpoints, кроме `/users/register` и `/users/login`, требуют авторизации.

**Способ передачи токена:**
```
Authorization: Bearer {access_token}
```

Токен получается при регистрации или входе и действует в течение времени, установленного в `ACCESS_TOKEN_EXPIRE_MINUTES`.
