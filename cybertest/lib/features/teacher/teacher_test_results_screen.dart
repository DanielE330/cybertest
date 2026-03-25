import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/student_attempt_result.dart';
import '../../core/providers/test_provider.dart';
import '../../theme/app_colors.dart';

enum _SortBy { score, name, date }

class TeacherTestResultsScreen extends ConsumerStatefulWidget {
  final int testId;
  final String testName;

  const TeacherTestResultsScreen({
    super.key,
    required this.testId,
    required this.testName,
  });

  @override
  ConsumerState<TeacherTestResultsScreen> createState() =>
      _TeacherTestResultsScreenState();
}

class _TeacherTestResultsScreenState
    extends ConsumerState<TeacherTestResultsScreen> {
  _SortBy _sortBy = _SortBy.date;
  bool _sortDescending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(testResultsProvider.notifier).loadResults(widget.testId);
    });
  }

  List<StudentAttemptResult> _sortedResults(List<StudentAttemptResult> results) {
    final sorted = List<StudentAttemptResult>.from(results);
    sorted.sort((a, b) {
      int cmp;
      switch (_sortBy) {
        case _SortBy.score:
          cmp = a.score.compareTo(b.score);
          break;
        case _SortBy.name:
          cmp = a.studentName.compareTo(b.studentName);
          break;
        case _SortBy.date:
          cmp = a.completedAt.compareTo(b.completedAt);
          break;
      }
      return _sortDescending ? -cmp : cmp;
    });
    return sorted;
  }

  Color _scoreColor(double score) {
    if (score >= 80) return RtColors.success;
    if (score >= 60) return RtColors.warning;
    return RtColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final resultsState = ref.watch(testResultsProvider);

    String formatDate(DateTime dt) {
      return '${dt.day.toString().padLeft(2, '0')}.'
          '${dt.month.toString().padLeft(2, '0')}.'
          '${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Результаты: ${widget.testName}'),
        actions: [
          PopupMenuButton<_SortBy>(
            icon: const Icon(Icons.sort),
            tooltip: 'Сортировка',
            onSelected: (value) {
              setState(() {
                if (_sortBy == value) {
                  _sortDescending = !_sortDescending;
                } else {
                  _sortBy = value;
                  _sortDescending = true;
                }
              });
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: _SortBy.score, child: Text('По оценке')),
              const PopupMenuItem(value: _SortBy.name, child: Text('По имени')),
              const PopupMenuItem(value: _SortBy.date, child: Text('По дате')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(testResultsProvider.notifier).loadResults(widget.testId),
          ),
        ],
      ),
      body: resultsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Ошибка: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(testResultsProvider.notifier)
                    .loadResults(widget.testId),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
        data: (results) {
          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    'Результатов пока нет',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Студенты ещё не прошли этот тест',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final sorted = _sortedResults(results);
          final avgScore = results.map((r) => r.score).reduce((a, b) => a + b) /
              results.length;

          return Column(
            children: [
              // Статистика сверху
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatChip(
                      label: 'Всего попыток',
                      value: results.length.toString(),
                      icon: Icons.people,
                    ),
                    _StatChip(
                      label: 'Средняя оценка',
                      value: '${avgScore.toStringAsFixed(1)}%',
                      icon: Icons.analytics,
                      color: _scoreColor(avgScore),
                    ),
                  ],
                ),
              ),
              // Список результатов
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: sorted.length,
                  itemBuilder: (context, index) {
                    final r = sorted[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _scoreColor(r.score).withValues(alpha: 0.15),
                          child: Text(
                            '${r.score.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: _scoreColor(r.score),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        title: Text(
                          r.studentName,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Правильно: ${r.correctAnswers} из ${r.totalQuestions}',
                            ),
                            Text(
                              formatDate(r.completedAt),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _scoreColor(r.score),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${r.score.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color ?? theme.colorScheme.primary, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color ?? theme.colorScheme.primary,
          ),
        ),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
