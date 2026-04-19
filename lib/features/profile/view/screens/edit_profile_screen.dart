import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/enums.dart';
import '../../view_model/profile_cubit.dart';
import '../../view_model/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}



class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userId = SupabaseService().currentUser?.id;

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        // Initialize name controller once profile loads
        if (!_initialized && state.profile != null) {
          _nameController.text = state.profile!.name;
          _initialized = true;
        }

        // Pop on successful update
        if (state.updateProfileState == RequestState.loaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile updated successfully!'),
              backgroundColor: AppConfig.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        // Load profile if not loaded
        if (state.getProfileState == RequestState.initial && userId != null) {
          context.read<ProfileCubit>().getProfile(profileId: userId);
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'Edit Profile',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),
          body: state.getProfileState == RequestState.loading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          // Avatar
                          GestureDetector(
                            onTap: () => _pickAvatar(context, userId),
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppConfig.primaryColor,
                                        AppConfig.primaryLightColor,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppConfig.primaryColor
                                            .withValues(alpha: 0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: state.uploadAvatarState ==
                                          RequestState.loading
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : state.profile?.avatarUrl != null
                                          ? ClipOval(
                                              child: Image.network(
                                                state.profile!.avatarUrl!,
                                                fit: BoxFit.cover,
                                                width: 110,
                                                height: 110,
                                                errorBuilder: (_, __, ___) =>
                                                    _buildAvatarInitial(state),
                                              ),
                                            )
                                          : _buildAvatarInitial(state),
                                ),
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: AppConfig.primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.black
                                          : Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 36),
                          // Name Field
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Display Name',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              hintText: 'Enter your name',
                              prefixIcon:
                                  Icon(Icons.person_outline, size: 20),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Name is required';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) =>
                                _updateProfile(context, userId),
                          ),
                          const SizedBox(height: 16),
                          // Email (read-only)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Email',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue:
                                SupabaseService().currentUser?.email ?? '',
                            readOnly: true,
                            decoration: InputDecoration(
                              prefixIcon:
                                  const Icon(Icons.email_outlined, size: 20),
                              fillColor: isDark
                                  ? const Color(0xFF151520)
                                  : Colors.grey[200],
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Save Button
                          ElevatedButton(
                            onPressed: state.updateProfileState ==
                                    RequestState.loading
                                ? null
                                : () => _updateProfile(context, userId),
                            child: state.updateProfileState ==
                                    RequestState.loading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Save Changes'),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildAvatarInitial(ProfileState state) {
    final initial = (state.profile?.name ?? '?')[0].toUpperCase();
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 44,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  void _updateProfile(BuildContext context, String? userId) {
    if (userId == null) return;
    if (_formKey.currentState!.validate()) {
      context.read<ProfileCubit>().updateProfile(
            profileId: userId,
            name: _nameController.text.trim(),
          );
    }
  }

  Future<void> _pickAvatar(BuildContext context, String? userId) async {
    if (userId == null) return;
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image != null && context.mounted) {
      context.read<ProfileCubit>().uploadAvatar(
            userId: userId,
            file: image,
          );
    }
  }
}
