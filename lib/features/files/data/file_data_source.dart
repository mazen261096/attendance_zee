import '../../../../core/services/supabase_service.dart';


// ─────────────────────────────────────────────────────────────────────────────
// FileDataSource — handles all Supabase metadata operations for files.
// The actual binary upload is performed by FileUploadService (Step 2).
// ─────────────────────────────────────────────────────────────────────────────

abstract class BaseFileDataSource {
  // Merged: course files + all lecture files under the course
  Future<List<Map<String, dynamic>>> getCourseFilesWithLectures({
    required String courseId,
  });

  // Lecture-scoped only
  Future<List<Map<String, dynamic>>> getLectureFiles({
    required String lectureId,
  });

  // Insert course-level file metadata after upload
  Future<Map<String, dynamic>> insertCourseFileMetadata({
    required String courseId,
    required String objectKey,
    required String fileName,
    required String contentType,
    required int fileSize,
  });

  // Insert lecture-level file metadata after upload
  Future<Map<String, dynamic>> insertLectureFileMetadata({
    required String lectureId,
    required String objectKey,
    required String fileName,
    required String contentType,
    required int fileSize,
  });

  // Delete metadata row (caller also deletes from R2 via CloudflareService)
  Future<void> deleteCourseFileMeta({required String fileId});
  Future<void> deleteLectureFileMeta({required String fileId});
}

class FileDataSource implements BaseFileDataSource {
  const FileDataSource({required this.supabaseService});

  final SupabaseService supabaseService;

  // ─────────────────────────────────────────────────────────────────────────
  // Queries
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<List<Map<String, dynamic>>> getCourseFilesWithLectures({
    required String courseId,
  }) async {
    final response = await SupabaseService.client.rpc(
      'get_course_files_with_lectures',
      params: {'p_course_id': courseId},
    );
    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<List<Map<String, dynamic>>> getLectureFiles({
    required String lectureId,
  }) async {
    final response = await SupabaseService.client
        .from('lecture_files')
        .select()
        .eq('lecture_id', lectureId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Inserts (after successful R2 upload)
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> insertCourseFileMetadata({
    required String courseId,
    required String objectKey,
    required String fileName,
    required String contentType,
    required int fileSize,
  }) async {
    final userId = SupabaseService.client.auth.currentUser!.id;

    final response = await SupabaseService.client
        .from('course_files')
        .insert({
          'course_id': courseId,
          'object_key': objectKey,
          'file_name': fileName,
          'file_url': objectKey, // kept for backward compat
          'content_type': contentType,
          'file_size': fileSize,
          'uploaded_by': userId,
        })
        .select()
        .single();

    return response;
  }

  @override
  Future<Map<String, dynamic>> insertLectureFileMetadata({
    required String lectureId,
    required String objectKey,
    required String fileName,
    required String contentType,
    required int fileSize,
  }) async {
    final userId = SupabaseService.client.auth.currentUser!.id;

    final response = await SupabaseService.client
        .from('lecture_files')
        .insert({
          'lecture_id': lectureId,
          'object_key': objectKey,
          'file_name': fileName,
          'file_url': objectKey, // kept for backward compat
          'content_type': contentType,
          'file_size': fileSize,
          'uploaded_by': userId,
        })
        .select()
        .single();

    return response;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Deletes
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> deleteCourseFileMeta({required String fileId}) async {
    await SupabaseService.client
        .from('course_files')
        .delete()
        .eq('id', fileId);
  }

  @override
  Future<void> deleteLectureFileMeta({required String fileId}) async {
    await SupabaseService.client
        .from('lecture_files')
        .delete()
        .eq('id', fileId);
  }
}
