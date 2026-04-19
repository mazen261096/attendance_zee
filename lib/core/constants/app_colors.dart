import 'package:flutter/material.dart';
import '../config/app_config.dart';

class AppColors {
  // ──────────────────────────────────────────────
  // Brand Colors (derived from AppConfig)
  // ──────────────────────────────────────────────
  static const Color primary = AppConfig.primaryColor;
  static const Color primaryDark = AppConfig.primaryDarkColor;
  static const Color primaryLight = AppConfig.primaryLightColor;

  // Secondary — derived from the dark gray brand color
  static const Color secondary = AppConfig.secondaryColor;

  // ──────────────────────────────────────────────
  // Light Mode
  // ──────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF424040);
  static const Color textSecondaryLight = Color(0xFF757575);

  // ──────────────────────────────────────────────
  // Dark Mode
  // ──────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF2C2A2A);
  static const Color surfaceDark = Color(0xFF424040);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFBDBDBD);

  // ──────────────────────────────────────────────
  // Functional Colors
  // ──────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ──────────────────────────────────────────────
  // Gradient
  // ──────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
