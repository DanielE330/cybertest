import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/test.dart';
import '../../core/models/question.dart';
import '../../core/models/test_attempt.dart';
import '../../core/providers/attempt_provider.dart';

class TakeTestScreen extends ConsumerStatefulWidget {
  final Test test;

  const TakeTestScreen({super.key, required this.test});

  @override
  ConsumerState<TakeTestScreen> createState() => _TakeTestScreenState();
}

class _TakeTestScreenState extends ConsumerState<TakeTestScreen> {
  TestAttempt? _attempt;
  Map<int, List<int>> _selectedAnswers = {}; // questionId -> list of answerIds
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Загрузка попытки после первого frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAttempt();
    });
  }

  Future<void> _startAttempt() async {
    await ref.read(attemptProvider.notifier).startAttempt(widget.test.id!);
    final attemptState = ref.read(attemptProvider);
    if (attemptState.hasValue && attemptState.value != null) {
      setState(() => _attempt = attemptState.value);
    }
  }

  void _onAnswerSelected(int questionId, int answerId, bool isMultiple) {
    setState(() {
      if (isMultiple) {
        _selectedAnswers[questionId] ??= [];
        if (_selectedAnswers[questionId]!.contains(answerId)) {
          _selectedAnswers[questionId]!.remove(answerId);
        } else {
          _selectedAnswers[questionId]!.add(answerId);
        }
      } else {
        _selectedAnswers[questionId] = [answerId];
      }
    });
  }

  Future<void> _submitTest() async {
    if (_attempt == null) return;

    setState(() => _isSubmitting = true);

    final answers = _selectedAnswers.entries
        .expand((entry) => entry.value.map((answerId) => AttemptAnswer(
              questionId: entry.key,
              answerId: answerId,
            )))
        .toList();

    await ref.read(attemptProvider.notifier).submitAnswers(_attempt!.id, answers);

    final result = await ref.read(attemptProvider.notifier).completeTest(_attempt!.id);

    setState(() => _isSubmitting = false);

    Navigator.of(context).pushReplacementNamed('/test-result', arguments: result);
  }

  @override
  Widget build(BuildContext context) {
    if (_attempt == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    List<Question> questions = widget.test.questions ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(widget.test.name)),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ...questions.map((question) {
                  final isMultiple = question.type == QuestionType.multipleAnswer;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(question.text, style: Theme.of(context).textTheme.titleMedium),
                          ...question.answers!.map((answer) {
                            final isSelected = _selectedAnswers[question.id]?.contains(answer.id) ?? false;
                            return ListTile(
                              title: Text(answer.text),
                              leading: isMultiple
                                  ? Checkbox(
                                      value: isSelected,
                                      onChanged: (value) => _onAnswerSelected(question.id!, answer.id!, true),
                                    )
                                  : Radio<int>(
                                      value: answer.id!,
                                      groupValue: _selectedAnswers[question.id]?.first,
                                      onChanged: (value) => _onAnswerSelected(question.id!, value!, false),
                                    ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }),
                ElevatedButton(
                  onPressed: _submitTest,
                  child: const Text('Отправить тест'),
                ),
              ],
            ),
    );
  }
}