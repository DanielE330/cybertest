import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/test_provider.dart';

class CreateTestScreen extends ConsumerStatefulWidget {
  const CreateTestScreen({super.key});

  @override
  ConsumerState<CreateTestScreen> createState() => _CreateTestScreenState();
}

class _CreateTestScreenState extends ConsumerState<CreateTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createTest() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(testProvider.notifier).createTest(
      name: _nameController.text,
      description: _descriptionController.text,
    );

    final test = ref.read(testProvider);
    if (test.hasValue && test.value != null) {
      final created = test.value!;
      print('[CREATE_TEST] ✅ Тест создан с ID: ${created.id}');
      print('[CREATE_TEST] 📋 Полная информация: name=${created.name}, id=${created.id}, accessCode=${created.accessCode}');

      // Сохраняем тест в локальный кэш MyTestsScreen
      ref.read(myTestsProvider.notifier).addTestToCache(created);

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Тест создан'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Access code:'),
              const SizedBox(height: 8),
              SelectableText(
                created.accessCode,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: created.accessCode));
                Navigator.pop(context);
              },
              child: const Text('Копировать'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Тест создан успешно')),
      );
      Navigator.of(context).pushReplacementNamed('/edit-test', arguments: created.id);
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
      appBar: AppBar(title: const Text('Создать тест')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Название теста'),
                validator: (value) => value?.isEmpty ?? true ? 'Обязательное поле' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Описание'),
                validator: (value) => value?.isEmpty ?? true ? 'Обязательное поле' : null,
              ),
              const SizedBox(height: 20),
              testState.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _createTest,
                      child: const Text('Создать тест'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}