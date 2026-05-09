import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/failure.dart';
import '../../../core/utils/supabase_error_mapper.dart';

abstract class BaseAuthDataSource {
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  });

  /// Native Google Sign-In — shows the system account picker (no browser).
  /// Returns a full [AuthResponse] with session + user on success.
  Future<AuthResponse> signInWithGoogle();

  Future<void> signOut();

  User? getCurrentUser();
  Stream<AuthState> get authStateChanges;

  Future<void> resetPassword({required String email});
}

class AuthDataSource implements BaseAuthDataSource {
  final SupabaseService supabaseService;

  const AuthDataSource({required this.supabaseService});

  // ── Email ──────────────────────────────────────────────────────────────────

  @override
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw SupabaseErrorMapper.mapException(e);
    }
  }

  @override
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      throw SupabaseErrorMapper.mapException(e);
    }
  }

  // ── Google Native (v7 API) ─────────────────────────────────────────────────

  /// Uses [google_sign_in] v7 singleton API to get an ID token from the
  /// native Google dialog, then passes it to Supabase via [signInWithIdToken].
  /// No browser is opened — shows native Android account picker.
  ///
  /// Call [initGoogleSignIn] once at app start (e.g. in main.dart or DI setup)
  /// before using this method.
  static Future<void> initGoogleSignIn() async {
    await GoogleSignIn.instance.initialize(
      serverClientId: AppConfig.googleWebClientId,
    );
  }

  @override
  Future<AuthResponse> signInWithGoogle() async {
    try {
      // Show the native account picker and authenticate
      final GoogleSignInAccount account =
          await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication gAuth = account.authentication;

      final idToken = gAuth.idToken;
      if (idToken == null) {
        throw const Failure(
          message: 'Google did not return an ID token. '
              'Make sure serverClientId is the Web OAuth client ID.',
          code: 'google_no_id_token',
        );
      }

      // Exchange Google ID token for a Supabase session (no accessToken needed)
      final response = await SupabaseService.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      return response;
    } on Failure {
      rethrow;
    } on GoogleSignInException catch (e) {
      // Cancelled / interrupted — surface as a Failure, not a crash
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        throw const Failure(
          message: 'Google Sign-In was cancelled.',
          code: 'google_sign_in_cancelled',
        );
      }
      throw Failure(message: e.description ?? 'Google Sign-In failed.', code: 'google_sign_in_error');
    } catch (e) {
      throw SupabaseErrorMapper.mapException(e);
    }
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────


  @override
  Future<void> signOut() async {
    try {
      await Future.wait<void>([
        SupabaseService.client.auth.signOut(),
        GoogleSignIn.instance.signOut(),
      ]);
    } catch (e) {
      throw SupabaseErrorMapper.mapException(e);
    }
  }


  // ── Misc ───────────────────────────────────────────────────────────────────

  @override
  User? getCurrentUser() => SupabaseService.client.auth.currentUser;

  @override
  Stream<AuthState> get authStateChanges =>
      SupabaseService.client.auth.onAuthStateChange;

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await SupabaseService.client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw SupabaseErrorMapper.mapException(e);
    }
  }
}
