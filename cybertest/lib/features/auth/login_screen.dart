import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiberbez/core/models/user.dart';
import '../../core/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
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
    super.dispose();
  }

  Future<void> login() async {
    if (nameController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() => errorMessage = 'Заполните все поля');
      return;
    }

    setState(() => errorMessage = null);

    print('[LOGIN_SCREEN] 📌 Выбрана роль: $status');

    await ref.read(authProvider.notifier).login(
      username: nameController.text,
      password: passwordController.text,
      role: status,
    );

    if (mounted) {
      final authState = ref.read(authProvider);
      authState.when(
        data: (user) {
          if (user != null) {
            print('[LOGIN_SCREEN] ✅ Логин успешен. Роль пользователя: ${user.role.displayName}');
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

  Future<void> registration() async {
    Navigator.pushNamed(context, '/registration');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Тесты онлайн',
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
                        onPressed: login,
                        child: const Text('Войти'),
                      ),
                    ),
              const SizedBox(height: 12),
              
              isLoading
                  ? const SizedBox.shrink()
                  : SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: registration,
                        child: const Text('Нет аккаунта? Зарегистрироваться'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}