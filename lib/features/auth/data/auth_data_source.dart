import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
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

  Future<void> signOut();

  User? getCurrentUser();
  Stream<AuthState> get authStateChanges;

  Future<void> resetPassword({required String email});
}

class AuthDataSource implements BaseAuthDataSource {
  final SupabaseService supabaseService;

  const AuthDataSource({required this.supabaseService});

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

  @override
  Future<void> signOut() async {
    try {
      await SupabaseService.client.auth.signOut();
    } catch (e) {
      throw SupabaseErrorMapper.mapException(e);
    }
  }

  @override
  User? getCurrentUser() {
    return SupabaseService.client.auth.currentUser;
  }

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
