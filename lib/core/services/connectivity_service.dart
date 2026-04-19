import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// A global connectivity service that monitors network status
/// with a debounce delay to avoid false positives on slow networks.
class ConnectivityService extends ChangeNotifier {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _debounceTimer;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  /// Debounce duration before showing offline banner.
  /// Set to 5 seconds to tolerate slow/intermittent Egyptian networks.
  static const _debounceDuration = Duration(seconds: 5);

  Future<void> init() async {
    // Check initial status
    final results = await _connectivity.checkConnectivity();
    _isConnected = !_isFullyOffline(results);

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(_onChanged);
  }

  void _onChanged(List<ConnectivityResult> results) {
    final offline = _isFullyOffline(results);

    if (offline && _isConnected) {
      // Going offline — debounce to avoid flicker on slow networks
      _debounceTimer?.cancel();
      _debounceTimer = Timer(_debounceDuration, () {
        _isConnected = false;
        notifyListeners();
      });
    } else if (!offline && !_isConnected) {
      // Back online — show immediately
      _debounceTimer?.cancel();
      _isConnected = true;
      notifyListeners();
    } else if (!offline) {
      // Still online, cancel any pending offline timer
      _debounceTimer?.cancel();
    }
  }

  bool _isFullyOffline(List<ConnectivityResult> results) {
    return results.isEmpty ||
        results.every((r) => r == ConnectivityResult.none);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
