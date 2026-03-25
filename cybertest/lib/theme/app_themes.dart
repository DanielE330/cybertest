import 'package:flutter/material.dart';
import 'app_colors.dart';


class DarkTheme {
  DarkTheme._();

  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'RostelecomBasis',
      primaryColor: RtColors.orange,
      scaffoldBackgroundColor: RtColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: RtColors.orange,
        onPrimary: Colors.white,
        secondary: RtColors.orangeLight,
        onSecondary: Colors.white,
        surface: RtColors.darkSurface,
        onSurface: RtColors.darkTextPrimary,
        error: RtColors.error,
        onError: Colors.white,
        primaryContainer: RtColors.darkCard,
        onPrimaryContainer: RtColors.orange,
        secondaryContainer: Color(0xFF3D2800),
        onSecondaryContainer: RtColors.orangeLight,
        surfaceContainerHighest: RtColors.darkCard,
        onSurfaceVariant: RtColors.darkTextSecondary,
        outline: RtColors.darkBorder,
        tertiary: RtColors.darkTextSecondary,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: RtColors.darkTextPrimary, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: RtColors.darkTextPrimary, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: RtColors.darkTextPrimary, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: RtColors.darkTextPrimary, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: RtColors.darkTextPrimary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: RtColors.darkTextPrimary),
        bodyMedium: TextStyle(color: RtColors.darkTextSecondary),
        bodySmall: TextStyle(color: RtColors.darkTextHint),
        labelLarge: TextStyle(color: RtColors.darkTextPrimary, fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: RtColors.darkCard,
        labelStyle: const TextStyle(color: RtColors.darkTextSecondary),
        hintStyle: const TextStyle(color: RtColors.darkTextHint),
        floatingLabelStyle: const TextStyle(color: RtColors.purple),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RtColors.purple, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RtColors.darkBorder),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RtColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RtColors.error, width: 2),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIconColor: RtColors.darkTextSecondary,
        suffixIconColor: RtColors.darkTextSecondary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: RtColors.darkBg,
        elevation: 0,
        scrolledUnderElevation: 1,
        iconTheme: IconThemeData(color: RtColors.orange),
        actionsIconTheme: IconThemeData(color: RtColors.orange),
        titleTextStyle: TextStyle(
          color: RtColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: RtColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: RtColors.darkBorder, width: 0.5),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: RtColors.orange,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: RtColors.orange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: RtColors.darkBorder,
          disabledForegroundColor: RtColors.darkTextHint,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: RtColors.orange,
          side: const BorderSide(color: RtColors.orange),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: RtColors.orange,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? RtColors.orange : RtColors.darkTextHint),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? RtColors.orange.withAlpha(80) : RtColors.darkBorder),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: RtColors.darkCard,
        labelStyle: const TextStyle(color: RtColors.darkTextPrimary),
        side: const BorderSide(color: RtColors.darkBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: RtColors.darkCard,
        contentTextStyle: TextStyle(color: RtColors.darkTextPrimary),
        actionTextColor: RtColors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: RtColors.darkSurface,
        titleTextStyle: const TextStyle(
          color: RtColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(color: RtColors.darkTextSecondary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerColor: RtColors.darkBorder,
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: RtColors.orange,
      ),
      iconTheme: const IconThemeData(color: RtColors.darkTextSecondary),
    );
  }
}


class LightTheme {
  LightTheme._();

  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: 'RostelecomBasis',
      primaryColor: RtColors.orange,
      scaffoldBackgroundColor: RtColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: RtColors.orange,
        onPrimary: Colors.white,
        secondary: RtColors.orangeDark,
        onSecondary: Colors.white,
        surface: RtColors.lightSurface,
        onSurface: RtColors.lightTextPrimary,
        error: RtColors.error,
        onError: Colors.white,
        primaryContainer: Color(0xFFFFE8D6),
        onPrimaryContainer: RtColors.orangeDark,
        secondaryContainer: Color(0xFFFFE0CC),
        onSecondaryContainer: RtColors.orangeDark,
        surfaceContainerHighest: Color(0xFFEEEEF3),
        onSurfaceVariant: RtColors.lightTextSecondary,
        outline: RtColors.lightBorder,
        tertiary: RtColors.lightTextSecondary,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: RtColors.lightTextPrimary, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: RtColors.lightTextPrimary, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: RtColors.lightTextPrimary, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: RtColors.lightTextPrimary, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: RtColors.lightTextPrimary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: RtColors.lightTextPrimary),
        bodyMedium: TextStyle(color: RtColors.lightTextSecondary),
        bodySmall: TextStyle(color: RtColors.lightTextHint),
        labelLarge: TextStyle(color: RtColors.lightTextPrimary, fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: RtColors.lightSurface,
        labelStyle: const TextStyle(color: RtColors.lightTextSecondary),
        hintStyle: const TextStyle(color: RtColors.lightTextHint),
        floatingLabelStyle: const TextStyle(color: RtColors.purple),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RtColors.purple, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RtColors.lightBorder),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RtColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RtColors.error, width: 2),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIconColor: RtColors.lightTextSecondary,
        suffixIconColor: RtColors.lightTextSecondary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: RtColors.lightSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        iconTheme: IconThemeData(color: RtColors.orange),
        actionsIconTheme: IconThemeData(color: RtColors.orange),
        titleTextStyle: TextStyle(
          color: RtColors.lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: RtColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: RtColors.lightBorder, width: 0.5),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: RtColors.orange,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: RtColors.orange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: RtColors.lightBorder,
          disabledForegroundColor: RtColors.lightTextHint,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: RtColors.orange,
          side: const BorderSide(color: RtColors.orange),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: RtColors.orange,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? RtColors.orange : RtColors.lightTextHint),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? RtColors.orange.withAlpha(80) : RtColors.lightBorder),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFFFE8D6),
        labelStyle: const TextStyle(color: RtColors.orangeDark),
        side: const BorderSide(color: Color(0xFFFFD0A8)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: RtColors.lightTextPrimary,
        contentTextStyle: const TextStyle(color: Colors.white),
        actionTextColor: RtColors.orangeLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: RtColors.lightSurface,
        titleTextStyle: const TextStyle(
          color: RtColors.lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(color: RtColors.lightTextSecondary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerColor: RtColors.lightBorder,
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: RtColors.orange,
      ),
      iconTheme: const IconThemeData(color: RtColors.lightTextSecondary),
    );
  }
}
