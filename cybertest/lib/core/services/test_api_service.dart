import 'package:dio/dio.dart';
import '../models/test.dart';
import '../models/question.dart';
import '../models/answer.dart';
import '../models/test_attempt.dart';
import '../models/test_result.dart';
import '../models/student_attempt_result.dart';
import 'api_client.dart';

class AnswerOption {
  final String text;
  final bool isCorrect;

  AnswerOption({required this.text, required this.isCorrect});

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'is_correct': isCorrect,
    };
  }
}

class TestApiService {
  final ApiClient _apiClient;

  TestApiService(this._apiClient);

  // GET /tests — список тестов преподавателя
  Future<List<Test>> getMyTests() async {
    try {
      print('[TEST] 📋 Загружаю список тестов преподавателя');
      final response = await _apiClient.dio.get('/tests');
      print('[TEST] ✅ Список тестов загружен: ${(response.data as List).length} шт.');
      return (response.data as List).map((t) => Test.fromJson(t)).toList();
    } on DioException catch (e) {
      print('[TEST] ❌ Ошибка загрузки списка тестов: ${_handleError(e)}');
      throw _handleError(e);
    }
  }

  // POST /tests — создать тест
  Future<Test> createTest({
    required String name,
    required String description,
  }) async {
    try {
      print('[TEST] 📋 Создаю тест: "$name"');
      final response = await _apiClient.dio.post('/tests', data: {
        'name': name,
        'description': description,
      });
      print('[TEST] ✅ Тест создан успешно, ID: ${response.data['id']}');
      return Test.fromJson(response.data);
    } on DioException catch (e) {
      print('[TEST] ❌ Ошибка создания теста: ${_handleError(e)}');
      throw _handleError(e);
    }
  }

  // POST /tests/{testId}/questions — добавить вопрос С ответами (одним запросом)
  Future<Question> addQuestionWithAnswers({
    required int testId,
    required String questionText,
    required String questionType,
    required int questionOrder,
    required List<AnswerOption> answers,
  }) async {
    try {
      final hasCorrect = answers.any((a) => a.isCorrect);
      if (!hasCorrect) {
        throw Exception('Хотя бы один ответ должен быть правильным');
      }

      print('[TEST] 📝 Добавляю вопрос с ${answers.length} ответами в тест $testId');
      final response = await _apiClient.dio.post(
        '/tests/$testId/questions',
        data: {
          'text': questionText,
          'type': questionType,
          'question_order': questionOrder,
          'answers': answers.map((a) => a.toJson()).toList(),
        },
      );
      print('[TEST] ✅ Вопрос добавлен, ID: ${response.data['id']}');
      return Question.fromJson(response.data);
    } on DioException catch (e) {
      print('[TEST] ❌ Ошибка при добавлении вопроса: ${_handleError(e)}');
      throw _handleError(e);
    }
  }

  // POST /tests/{testId}/questions/{questionId}/answers — добавить ответ к вопросу
  Future<Answer> addAnswer({
    required int testId,
    required int questionId,
    required String text,
    required bool isCorrect,
  }) async {
    try {
      print('[TEST] 📌 Добавляю ответ к вопросу $questionId: "$text"');
      final response = await _apiClient.dio.post(
        '/tests/$testId/questions/$questionId/answers',
        data: {
          'text': text,
          'is_correct': isCorrect,
        },
      );
      print('[TEST] ✅ Ответ добавлен, ID: ${response.data['id']}');
      return Answer.fromJson(response.data);
    } on DioException catch (e) {
      print('[TEST] ❌ Ошибка при добавлении ответа: ${_handleError(e)}');
      throw _handleError(e);
    }
  }

