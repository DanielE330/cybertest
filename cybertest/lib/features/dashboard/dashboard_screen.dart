import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/models/user.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(child: Text('Ошибка: $error')),
      ),
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Не авторизован')),
          );
        }

        print('\n╔════════════════════════════════════════════');
        print('║ [DASHBOARD] 👤 ИНФОРМАЦИЯ О ПОЛЬЗОВАТЕЛЕ');
        print('╠════════════════════════════════════════════');
        print('║ Username: ${user.username}');
        print('║ Role (enum): ${user.role}');
        print('║ Role (displayName): ${user.role.displayName}');
        print('║ Role (apiValue): ${user.role.apiValue}');
        print('║ ID: ${user.id}');
        print('╚════════════════════════════════════════════\n');

        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: Text('Панель управления (${user.role.displayName})'),
            actions: [
              IconButton(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  Navigator.pushReplacementNamed(context, '/');
                },
                icon: const Icon(Icons.logout),
              )
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getText(user.role),
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                if (user.role == UserRole.teacher) ...[
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/my-tests'),
                    child: const Text('Мои тесты'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/create-test'),
                    child: const Text('Создать тест'),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/access-code'),
                    child: const Text('Пройти тест'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _getText(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return 'Панель преподавателя';
      case UserRole.student:
        return 'Панель студента';
    }
  }
}