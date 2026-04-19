import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/secure_storage/secure_storage_helper.dart';
import '../../../core/utils/failure.dart';
import '../../../core/utils/supabase_error_mapper.dart';
import '../../../core/services/supabase_service.dart';
import 'auth_data_source.dart';
import 'models/user_model.dart';

abstract class BaseAuthRepository {
  Future<Either<Failure, UserModel>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserModel>> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> signOut();

  Future<bool> isAuthenticated();
  Future<UserModel?> getCurrentUser();

  Future<Either<Failure, void>> changePassword({required String newPassword});
  Future<Either<Failure, void>> resetPassword({required String email});
}

class AuthRepository implements BaseAuthRepository {
  final BaseAuthDataSource dataSource;

  AuthRepository({required this.dataSource});

  @override
  Future<Either<Failure, UserModel>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dataSource.signInWithEmail(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return const Left(Failure(message: 'errors.auth_error'));
      }

      final user = response.user!;
      final userModel = UserModel(
        id: user.id,
        email: user.email,
        name: user.userMetadata?['name'],
        avatarUrl: user.userMetadata?['avatar_url'],
        createdAt: user.createdAt != null
            ? DateTime.parse(user.createdAt)
            : DateTime.now(),
      );

      await _saveAuthData(
        accessToken: response.session?.accessToken ?? '',
        refreshToken: response.session?.refreshToken,
        userData: userModel.toJson(),
      );

      return Right(userModel);
    } on Failure catch (e) {
      if (e.code == 'invalid_credentials') {
        return Left(Failure(
          message: 'errors.wrong_password'.tr(),
          code: 'wrong_password',
        ));
      }
      if (e.code == 'email_not_confirmed') {
        return Left(Failure(
          message: 'errors.email_not_confirmed'.tr(),
          code: 'email_not_confirmed',
        ));
      }
      return Left(e);
    } catch (e, stack) {
      print('Error in signInWithEmail: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dataSource.signUpWithEmail(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return const Left(Failure(message: 'errors.auth_error'));
      }

      final user = response.user!;

      final userModel = UserModel(
        id: user.id,
        email: user.email,
        name: user.userMetadata?['name'] ?? user.email,
        avatarUrl: user.userMetadata?['avatar_url'],
        createdAt: user.createdAt != null
            ? DateTime.parse(user.createdAt)
            : DateTime.now(),
      );

      if (response.session != null) {
        await _saveAuthData(
          accessToken: response.session!.accessToken,
          refreshToken: response.session!.refreshToken,
          userData: userModel.toJson(),
        );
      }

      return Right(userModel);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in signUpWithEmail: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await dataSource.signOut();
      await _deleteAuthData();
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in signOut: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final hasTokens = await SecureStorageHelper.hasValidTokens();
      final currentUser = dataSource.getCurrentUser();
      return hasTokens && currentUser != null;
    } catch (e, stack) {
      print('Error in isAuthenticated: $e');
      print(stack);
      return false;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final userJson = await SecureStorageHelper.getUserData();
      return userJson != null ? UserModel.fromJson(userJson) : null;
    } catch (e, stack) {
      print('Error in getCurrentUser: $e');
      print(stack);
      return null;
    }
  }

  Future<void> _saveAuthData({
    required String accessToken,
    String? refreshToken,
    required Map<String, dynamic> userData,
  }) async {
    await Future.wait([
      SecureStorageHelper.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      ),
      SecureStorageHelper.saveUserData(userData),
    ]);
  }

  Future<void> _deleteAuthData() async {
    await Future.wait([
      SecureStorageHelper.clearTokens(),
      SecureStorageHelper.clearUserData(),
    ]);
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String newPassword,
  }) async {
    try {
      await SupabaseService.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in changePassword: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String email}) async {
    try {
      await dataSource.resetPassword(email: email);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in resetPassword: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }
}
