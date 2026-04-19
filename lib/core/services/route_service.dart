import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/routes.dart';

/// Smart Navigation Service
///
/// Automatically handles Platform Best Practices:
/// - **Web:** Uses `go` for smooth SPA feel & cleaner URLs
/// - **Mobile:** Uses `push` for proper Back Button stack
///
class RouteService {
  RouteService(this._navigatorKey);

  final GlobalKey<NavigatorState> _navigatorKey;
  BuildContext? get _context => _navigatorKey.currentContext;

  // ==========================================
  // SMART NAVIGATION (Platform Aware)
  // ==========================================

  Future<T?> pushNamed<T>(String routeName, {Map<String, String>? params}) {
    final context = _context;
    if (context == null) return Future.value(null);

    // Build path with parameters
    String path = routeName;
    if (params != null) {
      params.forEach((key, value) {
        path = path.replaceAll(':$key', value);
      });
    }

    if (kIsWeb) {
      // WEB: Use go for smooth SPA feel (Browser handles history)
      context.go(path);
      return Future.value(null);
    } else {
      // MOBILE: Use push for Back Button stack
      return context.push<T>(path);
    }
  }

  /// Push a route on ALL platforms (web + mobile).
  ///
  /// Use for detail screens (e.g. question pages) that should layer on top
  /// of the current page, preserving the parent's scroll position.
  /// The browser URL updates automatically via GoRouter.
  Future<T?> pushOnAllPlatforms<T>(
    String routeName, {
    Map<String, String>? params,
  }) {
    final context = _context;
    if (context == null) return Future.value(null);

    String path = routeName;
    if (params != null) {
      params.forEach((key, value) {
        path = path.replaceAll(':$key', value);
      });
    }

    return context.push<T>(path);
  }

  /// Navigate by replacing the current browser history entry (web only).
  /// Ideal for top-level tab switching in the web app bar — pressing Back
  /// won't cycle through every tab the user visited.
  ///
  /// On mobile, falls back to normal push.
  void replaceNamed(String routeName, {Map<String, String>? params}) {
    final context = _context;
    if (context == null) return;

    String path = routeName;
    if (params != null) {
      params.forEach((key, value) {
        path = path.replaceAll(':$key', value);
      });
    }

    if (kIsWeb) {
      // Router.neglect tells the Router not to report this navigation
      // to the browser history, so Back won't replay it.
      Router.neglect(context, () => context.go(path));
    } else {
      context.push(path);
    }
  }

  /// Go to route (replaces stack)
  /// Use ONLY for auth flows (Login, Signup, Splash)
  void goNamed(String routeName, {Map<String, String>? params}) {
    final context = _context;
    if (context == null) return;

    String path = routeName;
    if (params != null) {
      params.forEach((key, value) {
        path = path.replaceAll(':$key', value);
      });
    }
    context.go(path);
  }

  /// Go back
  bool goBack() {
    final context = _context;
    if (context == null) return false;
    if (GoRouter.of(context).canPop()) {
      context.pop();
      return true;
    }
    // Nothing to pop — navigate to Home.
    // Covers deep-link landings and web history edge cases.
    context.go(Routes.home);
    return false;
  }

  /// Check if can go back
  bool canGoBack() {
    final context = _context;
    if (context == null) return false;
    return GoRouter.of(context).canPop();
  }

  // ==========================================
  // DRAWER HELPER (mobile)
  // ==========================================

  /// Close drawer then navigate uses smart push
  Future<T?> closeDrawerAndPush<T>(
    BuildContext drawerContext,
    String routeName, {
    Map<String, String>? params,
  }) {
    final scaffoldState = Scaffold.maybeOf(drawerContext);
    if (scaffoldState?.isDrawerOpen ?? false) {
      Navigator.of(drawerContext).pop();
    }
    return pushNamed<T>(routeName, params: params);
  }
}
