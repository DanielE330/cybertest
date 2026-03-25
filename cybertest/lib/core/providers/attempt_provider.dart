import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/test_api_service.dart';
import '../models/test_attempt.dart';
import '../models/test_result.dart';
import 'test_provider.dart';

final attemptProvider = StateNotifierProvider<AttemptNotifier, AsyncValue<TestAttempt?>>((ref) {
  final service = ref.watch(testApiServiceProvider);
  return AttemptNotifier(service);
});

class AttemptNotifier extends StateNotifier<AsyncValue<TestAttempt?>> {
  final TestApiService _service;

  AttemptNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> startAttempt(int testId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.startAttempt(testId));
  }

  Future<void> submitAnswers(int attemptId, List<AttemptAnswer> answers) async {
    await AsyncValue.guard(() => _service.submitAnswers(attemptId, answers));
  }

  Future<TestResult> completeTest(int attemptId) async {
    return await _service.completeTest(attemptId);
  }
}