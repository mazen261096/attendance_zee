import 'dart:ui';

import 'package:dartz/dartz.dart';
import '../../core/utils/failure.dart';
import 'core_utils.dart';

extension EitherExtensions<L, R> on Either<L, R> {
  /// Automatically shows an error snackbar if the result is Left (Failure)
  /// Returns the original Either for chaining
  Either<L, R> showSnackBarOnError() {
    fold(
      (l) {
        if (l is Failure) {
          CoreUtils.showErrorSnackBar(message: l.message);
        } else {
          CoreUtils.showErrorSnackBar(message: l.toString());
        }
      },
      (r) {
        // Do nothing on success
      },
    );
    return this;
  }

  /// Automatically shows a success snackbar if the result is Right
  /// Optional [message] can be provided
  /// Returns the original Either for chaining
  Either<L, R> showSnackBarOnSuccess({String? message}) {
    fold(
      (l) {
        // Do nothing on error
      },
      (r) {
        if (message != null) {
          CoreUtils.showSuccessSnackBar(message: message);
        }
      },
    );
    return this;
  }

  /// Automatically shows an error dialog if the result is Left (Failure)
  /// Returns the original Either for chaining
  Either<L, R> showDialogOnError({required String title}) {
    fold(
      (l) {
        String message;
        if (l is Failure) {
          message = l.message;
        } else {
          message = l.toString();
        }
        CoreUtils.showErrorDialog(title: title, message: message);
      },
      (r) {
        // Do nothing on success
      },
    );
    return this;
  }

  /// Automatically shows a success dialog if the result is Right
  /// Returns the original Either for chaining
  Either<L, R> showDialogOnSuccess({
    required String title,
    required String message,
    VoidCallback? onOk,
  }) {
    fold(
      (l) {
        // Do nothing on error
      },
      (r) {
        CoreUtils.showSuccessDialog(title: title, message: message, onOk: onOk);
      },
    );
    return this;
  }
}
