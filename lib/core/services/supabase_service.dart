import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

class SupabaseService {
  SupabaseService._internal();
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;

  static SupabaseClient get client => Supabase.instance.client;

  Future<void> init() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      debug: AppConfig.supabaseDebug,
    );
  }

  User? get currentUser => client.auth.currentUser;
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}
