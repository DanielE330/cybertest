import 'package:flutter/material.dart';

class RtColors {
  RtColors._();

  // Основные брендовые
  static const Color orange = Color(0xFFFF6600);
  static const Color orangeLight = Color(0xFFFF8533);
  static const Color orangeDark = Color(0xFFE55C00);

  // Тёмная тема — фоны
  static const Color darkBg = Color(0xFF1A1A2E);
  static const Color darkSurface = Color(0xFF232340);
  static const Color darkCard = Color(0xFF2A2A4A);
  static const Color darkBorder = Color(0xFF7700ff);

  // Тёмная тема — текст
  static const Color darkTextPrimary = Color(0xFFF0F0F5);
  static const Color darkTextSecondary = Color(0xFFB0B0C8);
  static const Color darkTextHint = Color(0xFF7A7A9C);

  // Светлая тема — фоны
  static const Color lightBg = Color(0xFFF7F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE0E0E8);

  // Светлая тема — текст
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF5C5C70);
  static const Color lightTextHint = Color(0xFF9C9CB0);

  // Фиолетовый
  static const Color purple = Color(0xFF7B2FBE);
  static const Color purpleLight = Color(0xFF9B59B6);
  static const Color purpleDark = Color(0xFF5B1F8E);

  // Акценты / статусы
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
}

// Обратная совместимость
class DarkColors {
  DarkColors._();
  static const Color main = RtColors.darkBg;
  static const Color labelActive = RtColors.orange;
  static const Color inputField = RtColors.darkCard;
  static const Color labelText = RtColors.darkTextSecondary;
  static const Color lightInput = RtColors.darkBorder;
  static const Color orange = RtColors.orange;
}

class LightColors {
  LightColors._();
  static const Color main = RtColors.lightBg;
  static const Color labelActive = RtColors.orange;
  static const Color purpleText = RtColors.lightTextPrimary;
  static const Color orange = RtColors.orange;
}
