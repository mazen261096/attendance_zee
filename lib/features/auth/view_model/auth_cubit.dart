import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/utils/enums.dart';
import '../../../core/utils/either_extensions.dart';
import '../../../core/utils/core_utils.dart';
import '../../../core/utils/supabase_error_mapper.dart';
import '../../../core/resources/app_strings.dart';
import '../../../core/services/notification_service.dart';
import '../data/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.repository}) : super(const AuthState());

  final BaseAuthRepository repository;

  Future<void> checkAuthentication() async {
    final isAuth = await repository.isAuthenticated();
    final user = await repository.getCurrentUser();
    emit(state.copyWith(isAuthenticated: isAuth, user: user));
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(signInState: RequestState.loading, signInError: ''));

    try {
      final result = await repository.signInWithEmail(
        email: email,
        password: password,
      );

      result
          .showDialogOnError(title: AppStrings.errorTitle.tr())
          .fold(
            (failure) {
              emit(state.copyWith(
                signInState: RequestState.error,
                signInError: failure.message,
              ));
            },
            (user) {
              emit(state.copyWith(
                signInState: RequestState.loaded,
                user: user,
                isAuthenticated: true,
                signInError: '',
              ));

              // Save FCM token after successful login (mobile only)
              if (!kIsWeb) {
                NotificationService().saveFCMToken(user.id).catchError((e) {
                  print('Failed to save FCM token after login: $e');
                });
              }
            },
          );
    } catch (error, stack) {
      print('Error in signInWithEmail: $error');
      print(stack);
      final failure = SupabaseErrorMapper.mapException(error);
      CoreUtils.showErrorDialog(
        title: AppStrings.errorTitle.tr(),
        message: failure.message,
      );
      emit(state.copyWith(
        signInState: RequestState.error,
        signInError: failure.message,
      ));
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(signUpState: RequestState.loading, signUpError: ''));

    try {
      final result = await repository.signUpWithEmail(
        email: email,
        password: password,
      );

      result
          .showDialogOnError(title: AppStrings.errorTitle.tr())
          .fold(
            (failure) {
              emit(state.copyWith(
                signUpState: RequestState.error,
                signUpError: failure.message,
              ));
            },
            (user) {
              emit(state.copyWith(
                signUpState: RequestState.loaded,
                user: user,
                isAuthenticated: true,
                signUpError: '',
              ));

              // Save FCM token after successful signup (mobile only)
              if (!kIsWeb) {
                NotificationService().saveFCMToken(user.id).catchError((e) {
                  print('Failed to save FCM token after signup: $e');
                });
              }
            },
          );
    } catch (error, stack) {
      print('Error in signUpWithEmail: $error');
      print(stack);
      final failure = SupabaseErrorMapper.mapException(error);
      CoreUtils.showErrorDialog(
        title: AppStrings.errorTitle.tr(),
        message: failure.message,
      );
      emit(state.copyWith(
        signUpState: RequestState.error,
        signUpError: failure.message,
      ));
    }
  }

  Future<void> signOut() async {
    try {
      // Clear FCM token before signing out (mobile only)
      if (!kIsWeb) {
        final userId = state.user?.id;
        if (userId != null) {
          await NotificationService().clearFCMToken(userId).catchError((e) {
            print('Failed to clear FCM token on sign out: $e');
          });
        }
      }
      await repository.signOut();
      emit(const AuthState()); // Reset to initial state
    } catch (error, stack) {
      print('Error in signOut: $error');
      print(stack);
    }
  }

  Future<void> changePassword({required String newPassword}) async {
    emit(state.copyWith(
      changePasswordState: RequestState.loading,
      changePasswordError: '',
    ));

    try {
      final result = await repository.changePassword(newPassword: newPassword);

      result
          .showSnackBarOnError()
          .showSnackBarOnSuccess(message: AppStrings.passwordChangedSuccess.tr())
          .fold(
            (failure) {
              emit(state.copyWith(
                changePasswordState: RequestState.error,
                changePasswordError: failure.message,
              ));
            },
            (_) {
              emit(state.copyWith(
                changePasswordState: RequestState.loaded,
                changePasswordError: '',
              ));
            },
          );
    } catch (error, stack) {
      print('Error in changePassword: $error');
      print(stack);
      final failure = SupabaseErrorMapper.mapException(error);
      CoreUtils.showErrorSnackBar(message: failure.message);
      emit(state.copyWith(
        changePasswordState: RequestState.error,
        changePasswordError: failure.message,
      ));
    }
  }

  Future<void> resetPassword({required String email}) async {
    emit(state.copyWith(
      resetPasswordState: RequestState.loading,
      resetPasswordError: '',
    ));

    try {
      final result = await repository.resetPassword(email: email);

      result.showSnackBarOnError().fold(
        (failure) {
          emit(state.copyWith(
            resetPasswordState: RequestState.error,
            resetPasswordError: failure.message,
          ));
        },
        (_) {
          emit(state.copyWith(
            resetPasswordState: RequestState.loaded,
            resetPasswordError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in resetPassword: $error');
      print(stack);
      final failure = SupabaseErrorMapper.mapException(error);
      CoreUtils.showErrorSnackBar(message: failure.message);
      emit(state.copyWith(
        resetPasswordState: RequestState.error,
        resetPasswordError: failure.message,
      ));
    }
  }

  void resetChangePasswordState() {
    emit(state.copyWith(
      changePasswordState: RequestState.initial,
      changePasswordError: '',
    ));
  }
}