  // GET /tests/{testId}/results — результаты студентов по тесту
  Future<List<StudentAttemptResult>> getTestResults(int testId) async {
    try {
      print('[TEST] 📊 Загружаю результаты теста $testId');
      final response = await _apiClient.dio.get('/tests/$testId/results');
      print('[TEST] ✅ Результаты загружены: ${(response.data as List).length} попыток');
      return (response.data as List)
          .map((r) => StudentAttemptResult.fromJson(r))
          .toList();
    } on DioException catch (e) {
      print('[TEST] ❌ Ошибка загрузки результатов: ${_handleError(e)}');
      throw _handleError(e);
    }
  }

  // GET /tests/{testId} — тест по ID
  Future<Test> getTestById(int testId) async {
    try {
      print('[TEST] 🔍 Загружаю тест с ID: $testId');
      final response = await _apiClient.dio.get('/tests/$testId');
      print('[TEST] ✅ Тест загружен успешно');
      print('[TEST] 📦 RAW response.data: ${response.data}');
      print('[TEST] 📦 response.data type: ${response.data.runtimeType}');
      final data = response.data;
      if (data is Map) {
        print('[TEST] 🔑 Ключи ответа: ${data.keys.toList()}');
        print('[TEST] ❓ questions присутствует: ${data.containsKey("questions")}');
        if (data.containsKey('questions')) {
          print('[TEST] 📋 questions тип: ${data["questions"].runtimeType}');
          print('[TEST] 📋 questions значение: ${data["questions"]}');
        }
      }
      return Test.fromJson(response.data);
    } on DioException catch (e) {
      print('[TEST] ❌ Ошибка загрузки теста (ID: $testId): ${_handleError(e)}');
      throw _handleError(e);
    }
  }

  // GET /tests/access?access_code={code} — тест по коду доступа
  Future<Test> getTestByAccessCode(String accessCode) async {
    try {
      print('[TEST] 🔑 Загружаю тест по коду: $accessCode');
      final response = await _apiClient.dio.get('/tests/access', queryParameters: {
        'access_code': accessCode,
      });
      print('[TEST] ✅ Тест по коду доступа загружен');
      return Test.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST /tests/attempts — начать попытку
  Future<TestAttempt> startAttempt(int testId) async {
    try {
      print('[TEST] 🚀 Начинаю попытку для теста $testId');
      final response = await _apiClient.dio.post('/tests/attempts', data: {
        'test_id': testId,
      });
      print('[TEST] ✅ Попытка создана, ID: ${response.data['id']}');
      return TestAttempt.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST /tests/attempts/{attemptId}/answers — отправить ответы
  Future<void> submitAnswers(int attemptId, List<AttemptAnswer> answers) async {
    try {
      print('[TEST] 📤 Отправляю ${answers.length} ответов для попытки $attemptId');
      await _apiClient.dio.post('/tests/attempts/$attemptId/answers', data: {
        'answers': answers.map((a) => a.toJson()).toList(),
      });
      print('[TEST] ✅ Ответы отправлены');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST /tests/attempts/{attemptId}/complete — завершить тест
  Future<TestResult> completeTest(int attemptId) async {
    try {
      print('[TEST] 🏁 Завершаю попытку $attemptId');
      final response = await _apiClient.dio.post('/tests/attempts/$attemptId/complete');
      print('[TEST] ✅ Тест завершён, результат: ${response.data}');
      return TestResult.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    final detail = e.response?.data is Map ? e.response?.data['detail'] : null;
    if (e.response?.statusCode == 401) {
      return Exception('Не авторизован. Пожалуйста, войдите снова');
    } else if (e.response?.statusCode == 403) {
      return Exception(detail ?? 'Нет прав для выполнения операции');
    } else if (e.response?.statusCode == 404) {
      return Exception(detail ?? 'Ресурс не найден');
    } else if (e.response?.statusCode == 422) {
      return Exception(detail ?? 'Ошибка валидации данных');
    } else if (e.response?.statusCode == 500) {
      return Exception('Ошибка сервера. Попробуйте позже');
    } else {
      return Exception('Ошибка сети: ${e.message}');
    }
  }
}
