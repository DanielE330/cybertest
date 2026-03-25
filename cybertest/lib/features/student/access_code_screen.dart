import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/test_provider.dart';

class AccessCodeScreen extends ConsumerStatefulWidget {
  const AccessCodeScreen({super.key});

  @override
  ConsumerState<AccessCodeScreen> createState() => _AccessCodeScreenState();
}

class _AccessCodeScreenState extends ConsumerState<AccessCodeScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _accessTest() async {
    if (_controller.text.isEmpty) return;

    await ref.read(testProvider.notifier).getTestByAccessCode(_controller.text);

    final test = ref.read(testProvider);
    if (test.hasValue && test.value != null) {
      Navigator.of(context).pushNamed('/take-test', arguments: test.value);
    } else if (test.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${test.error}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final testState = ref.watch(testProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Введите код доступа')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Код доступа'),
            ),
            const SizedBox(height: 20),
            testState.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _accessTest,
                    child: const Text('Получить доступ'),
                  ),
          ],
        ),
      ),
    );
  }
}