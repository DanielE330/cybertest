import 'package:flutter/material.dart';
import '../../core/models/test_result.dart';

class TestResultScreen extends StatelessWidget {
  final TestResult result;

  const TestResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Результат теста')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Оценка: ${result.score}%',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              Text('Всего вопросов: ${result.totalQuestions}',
                  style: theme.textTheme.bodyLarge),
              Text('Правильных ответов: ${result.correctAnswers}',
                  style: theme.textTheme.bodyLarge),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/dashboard'),
                child: const Text('На главную'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}