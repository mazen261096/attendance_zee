import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Lightweight service for requesting the device's current location.
///
/// Returns `null` if the user denies permission or location services
/// are disabled.
/// Throws [LocationUnavailableException] if permission is granted but the position
/// cannot be determined (e.g. no GPS signal or timeout).
class LocationService {
  const LocationService();

  /// Request location permission and return the current position.
  Future<Position?> getCurrentPosition() async {
    // 1. Check if location services are enabled
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;
    } catch (_) {
      // isLocationServiceEnabled can fail on some web browsers
    }

    // 2. Check / request permission
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    // 3. Get position
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: kIsWeb ? LocationAccuracy.low : LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 15),
        ),
      );
    } catch (_) {
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) return lastKnown;
      } catch (_) {}
      throw LocationUnavailableException();
    }
  }

  /// Check whether we already have location permission (without prompting).
  Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }
}

class LocationUnavailableException implements Exception {}
