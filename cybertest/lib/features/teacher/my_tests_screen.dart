import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/test_provider.dart';

class MyTestsScreen extends ConsumerStatefulWidget {
  const MyTestsScreen({super.key});

  @override
  ConsumerState<MyTestsScreen> createState() => _MyTestsScreenState();
}

class _MyTestsScreenState extends ConsumerState<MyTestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myTestsProvider.notifier).loadMyTests();
    });
  }

  Future<void> _refresh() async {
    await ref.read(myTestsProvider.notifier).loadMyTests();
  }

  @override
  Widget build(BuildContext context) {
    final testsState = ref.watch(myTestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои тесты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Обновить',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/create-test');
          _refresh();
        },
        icon: const Icon(Icons.add),
        label: const Text('Создать тест'),
      ),
      body: testsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Ошибка: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refresh,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
        data: (tests) {
          if (tests.isEmpty) {
            final theme = Theme.of(context);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined, size: 64, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    'У вас пока нет тестов',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Нажмите "Создать тест" чтобы начать',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16).copyWith(bottom: 80),
              itemCount: tests.length,
              itemBuilder: (context, index) {
                final test = tests[index];
                final questionCount = test.questions?.length ?? 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Название теста
                        Text(
                          test.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (test.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            test.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 12),

                        // Код доступа
                        Row(
                          children: [
                            Icon(Icons.key, size: 16, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 6),
                            const Text('Код доступа: '),
                            Text(
                              test.accessCode,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: test.accessCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Код скопирован')),
                                );
                              },
                              child: Icon(Icons.copy, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Количество вопросов
                        Row(
                          children: [
                            Icon(Icons.help_outline, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text(
                              'Вопросов: $questionCount',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Кнопки действий
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/edit-test', arguments: test.id),
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Редактировать'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/test-results-teacher',
                                  arguments: {'testId': test.id, 'testName': test.name},
                                ),
                                icon: const Icon(Icons.bar_chart, size: 18),
                                label: const Text('Результаты'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
