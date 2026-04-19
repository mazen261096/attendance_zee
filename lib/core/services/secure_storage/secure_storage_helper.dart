import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorageHelper {
  static const _storage = FlutterSecureStorage();

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserData = 'user_data';

  // Save tokens
  static Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      if (refreshToken != null)
        _storage.write(key: _keyRefreshToken, value: refreshToken),
    ]);
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  // Save user data
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final userJson = jsonEncode(userData);
    await _storage.write(key: _keyUserData, value: userJson);
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final userJson = await _storage.read(key: _keyUserData);
    if (userJson != null) {
      return jsonDecode(userJson) as Map<String, dynamic>;
    }
    return null;
  }

  // Check if has valid tokens
  static Future<bool> hasValidTokens() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  // Clear tokens
  static Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
    ]);
  }

  // Clear user data
  static Future<void> clearUserData() async {
    await _storage.delete(key: _keyUserData);
  }

  // Clear all data
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
