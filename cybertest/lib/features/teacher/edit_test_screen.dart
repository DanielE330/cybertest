import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/question.dart';
import '../../core/models/answer.dart';
import '../../core/providers/test_provider.dart';
import '../../core/services/test_api_service.dart';
import '../../theme/app_colors.dart';

class EditTestScreen extends ConsumerStatefulWidget {
  final int testId;

  const EditTestScreen({super.key, required this.testId});

  @override
  ConsumerState<EditTestScreen> createState() => _EditTestScreenState();
}

class _EditTestScreenState extends ConsumerState<EditTestScreen> {
  @override
  void initState() {
    super.initState();
    // Загрузка теста после первого frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(testProvider.notifier).loadTestById(widget.testId);
      // Добавляем/обновляем тест в кэше MyTestsScreen
      final loadedTest = ref.read(testProvider).value;
      if (loadedTest != null) {
        ref.read(myTestsProvider.notifier).updateTestInCache(loadedTest);
      }
    });
  }

  Future<void> _refreshTest() async {
    await ref.read(testProvider.notifier).loadTestById(widget.testId);
    // Обновляем тест в кэше MyTestsScreen (вопросы и их кол-во)
    final updatedTest = ref.read(testProvider).value;
    if (updatedTest != null) {
      ref.read(myTestsProvider.notifier).updateTestInCache(updatedTest);
    }
  }

  void _showAddQuestionDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AddQuestionDialog(
        testId: widget.testId,
        questionOrder:
            (ref.read(testProvider).value?.questions?.length ?? 0) + 1,
        onSuccess: _refreshTest,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final testState = ref.watch(testProvider);

    return testState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          Scaffold(body: Center(child: Text('Ошибка загрузки: $error'))),
      data: (test) {
        if (test == null) {
          return const Scaffold(body: Center(child: Text('Тест не найден')));
        }

        final questions = test.questions ?? [];

        return Scaffold(
          appBar: AppBar(
            title: Text(test.name),
            elevation: 0,
          ),
          body: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Информация о тесте
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                test.description,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Вопросов: ${questions.length}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Список вопросов
                      if (questions.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              'Нет вопросов. Нажмите "Добавить вопрос"',
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        ...questions
                            .asMap()
                            .entries
                            .map((entry) => _QuestionCard(
                                  testId: widget.testId,
                                  question: entry.value,
                                  questionIndex: entry.key + 1,
                                  onRefresh: _refreshTest,
                                ))
                            .toList(),

                      const SizedBox(height: 24),

                      // Кнопка добавление вопроса
                      ElevatedButton.icon(
                        onPressed: _showAddQuestionDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Добавить вопрос'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _AddQuestionDialog extends ConsumerStatefulWidget {
  final int testId;
  final int questionOrder;
  final VoidCallback onSuccess;

  const _AddQuestionDialog({
    required this.testId,
    required this.questionOrder,
    required this.onSuccess,
  });

  @override
  ConsumerState<_AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AnswerDraft {
  final TextEditingController controller;
  bool isCorrect = false;

  _AnswerDraft() : controller = TextEditingController();

  void dispose() => controller.dispose();
}

class _AddQuestionDialogState extends ConsumerState<_AddQuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  QuestionType _selectedType = QuestionType.multipleChoice;
  late int _questionOrder;
  bool _isLoading = false;
  final List<_AnswerDraft> _answers = [];

  @override
  void initState() {
    super.initState();
    _questionOrder = widget.questionOrder;
    // По умолчанию 2 варианта ответа
    _answers.add(_AnswerDraft());
    _answers.add(_AnswerDraft());
  }

  @override
  void dispose() {
    _textController.dispose();
    for (final a in _answers) {
      a.dispose();
    }
    super.dispose();
  }

  void _addAnswerField() {
    setState(() => _answers.add(_AnswerDraft()));
  }

  void _removeAnswerField(int index) {
    if (_answers.length <= 2) return;
    setState(() {
      _answers[index].dispose();
      _answers.removeAt(index);
    });
  }

  Future<void> _addQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    // Проверка: хотя бы один правильный ответ
    final hasCorrect = _answers.any((a) => a.isCorrect);
    if (!hasCorrect) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Отметьте хотя бы один правильный ответ')),
      );
      return;
    }

    // Проверка: все поля ответов заполнены
    final allFilled = _answers.every((a) => a.controller.text.trim().isNotEmpty);
    if (!allFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Заполните текст всех вариантов ответа')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(testApiServiceProvider);
      final answerOptions = _answers
          .map((a) => AnswerOption(text: a.controller.text.trim(), isCorrect: a.isCorrect))
          .toList();

      final question = await service.addQuestionWithAnswers(
        testId: widget.testId,
        questionText: _textController.text.trim(),
        questionType: _selectedType.apiValue,
        questionOrder: _questionOrder,
        answers: answerOptions,
      );

      if (mounted) {
        // Добавляем вопрос локально — сервер не возвращает questions в GET /tests/{id}
        ref.read(testProvider.notifier).addQuestionLocally(question);
        // Обновляем кэш MyTestsScreen (счётчик вопросов)
        final updatedTest = ref.read(testProvider).value;
        if (updatedTest != null) {
          ref.read(myTestsProvider.notifier).updateTestInCache(updatedTest);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Вопрос успешно добавлен')),
        );
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Добавить вопрос'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Текст вопроса
                TextFormField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    labelText: 'Текст вопроса',
                    hintText: 'Введите текст вопроса',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Введите текст вопроса';
                    if (value!.length < 5) return 'Минимум 5 символов';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Тип вопроса
                DropdownButtonFormField<QuestionType>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Тип вопроса',
                    border: OutlineInputBorder(),
                  ),
                  items: [QuestionType.multipleChoice, QuestionType.multipleAnswer]
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.displayName),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedType = value);
                  },
                ),
                const SizedBox(height: 20),

                // Заголовок секции ответов
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Варианты ответов',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '(мин: 2)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Динамический список ответов
                ..._answers.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final draft = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                      color: draft.isCorrect
                          ? RtColors.success.withAlpha(30)
                          : null,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: draft.isCorrect,
                          activeColor: RtColors.success,
                          onChanged: (v) =>
                              setState(() => draft.isCorrect = v ?? false),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: draft.controller,
                            decoration: InputDecoration(
                              hintText: 'Вариант ответа ${idx + 1}',
                              isDense: true,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (_answers.length > 2)
                          IconButton(
                            icon: Icon(Icons.close, size: 18, color: Theme.of(context).colorScheme.error),
                            onPressed: () => _removeAnswerField(idx),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                  );
                }),

                // Кнопка "Добавить вариант"
                TextButton.icon(
                  onPressed: _addAnswerField,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Добавить вариант ответа'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addQuestion,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Сохранить'),
        ),
      ],
    );
  }
}

