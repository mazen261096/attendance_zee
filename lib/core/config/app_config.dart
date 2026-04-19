import 'package:flutter/material.dart';

/// ╔══════════════════════════════════════════════════════════════╗
/// ║                    APP CONFIGURATION                        ║
/// ║  This is the ONLY file you need to edit for a new project.  ║
/// ║  Change values here and the whole app will update.          ║
/// ╚══════════════════════════════════════════════════════════════╝
class AppConfig {
  AppConfig._();

  // ──────────────────────────────────────────────
  // App Identity
  // ──────────────────────────────────────────────
  static const String appName = 'AttendanceZee';
  static const String appNamePart1 = 'Attendance';
  static const String appNamePart2 = 'Zee';
  static const String appVersion = '1.0.0';

  // ──────────────────────────────────────────────
  // Supabase Backend
  // ──────────────────────────────────────────────
  static const String supabaseUrl = 'https://afezewzfxwtghrlsugfl.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFmZXpld3pmeHd0Z2hybHN1Z2ZsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU3MjgxNTYsImV4cCI6MjA5MTMwNDE1Nn0.9JcBwJEU8WsyC6pOkrBxSMzaAOoM9AkzbdwX0rmvUHA';
  static const bool supabaseDebug = true;

  // ──────────────────────────────────────────────
  // Brand Colors
  // ──────────────────────────────────────────────
  static const Color primaryColor = Color(0xFF4F46E5); // Indigo
  static const Color primaryDarkColor = Color(0xFF3730A3);
  static const Color primaryLightColor = Color(0xFF818CF8);
  static const Color secondaryColor = Color(0xFF1E293B); // Slate
  static const Color accentColor = Color(0xFF06B6D4); // Cyan
  static const Color successColor = Color(0xFF10B981); // Emerald
  static const Color warningColor = Color(0xFFF59E0B); // Amber
  static const Color errorColor = Color(0xFFEF4444); // Red

  // ──────────────────────────────────────────────
  // Contact & Links
  // ──────────────────────────────────────────────
  static const String supportEmail = 'support@attendancezee.com';
  static const String websiteUrl = 'https://attendancezee.com';

  // ──────────────────────────────────────────────
  // Feature Flags
  // ──────────────────────────────────────────────
  static const bool enableGoogleSignIn = false;
  static const bool enableAds = false;
  static const bool enablePushNotifications = true;

  // ──────────────────────────────────────────────
  // Notification Channel (Android)
  // ──────────────────────────────────────────────
  static const String notificationChannelId = 'attendance_zee_notify_channel';
  static const String notificationChannelName = 'Attendance Notifications';
  static const String notificationChannelDescription =
      'Notifications for attendance, grades, and course updates.';
  static const String notificationSoundName = 'zee_notify';

  // ──────────────────────────────────────────────
  // FCM Token Storage (Supabase)
  // ──────────────────────────────────────────────
  static const String fcmTokenTable = 'profiles';
  static const String fcmTokenColumn = 'fcm_token';
}
