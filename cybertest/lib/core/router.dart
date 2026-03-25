import 'package:flutter/material.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/registration_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/teacher/create_test_screen.dart';
import '../features/teacher/edit_test_screen.dart';
import '../features/teacher/my_tests_screen.dart';
import '../features/teacher/teacher_test_results_screen.dart';
import '../features/student/access_code_screen.dart';
import '../features/student/take_test_screen.dart';
import '../features/student/test_result_screen.dart';
import '../core/models/test.dart';
import '../core/models/test_result.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case '/registration':
        return MaterialPageRoute(builder: (_) => const RegistrationScreen());

      case '/create-test':
        return MaterialPageRoute(builder: (_) => const CreateTestScreen());

      case '/edit-test':
        final testId = settings.arguments as int;
        return MaterialPageRoute(builder: (_) => EditTestScreen(testId: testId));

      case '/my-tests':
        return MaterialPageRoute(builder: (_) => const MyTestsScreen());

      case '/test-results-teacher':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => TeacherTestResultsScreen(
            testId: args['testId'] as int,
            testName: args['testName'] as String,
          ),
        );

      case '/access-code':
        return MaterialPageRoute(builder: (_) => const AccessCodeScreen());

      case '/take-test':
        final test = settings.arguments as Test;
        return MaterialPageRoute(builder: (_) => TakeTestScreen(test: test));

      case '/test-result':
        final result = settings.arguments as TestResult;
        return MaterialPageRoute(builder: (_) => TestResultScreen(result: result));

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Маршрут не найден')),
          ),
        );
    }
  }
}