class _QuestionCard extends ConsumerWidget {
  final int testId;
  final Question question;
  final int questionIndex;
  final VoidCallback onRefresh;

  const _QuestionCard({
    required this.testId,
    required this.question,
    required this.questionIndex,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = question.answers ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок вопроса
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Q$questionIndex',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.text,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Тип вопроса
            Text(
              'Тип: ${question.type.displayName}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),

            // Список ответов
            if (answers.isEmpty)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Нет ответов',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: answers
                    .asMap()
                    .entries
                    .map((entry) => _AnswerItem(answer: entry.value))
                    .toList(),
              ),

            const SizedBox(height: 12),

            // Кнопка добавления ответа
            ElevatedButton.icon(
              onPressed: () => _showAddAnswerDialog(
                context,
                ref,
                question.id!,
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Добавить ответ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: RtColors.success,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAnswerDialog(
    BuildContext context,
    WidgetRef ref,
    int questionId,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => _AddAnswerDialog(
        testId: testId,
        questionId: questionId,
        onSuccess: onRefresh,
      ),
    );
  }
}

class _AnswerItem extends StatelessWidget {
  final Answer answer;

  const _AnswerItem({required this.answer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: answer.isCorrect
            ? RtColors.success.withAlpha(30)
            : colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: answer.isCorrect
              ? RtColors.success.withAlpha(120)
              : colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: answer.isCorrect ? RtColors.success : colorScheme.onSurfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              answer.isCorrect ? Icons.check : Icons.close,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              answer.text,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          if (answer.isCorrect)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: RtColors.success,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Правильный',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddAnswerDialog extends ConsumerStatefulWidget {
  final int testId;
  final int questionId;
  final VoidCallback onSuccess;

  const _AddAnswerDialog({
    required this.testId,
    required this.questionId,
    required this.onSuccess,
  });

  @override
  ConsumerState<_AddAnswerDialog> createState() => _AddAnswerDialogState();
}

class _AddAnswerDialogState extends ConsumerState<_AddAnswerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  bool _isCorrect = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _addAnswer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(testApiServiceProvider);
      final answer = await service.addAnswer(
        testId: widget.testId,
        questionId: widget.questionId,
        text: _textController.text.trim(),
        isCorrect: _isCorrect,
      );

      if (mounted) {
        // Добавляем ответ локально — без перезагрузки с сервера
        ref.read(testProvider.notifier).addAnswerLocally(widget.questionId, answer);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Ответ успешно добавлен')),
        );
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Добавить ответ'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Текст ответа
              TextFormField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Текст ответа',
                  hintText: 'Введите вариант ответа',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Введите текст ответа';
                  }
                  if (value!.length > 200) {
                    return 'Максимум 200 символов';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Чекбокс правильного ответа
              CheckboxListTile(
                value: _isCorrect,
                onChanged: (value) {
                  setState(() => _isCorrect = value ?? false);
                },
                title: const Text('Это правильный ответ'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addAnswer,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Добавить'),
        ),
      ],
    );
  }
}
