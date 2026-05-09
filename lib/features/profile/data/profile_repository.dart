import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/failure.dart';
import '../../../core/utils/supabase_error_mapper.dart';
import 'models/profile_model.dart';
import 'profile_data_source.dart';

abstract class BaseProfileRepository {
  Future<Either<Failure, ProfileModel>> getProfile({required String profileId});

  Future<Either<Failure, ProfileModel>> updateProfile({
    required String profileId,
    String? name,
    String? avatarUrl,
    String? preferredTheme,
    String? preferredLanguage,
  });

  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required XFile file,
  });
}

class ProfileRepository implements BaseProfileRepository {
  final BaseProfileDataSource dataSource;

  ProfileRepository({required this.dataSource});

  @override
  Future<Either<Failure, ProfileModel>> getProfile({
    required String profileId,
  }) async {
    try {
      final result = await dataSource.getProfile(profileId: profileId);
      final profile = ProfileModel.fromJson(result);
      return Right(profile);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in getProfile: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, ProfileModel>> updateProfile({
    required String profileId,
    String? name,
    String? avatarUrl,
    String? preferredTheme,
    String? preferredLanguage,
  }) async {
    try {
      final result = await dataSource.updateProfile(
        profileId: profileId,
        name: name,
        avatarUrl: avatarUrl,
        preferredTheme: preferredTheme,
        preferredLanguage: preferredLanguage,
      );
      final profile = ProfileModel.fromJson(result);
      return Right(profile);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in updateProfile: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required XFile file,
  }) async {
    try {
      final avatarUrl = await dataSource.uploadAvatar(
        userId: userId,
        file: file,
      );
      return Right(avatarUrl);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in uploadAvatar: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }
}
