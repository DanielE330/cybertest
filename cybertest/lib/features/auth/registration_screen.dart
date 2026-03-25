import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  String status = 'student';
  String? errorMessage;

  final statusOptions = {
    'student': 'Студент',
    'teacher': 'Преподаватель',
  };

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (nameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        passwordConfirmController.text.isEmpty) {
      setState(() => errorMessage = 'Заполните все поля');
      return;
    }

    if (passwordController.text != passwordConfirmController.text) {
      setState(() => errorMessage = 'Пароли не совпадают');
      return;
    }

    if (passwordController.text.length < 8) {
      setState(() => errorMessage = 'Пароль должен быть минимум 8 символов');
      return;
    }

    setState(() => errorMessage = null);

    await ref.read(authProvider.notifier).register(
      username: nameController.text,
      password: passwordController.text,
      role: status,
    );

    if (mounted) {
      final authState = ref.read(authProvider);
      authState.when(
        data: (user) {
          if (user != null) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        },
        error: (error, _) {
          setState(() => errorMessage = error.toString());
        },
        loading: () {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация'),
      ),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Создание нового аккаунта',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 30),

                if (errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withAlpha(30),
                      border: Border.all(color: colorScheme.error),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                const SizedBox(height: 16),

                TextField(
                  controller: nameController,
                  readOnly: isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Логин',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  readOnly: isLoading,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Пароль',
                    prefixIcon: Icon(Icons.lock),
                    helperText: 'Минимум 8 символов',
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: passwordConfirmController,
                  readOnly: isLoading,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Повторите пароль',
                    prefixIcon: Icon(Icons.lock),
                    helperText: 'Минимум 8 символов',
                  ),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: status,
                  isExpanded: true,
                  items: statusOptions.entries
                      .map((e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ))
                      .toList(),
                  onChanged: isLoading
                      ? null
                      : (v) {
                          if (v != null) {
                            setState(() => status = v);
                          }
                        },
                  decoration: const InputDecoration(
                    labelText: 'Роль',
                    prefixIcon: Icon(Icons.security),
                  ),
                ),
                const SizedBox(height: 24),

                isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: register,
                          child: const Text('Зарегистрироваться'),
                        ),
                      ),
                const SizedBox(height: 12),

                isLoading
                    ? const SizedBox.shrink()
                    : SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Уже есть аккаунт? Войти'),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
