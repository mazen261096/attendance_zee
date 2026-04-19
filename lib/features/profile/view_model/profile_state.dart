import 'package:equatable/equatable.dart';
import '../../../core/utils/enums.dart';
import '../data/models/profile_model.dart';

class ProfileState extends Equatable {
  final RequestState getProfileState;
  final String getProfileError;
  final ProfileModel? profile;

  final RequestState updateProfileState;
  final String updateProfileError;

  final RequestState uploadAvatarState;
  final String uploadAvatarError;

  const ProfileState({
    this.getProfileState = RequestState.initial,
    this.getProfileError = '',
    this.profile,
    this.updateProfileState = RequestState.initial,
    this.updateProfileError = '',
    this.uploadAvatarState = RequestState.initial,
    this.uploadAvatarError = '',
  });

  ProfileState copyWith({
    RequestState? getProfileState,
    String? getProfileError,
    ProfileModel? profile,
    RequestState? updateProfileState,
    String? updateProfileError,
    RequestState? uploadAvatarState,
    String? uploadAvatarError,
  }) {
    return ProfileState(
      getProfileState: getProfileState ?? this.getProfileState,
      getProfileError: getProfileError ?? this.getProfileError,
      profile: profile ?? this.profile,
      updateProfileState: updateProfileState ?? this.updateProfileState,
      updateProfileError: updateProfileError ?? this.updateProfileError,
      uploadAvatarState: uploadAvatarState ?? this.uploadAvatarState,
      uploadAvatarError: uploadAvatarError ?? this.uploadAvatarError,
    );
  }

  bool get isGetProfileLoading => getProfileState == RequestState.loading;
  bool get isGetProfileSuccess => getProfileState == RequestState.loaded;
  bool get hasGetProfileError => getProfileState == RequestState.error;

  bool get isUpdateProfileLoading => updateProfileState == RequestState.loading;
  bool get isUpdateProfileSuccess => updateProfileState == RequestState.loaded;
  bool get hasUpdateProfileError => updateProfileState == RequestState.error;

  bool get isUploadAvatarLoading => uploadAvatarState == RequestState.loading;
  bool get isUploadAvatarSuccess => uploadAvatarState == RequestState.loaded;
  bool get hasUploadAvatarError => uploadAvatarState == RequestState.error;

  @override
  List<Object?> get props => [
        getProfileState,
        getProfileError,
        profile,
        updateProfileState,
        updateProfileError,
        uploadAvatarState,
        uploadAvatarError,
      ];
}
