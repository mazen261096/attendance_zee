import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Singleton service that collects device information for analytics.
/// Initialized once at app startup, then provides a map of analytics data
/// to attach to question submissions and posts.
class DeviceInfoService {
  DeviceInfoService._();
  static final DeviceInfoService _instance = DeviceInfoService._();
  static DeviceInfoService get instance => _instance;

  String? _deviceId;
  String? _deviceModel;
  String? _platform;
  String? _deviceLocale;

  bool _initialized = false;

  /// Initialize the service. Call once at app startup.
  Future<void> init() async {
    if (_initialized) return;

    final deviceInfo = DeviceInfoPlugin();

    // Platform
    if (kIsWeb) {
      _platform = 'web';
      final webInfo = await deviceInfo.webBrowserInfo;
      _deviceModel = webInfo.browserName.name;

      // Fallback for Web: Use SharedPreferences to store a persistent UUID
      final prefs = await SharedPreferences.getInstance();
      const deviceIdKey = 'web_device_id';
      _deviceId = prefs.getString(deviceIdKey);
      if (_deviceId == null) {
        _deviceId = const Uuid().v4();
        await prefs.setString(deviceIdKey, _deviceId!);
      }
    } else if (Platform.isIOS) {
      _platform = 'ios';
      final iosInfo = await deviceInfo.iosInfo;
      _deviceModel = iosInfo.utsname.machine; // e.g. "iPhone15,2"
      _deviceId = iosInfo.identifierForVendor; // IDFV - safe to use
    } else if (Platform.isAndroid) {
      _platform = 'android';
      final androidInfo = await deviceInfo.androidInfo;
      _deviceModel =
          '${androidInfo.brand} ${androidInfo.model}'; // e.g. "Samsung SM-S911B"
      _deviceId = androidInfo
          .id; // Corrected Android device ID (survives app reinstalls)
    }

    // Locale from the platform (e.g. "ar_EG", "en_US")
    _deviceLocale = PlatformDispatcher.instance.locale.toString();

    _initialized = true;
  }

  /// Returns a map of analytics data to send with question submissions.
  Map<String, String?> toAnalyticsMap() {
    return {
      'p_device_id': _deviceId,
      'p_device_model': _deviceModel,
      'p_platform': _platform,
      'p_device_locale': _deviceLocale,
    };
  }
}
