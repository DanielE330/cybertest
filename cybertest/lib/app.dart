import 'package:flutter/material.dart';
import 'core/router.dart';
import 'theme/app_themes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Приложение для кибертестов',
      debugShowCheckedModeBanner: false,
      theme: LightTheme.theme,
      darkTheme: DarkTheme.theme,
      themeMode: ThemeMode.dark,
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}