import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../../../core/utils/image_compress_helper.dart';

abstract class BaseProfileDataSource {
  Future<Map<String, dynamic>> getProfile({required String profileId});

  Future<Map<String, dynamic>> updateProfile({
    required String profileId,
    String? name,
    String? avatarUrl,
    String? preferredTheme,
    String? preferredLanguage,
  });

  Future<String> uploadAvatar({required String userId, required XFile file});
}

class ProfileDataSource implements BaseProfileDataSource {
  final SupabaseService supabaseService;

  const ProfileDataSource({required this.supabaseService});

  @override
  Future<Map<String, dynamic>> getProfile({required String profileId}) async {
    final response = await SupabaseService.client
        .from('profiles')
        .select()
        .eq('id', profileId)
        .single();

    return response;
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String profileId,
    String? name,
    String? avatarUrl,
    String? preferredTheme,
    String? preferredLanguage,
  }) async {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;
    if (preferredTheme != null) data['preferred_theme'] = preferredTheme;
    if (preferredLanguage != null) data['preferred_language'] = preferredLanguage;

    final response = await SupabaseService.client
        .from('profiles')
        .update(data)
        .eq('id', profileId)
        .select()
        .single();

    return response;
  }

  @override
  Future<String> uploadAvatar({
    required String userId,
    required XFile file,
  }) async {
    final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storagePath = '$userId/$fileName';

    // Delete old avatar if exists
    try {
      final existingFiles = await SupabaseService.client.storage
          .from('avatars')
          .list(path: userId);

      if (existingFiles.isNotEmpty) {
        final filesToDelete =
            existingFiles.map((f) => '$userId/${f.name}').toList();
        await SupabaseService.client.storage
            .from('avatars')
            .remove(filesToDelete);
      }
    } catch (e) {
      print('Error deleting old avatar: $e');
    }

    final Uint8List rawBytes = await file.readAsBytes();
    final Uint8List bytes = compressImageBytes(rawBytes);

    await SupabaseService.client.storage.from('avatars').uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
            cacheControl: '31536000',
          ),
        );

    final publicUrl =
        SupabaseService.client.storage.from('avatars').getPublicUrl(storagePath);

    return publicUrl;
  }
}
