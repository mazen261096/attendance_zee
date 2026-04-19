import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'failure.dart';

/// Maps Supabase Auth error codes to localized error message keys
class SupabaseErrorMapper {
  /// Converts a Supabase exception to a localized Failure object
  static Failure mapException(Object exception) {
    // Network / connectivity errors (no internet, DNS failure, etc.)
    if (_isNetworkError(exception)) {
      return Failure(
        message: 'errors.network_error'.tr(),
        code: 'network_error',
      );
    }

    if (exception is AuthException) {
      return _mapAuthException(exception);
    } else if (exception is PostgrestException) {
      return _mapPostgrestException(exception);
    } else if (exception is StorageException) {
      return _mapStorageException(exception);
    }

    // Handle generic exceptions
    return Failure(message: 'errors.unexpected_error'.tr(), code: 'unknown');
  }

  /// Detects network-related exceptions by inspecting the error message.
  static bool _isNetworkError(Object exception) {
    final msg = exception.toString().toLowerCase();
    return msg.contains('socketexception') ||
        msg.contains('handshakeexception') ||
        msg.contains('clientexception') ||
        (msg.contains('connection') && msg.contains('refused')) ||
        msg.contains('network is unreachable') ||
        msg.contains('no address associated') ||
        msg.contains('failed host lookup');
  }

  static Failure _mapAuthException(AuthException exception) {
    // Handle AuthApiException with error codes
    if (exception is AuthApiException) {
      final code = exception.code;
      final statusCode = exception.statusCode;

      return Failure(
        message: _getErrorMessageKey(code).tr(),
        code: code,
        statusCode: statusCode != null
            ? int.tryParse(statusCode.toString())
            : null,
      );
    }

    // Fallback for generic AuthException
    return Failure(message: 'errors.auth_error'.tr(), code: 'auth_error');
  }

  static Failure _mapPostgrestException(PostgrestException exception) {
    // PGRST116: JSON object requested, multiple (or no) rows returned
    if (exception.code == 'PGRST116') {
      return Failure(
        message: 'errors.record_not_found'.tr(),
        code: exception.code,
      );
    }

    // 23505: Unique violation
    if (exception.code == '23505') {
      return Failure(
        message: 'errors.record_already_exists'.tr(),
        code: exception.code,
      );
    }

    // Check for specific RPC error messages
    final message = exception.message.toLowerCase();
    if (message.contains('you are not allowed to ask this user questions')) {
      return Failure(
        message: 'errors.blocked_by_user'.tr(),
        code: 'blocked_by_user',
      );
    }

    return Failure(message: 'errors.database_error'.tr(), code: exception.code);
  }

  static Failure _mapStorageException(StorageException exception) {
    return Failure(
      message: 'errors.storage_error'.tr(),
      code: exception.statusCode,
    );
  }

  static String _getErrorMessageKey(String? code) {
    if (code == null) return 'errors.unknown_error';

    // Map Supabase error codes to translation keys
    switch (code) {
      // Authentication errors
      case 'invalid_credentials':
        return 'errors.invalid_credentials';
      case 'email_exists':
        return 'errors.email_exists';
      case 'user_not_found':
        return 'errors.user_not_found';
      case 'weak_password':
        return 'errors.weak_password';
      case 'email_not_confirmed':
        return 'errors.email_not_confirmed';
      case 'phone_not_confirmed':
        return 'errors.phone_not_confirmed';
      case 'user_already_exists':
        return 'errors.user_already_exists';
      case 'user_banned':
        return 'errors.user_banned';

      // Provider errors
      case 'email_provider_disabled':
        return 'errors.email_provider_disabled';
      case 'phone_provider_disabled':
        return 'errors.phone_provider_disabled';
      case 'provider_disabled':
        return 'errors.provider_disabled';
      case 'oauth_provider_not_supported':
        return 'errors.oauth_provider_not_supported';
      case 'anonymous_provider_disabled':
        return 'errors.anonymous_provider_disabled';

      // Email errors
      case 'email_address_invalid':
        return 'errors.email_address_invalid';
      case 'email_address_not_authorized':
        return 'errors.email_address_not_authorized';
      case 'email_conflict_identity_not_deletable':
        return 'errors.email_conflict_identity_not_deletable';

      // Password errors
      case 'same_password':
        return 'errors.same_password';
      case 'reauthentication_needed':
        return 'errors.reauthentication_needed';
      case 'reauthentication_not_valid':
        return 'errors.reauthentication_not_valid';

      // Session errors
      case 'session_not_found':
        return 'errors.session_not_found';
      case 'session_expired':
        return 'errors.session_expired';
      case 'refresh_token_not_found':
        return 'errors.refresh_token_not_found';
      case 'refresh_token_already_used':
        return 'errors.refresh_token_already_used';

      // Rate limiting
      case 'over_request_rate_limit':
        return 'errors.over_request_rate_limit';
      case 'over_email_send_rate_limit':
        return 'errors.over_email_send_rate_limit';
      case 'over_sms_send_rate_limit':
        return 'errors.over_sms_send_rate_limit';

      // OTP errors
      case 'otp_expired':
        return 'errors.otp_expired';
      case 'otp_disabled':
        return 'errors.otp_disabled';

      // Phone errors
      case 'phone_exists':
        return 'errors.phone_exists';
      case 'sms_send_failed':
        return 'errors.sms_send_failed';

      // MFA errors
      case 'mfa_challenge_expired':
        return 'errors.mfa_challenge_expired';
      case 'mfa_verification_failed':
        return 'errors.mfa_verification_failed';
      case 'mfa_verification_rejected':
        return 'errors.mfa_verification_rejected';
      case 'insufficient_aal':
        return 'errors.insufficient_aal';

      // Signup/Invite errors
      case 'signup_disabled':
        return 'errors.signup_disabled';
      case 'invite_not_found':
        return 'errors.invite_not_found';

      // Identity errors
      case 'identity_already_exists':
        return 'errors.identity_already_exists';
      case 'identity_not_found':
        return 'errors.identity_not_found';
      case 'single_identity_not_deletable':
        return 'errors.single_identity_not_deletable';

      // SAML/SSO errors
      case 'saml_provider_disabled':
        return 'errors.saml_provider_disabled';
      case 'sso_provider_not_found':
        return 'errors.sso_provider_not_found';
      case 'user_sso_managed':
        return 'errors.user_sso_managed';

      // Validation errors
      case 'validation_failed':
        return 'errors.validation_failed';
      case 'bad_json':
        return 'errors.bad_json';
      case 'bad_jwt':
        return 'errors.bad_jwt';

      // CAPTCHA errors
      case 'captcha_failed':
        return 'errors.captcha_failed';

      // Flow state errors
      case 'flow_state_expired':
        return 'errors.flow_state_expired';
      case 'flow_state_not_found':
        return 'errors.flow_state_not_found';

      // Authorization errors
      case 'no_authorization':
        return 'errors.no_authorization';
      case 'not_admin':
        return 'errors.not_admin';

      // Server errors
      case 'unexpected_failure':
        return 'errors.unexpected_failure';
      case 'request_timeout':
        return 'errors.request_timeout';

      // Default fallback
      default:
        return 'errors.unknown_error';
    }
  }
}
