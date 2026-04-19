import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/enums.dart';
import '../../../core/utils/either_extensions.dart';
import '../../../core/utils/core_utils.dart';
import '../data/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required this.repository}) : super(const ProfileState());

  final BaseProfileRepository repository;

  /// Global signal: bump this to notify any listener that the profile was updated.
  static final profileUpdated = ValueNotifier<int>(0);

  Future<void> getProfile({required String profileId}) async {
    emit(state.copyWith(
      getProfileState: RequestState.loading,
      getProfileError: '',
    ));

    try {
      final result = await repository.getProfile(profileId: profileId);

      result.fold(
        (failure) => emit(state.copyWith(
          getProfileState: RequestState.error,
          getProfileError: failure.message,
        )),
        (profile) => emit(state.copyWith(
          getProfileState: RequestState.loaded,
          profile: profile,
          getProfileError: '',
        )),
      );
    } catch (error, stack) {
      print('Error in getProfile: $error');
      print(stack);
      emit(state.copyWith(
        getProfileState: RequestState.error,
        getProfileError: error.toString(),
      ));
    }
  }

  Future<void> updateProfile({
    required String profileId,
    String? name,
    String? avatarUrl,
  }) async {
    emit(state.copyWith(
      updateProfileState: RequestState.loading,
      updateProfileError: '',
    ));

    try {
      final result = await repository.updateProfile(
        profileId: profileId,
        name: name,
        avatarUrl: avatarUrl,
      );

      result.showSnackBarOnError().fold(
        (failure) => emit(state.copyWith(
          updateProfileState: RequestState.error,
          updateProfileError: failure.message,
        )),
        (profile) {
          emit(state.copyWith(
            updateProfileState: RequestState.loaded,
            profile: profile,
            updateProfileError: '',
          ));
          profileUpdated.value++;
        },
      );
    } catch (error, stack) {
      print('Error in updateProfile: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        updateProfileState: RequestState.error,
        updateProfileError: error.toString(),
      ));
    }
  }

  Future<void> uploadAvatar({
    required String userId,
    required XFile file,
  }) async {
    emit(state.copyWith(
      uploadAvatarState: RequestState.loading,
      uploadAvatarError: '',
    ));

    try {
      final result = await repository.uploadAvatar(userId: userId, file: file);

      await result.showSnackBarOnError().fold(
        (failure) {
          emit(state.copyWith(
            uploadAvatarState: RequestState.error,
            uploadAvatarError: failure.message,
          ));
        },
        (avatarUrl) async {
          await updateProfile(profileId: userId, avatarUrl: avatarUrl);
          emit(state.copyWith(
            uploadAvatarState: RequestState.loaded,
            uploadAvatarError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in uploadAvatar: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        uploadAvatarState: RequestState.error,
        uploadAvatarError: error.toString(),
      ));
    }
  }

  void resetUpdateState() {
    emit(state.copyWith(
      updateProfileState: RequestState.initial,
      updateProfileError: '',
    ));
  }

  void resetUploadAvatarState() {
    emit(state.copyWith(
      uploadAvatarState: RequestState.initial,
      uploadAvatarError: '',
    ));
  }
}
