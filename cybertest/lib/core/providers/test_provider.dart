import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/test_api_service.dart';
import '../models/test.dart';
import '../models/question.dart';
import '../models/answer.dart';
import '../models/student_attempt_result.dart';
import 'auth_provider.dart';

final testApiServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TestApiService(apiClient);
});

final testProvider = StateNotifierProvider<TestNotifier, AsyncValue<Test?>>((ref) {
  final service = ref.watch(testApiServiceProvider);
  return TestNotifier(service);
});

class TestNotifier extends StateNotifier<AsyncValue<Test?>> {
  final TestApiService _service;

  TestNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> createTest({
    required String name,
    required String description,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.createTest(
          name: name,
          description: description,
        ));
  }

  Future<void> getTestByAccessCode(String accessCode) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.getTestByAccessCode(accessCode));
  }

  Future<void> loadTestById(int testId) async {
    // Сохраняем локальные вопросы перед перезагрузкой (сервер их не возвращает)
    final previousQuestions = state.value?.id == testId
        ? state.value?.questions
        : null;

    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() => _service.getTestById(testId));

    // Если сервер вернул тест без вопросов, но у нас есть локальные — восстанавливаем
    if (result.hasValue && result.value != null) {
      final test = result.value!;
      final serverQuestions = test.questions;
      final hasServerQuestions = serverQuestions != null && serverQuestions.isNotEmpty;
      final hasLocalQuestions = previousQuestions != null && previousQuestions.isNotEmpty;

      if (!hasServerQuestions && hasLocalQuestions) {
        print('[TEST_PROVIDER] ℹ️ Сервер не вернул вопросы — восстанавливаем ${previousQuestions.length} локальных');
        state = AsyncValue.data(Test(
          id: test.id,
          name: test.name,
          description: test.description,
          accessCode: test.accessCode,
          teacherId: test.teacherId,
          questions: previousQuestions,
        ));
        return;
      }
    }
    state = result;
  }

  /// Добавляет вопрос в локальное состояние (без запроса к серверу)
  void addQuestionLocally(Question? question) {
    if (question == null) return;
    final current = state.value;
    if (current == null) return;
    final List<Question> questions = [...(current.questions ?? []), question];
    state = AsyncValue.data(Test(
      id: current.id,
      name: current.name,
      description: current.description,
      accessCode: current.accessCode,
      teacherId: current.teacherId,
      questions: questions,
    ));
    print('[TEST_PROVIDER] ✅ Вопрос добавлен локально: id=${question.id}, всего вопросов: ${questions.length}');
  }

  /// Добавляет ответ к вопросу локально
  void addAnswerLocally(int questionId, Answer answer) {
    final current = state.value;
    if (current == null) return;
    final List<Question> questions = (current.questions ?? []).map((q) {
      if (q.id == questionId) {
        final List<Answer> updatedAnswers = [...(q.answers ?? []), answer];
        return Question(
          id: q.id,
          text: q.text,
          type: q.type,
          questionOrder: q.questionOrder,
          answers: updatedAnswers,
        );
      }
      return q;
    }).toList();
    state = AsyncValue.data(Test(
      id: current.id,
      name: current.name,
      description: current.description,
      accessCode: current.accessCode,
      teacherId: current.teacherId,
      questions: questions,
    ));
    print('[TEST_PROVIDER] ✅ Ответ добавлен локально: questionId=$questionId, answerId=${answer.id}');
  }
}

// Провайдер для списка тестов преподавателя
final myTestsProvider = StateNotifierProvider<MyTestsNotifier, AsyncValue<List<Test>>>((ref) {
  final service = ref.watch(testApiServiceProvider);
  return MyTestsNotifier(service);
});

class MyTestsNotifier extends StateNotifier<AsyncValue<List<Test>>> {
  final TestApiService _service;

  MyTestsNotifier(this._service) : super(const AsyncValue.data([]));

  Future<void> loadMyTests() async {
    // Сохраняем текущие данные, чтобы не терять кэш при перезагрузке
    final cachedTests = state.value ?? [];
    state = const AsyncValue.loading();
    try {
      final tests = await _service.getMyTests();
      state = AsyncValue.data(tests);
    } catch (e) {
      // GET /tests не реализован на бэкенде — показываем кэшированные тесты
      print('[MY_TESTS] ⚠️ Сервер не вернул список тестов, используем кэш (${cachedTests.length} шт.)');
      if (cachedTests.isNotEmpty) {
        state = AsyncValue.data(cachedTests);
      } else {
        state = AsyncValue.data([]);
      }
    }
  }

  /// Добавляет тест в локальный кэш (при создании нового теста)
  void addTestToCache(Test test) {
    final current = state.value ?? [];
    final exists = current.any((t) => t.id == test.id);
    if (!exists) {
      state = AsyncValue.data([...current, test]);
      print('[MY_TESTS] ✅ Тест добавлен в кэш: id=${test.id}, name=${test.name}');
    }
  }

  /// Обновляет тест в локальном кэше (после добавления вопросов)
  void updateTestInCache(Test test) {
    final current = state.value ?? [];
    final idx = current.indexWhere((t) => t.id == test.id);
    if (idx >= 0) {
      final updated = List<Test>.from(current);
      updated[idx] = test;
      state = AsyncValue.data(updated);
      print('[MY_TESTS] 🔄 Тест обновлён в кэше: id=${test.id}, вопросов=${test.questions?.length ?? 0}');
    } else {
      // Если теста нет в кэше — добавляем
      state = AsyncValue.data([...current, test]);
      print('[MY_TESTS] ✅ Тест добавлен в кэш при обновлении: id=${test.id}');
    }
  }
}

// Провайдер для результатов студентов по тесту
final testResultsProvider =
    StateNotifierProvider<TestResultsNotifier, AsyncValue<List<StudentAttemptResult>>>((ref) {
  final service = ref.watch(testApiServiceProvider);
  return TestResultsNotifier(service);
});

class TestResultsNotifier extends StateNotifier<AsyncValue<List<StudentAttemptResult>>> {
  final TestApiService _service;

  TestResultsNotifier(this._service) : super(const AsyncValue.data([]));

  Future<void> loadResults(int testId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.getTestResults(testId));
  }
}