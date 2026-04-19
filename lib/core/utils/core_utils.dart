import 'package:flutter/material.dart';

import '../routes/app_router.dart';
import '../constants/app_colors.dart';
import '../widgets/status_dialog.dart';

class CoreUtils {
  /// Dismisses the keyboard
  static void dismissKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Shows a standardized snackbar
  static void showSnackBar({
    required String message,
    Color? backgroundColor,
    Color? messageColor,
    SnackBarBehavior? behavior,
  }) {
    AppRouter.scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: messageColor ?? Colors.white),
        ),
        backgroundColor: backgroundColor ?? Colors.black,
        behavior: behavior ?? SnackBarBehavior.floating,
      ),
    );
  }

  static void showSuccessSnackBar({required String message}) {
    showSnackBar(
      message: message,
      backgroundColor: AppColors.success,
      messageColor: Colors.white,
    );
  }

  static void showErrorSnackBar({required String message}) {
    showSnackBar(
      message: message,
      backgroundColor: AppColors.error,
      messageColor: Colors.white,
    );
  }

  /// Shows a success dialog using the global navigator context
  static void showSuccessDialog({
    required String title,
    required String message,
    VoidCallback? onOk,
  }) {
    final context = AppRouter.navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: false,

        builder: (context) =>
            StatusDialog.success(title: title, message: message, onOk: onOk),
      );
    }
  }

  /// Shows an error dialog using the global navigator context
  static void showErrorDialog({
    required String title,
    required String message,
  }) {
    final context = AppRouter.navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        builder: (context) =>
            StatusDialog.error(title: title, message: message),
      );
    }
  }

  /// Helper to get a localized asset path
  /// Usage: CoreUtils.localizedAsset(context, 'banner.png')
  /// Returns 'assets/images/en/banner.png' or 'assets/images/ar/banner.png'
  static String localizedAsset(BuildContext context, String assetName) {
    // Basic way to get locale, can also get from SettingsController if preferred.
    final locale = Localizations.localeOf(context).languageCode;
    return 'assets/images/$locale/$assetName';
  }
}
