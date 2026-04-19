import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Simple, platform-based adaptive helper.
///
/// - Platform check: uses [kIsWeb] (compile-time constant).
/// - Narrow check: on web, hides labels when the viewport is ≤ 900px.
/// - Responsive padding: on web, horizontal padding scales with window width.
class AdaptiveManager {
  /// Whether labels in the web app bar should be hidden.
  /// Returns `true` when running on web AND the viewport is narrow.
  static bool isNarrowWeb(BuildContext context) {
    return kIsWeb && MediaQuery.sizeOf(context).width <= 900;
  }

  /// Responsive page padding.
  ///
  /// On web:
  /// - ≤ 900px  → 12px (same as mobile, feels natural on narrow windows)
  /// - > 900px  → scales from 12px up to 20% of width
  /// On mobile: fixed 6px all around.
  static EdgeInsets getPagePadding(BuildContext context) {
    if (kIsWeb) {
      final width = MediaQuery.sizeOf(context).width;
      if (width <= 900) {
        return const EdgeInsets.symmetric(horizontal: 12);
      }
      // Lerp from 12px at 900px to 20% at wider widths
      final t = ((width - 900) / 600).clamp(0.0, 1.0); // 0→1 over 900–1500px
      final horizontal = 12.0 + t * (width * 0.20 - 12.0);
      return EdgeInsets.symmetric(horizontal: horizontal);
    }
    return const EdgeInsets.symmetric(horizontal: 8);
  }

  /// Dialog width — wider on web, narrower on mobile.
  static double getDialogWidth(BuildContext context) {
    if (kIsWeb) {
      return 600;
    }
    return MediaQuery.sizeOf(context).width * 0.9;
  }

  /// Responsive logo / app icon size.
  ///
  /// On native mobile: uses ScreenUtil [150.w].
  /// On web: adapts to viewport width so it looks right on both
  /// desktop browsers and mobile browsers viewing the web version.
  ///   - ≤ 600px (mobile web)  → 120px
  ///   - ≤ 900px (tablet web)  → 110px
  ///   - > 900px (desktop web) → 100px
  static double getLogoSize(BuildContext context) {
    if (!kIsWeb) return 150.0.w;
    final width = MediaQuery.sizeOf(context).width;
    if (width <= 600) return 150.0;
    if (width <= 900) return 200.0;
    return 300.0;
  }

  /// Responsive border radius for the logo.
  static double getLogoBorderRadius(BuildContext context) {
    if (!kIsWeb) return 30.0.r;
    return 20.0;
  }
}
