import 'package:equatable/equatable.dart';
import '../../../core/utils/enums.dart';
import '../data/models/user_model.dart';

class AuthState extends Equatable {
  final RequestState signInState;
  final String signInError;

  final RequestState signUpState;
  final String signUpError;

  final RequestState googleSignInState;
  final String googleSignInError;

  final RequestState changePasswordState;
  final String changePasswordError;

  final RequestState resetPasswordState;
  final String resetPasswordError;

  final UserModel? user;
  final bool isAuthenticated;

  const AuthState({
    this.signInState = RequestState.initial,
    this.signInError = '',
    this.signUpState = RequestState.initial,
    this.signUpError = '',
    this.googleSignInState = RequestState.initial,
    this.googleSignInError = '',
    this.changePasswordState = RequestState.initial,
    this.changePasswordError = '',
    this.resetPasswordState = RequestState.initial,
    this.resetPasswordError = '',
    this.user,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    RequestState? signInState,
    String? signInError,
    RequestState? signUpState,
    String? signUpError,
    RequestState? googleSignInState,
    String? googleSignInError,
    RequestState? changePasswordState,
    String? changePasswordError,
    RequestState? resetPasswordState,
    String? resetPasswordError,
    UserModel? user,
    bool? isAuthenticated,
  }) {
    return AuthState(
      signInState: signInState ?? this.signInState,
      signInError: signInError ?? this.signInError,
      signUpState: signUpState ?? this.signUpState,
      signUpError: signUpError ?? this.signUpError,
      googleSignInState: googleSignInState ?? this.googleSignInState,
      googleSignInError: googleSignInError ?? this.googleSignInError,
      changePasswordState: changePasswordState ?? this.changePasswordState,
      changePasswordError: changePasswordError ?? this.changePasswordError,
      resetPasswordState: resetPasswordState ?? this.resetPasswordState,
      resetPasswordError: resetPasswordError ?? this.resetPasswordError,
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  bool get isSignInLoading => signInState == RequestState.loading;
  bool get isSignInSuccess => signInState == RequestState.loaded;
  bool get hasSignInError => signInState == RequestState.error;

  bool get isSignUpLoading => signUpState == RequestState.loading;
  bool get isSignUpSuccess => signUpState == RequestState.loaded;
  bool get hasSignUpError => signUpState == RequestState.error;

  bool get isGoogleSignInLoading => googleSignInState == RequestState.loading;
  bool get isGoogleSignInSuccess => googleSignInState == RequestState.loaded;
  bool get hasGoogleSignInError => googleSignInState == RequestState.error;

  bool get isChangePasswordLoading =>
      changePasswordState == RequestState.loading;
  bool get isChangePasswordSuccess =>
      changePasswordState == RequestState.loaded;

  bool get isResetPasswordLoading =>
      resetPasswordState == RequestState.loading;
  bool get isResetPasswordSuccess =>
      resetPasswordState == RequestState.loaded;

  @override
  List<Object?> get props => [
        signInState, signInError,
        signUpState, signUpError,
        googleSignInState, googleSignInError,
        changePasswordState, changePasswordError,
        resetPasswordState, resetPasswordError,
        user, isAuthenticated,
      ];
}
