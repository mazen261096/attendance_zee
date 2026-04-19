import '../../../core/services/supabase_service.dart';

abstract class BaseLectureDataSource {
  // ── Lectures ──
  Future<List<Map<String, dynamic>>> getCourseLectures({
    required String courseId,
  });
  Future<Map<String, dynamic>> getLecture({required String lectureId});
  Future<Map<String, dynamic>> createLecture({
    required String courseId,
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
  });
  Future<Map<String, dynamic>> updateLecture({
    required String lectureId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
  });
  Future<void> deleteLecture({required String lectureId});
  Future<Map<String, dynamic>> toggleAttendance({
    required String lectureId,
    required bool isOpen,
  });

  // ── Lecture Files ──
  Future<List<Map<String, dynamic>>> getLectureFiles({
    required String lectureId,
  });
  Future<Map<String, dynamic>> addLectureFile({
    required String lectureId,
    required String fileUrl,
    required String fileName,
  });
  Future<void> deleteLectureFile({required String fileId});

  // ── Attendance ──
  Future<List<Map<String, dynamic>>> getLectureAttendance({
    required String lectureId,
  });
  Future<Map<String, dynamic>> checkIn({required String lectureId});
  Future<void> updateAttendanceStatus({
    required String attendanceId,
    required String status,
  });
}

class LectureDataSource implements BaseLectureDataSource {
  final SupabaseService supabaseService;

  const LectureDataSource({required this.supabaseService});

  // ──────────────────────────────────────────────
  // Lectures
  // ──────────────────────────────────────────────

  @override
  Future<List<Map<String, dynamic>>> getCourseLectures({
    required String courseId,
  }) async {
    final response = await SupabaseService.client
        .from('lectures')
        .select()
        .eq('course_id', courseId)
        .order('start_time', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<Map<String, dynamic>> getLecture({required String lectureId}) async {
    final response = await SupabaseService.client
        .from('lectures')
        .select()
        .eq('id', lectureId)
        .single();

    return response;
  }

  @override
  Future<Map<String, dynamic>> createLecture({
    required String courseId,
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final userId = SupabaseService.client.auth.currentUser!.id;

    final response = await SupabaseService.client
        .from('lectures')
        .insert({
          'course_id': courseId,
          'title': title,
          'description': description,
          'start_time': startTime.toUtc().toIso8601String(),
          'end_time': endTime.toUtc().toIso8601String(),
          'is_attendance_open': false,
          'created_by': userId,
        })
        .select()
        .single();

    return response;
  }

  @override
  Future<Map<String, dynamic>> updateLecture({
    required String lectureId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final Map<String, dynamic> data = {};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (startTime != null) data['start_time'] = startTime.toUtc().toIso8601String();
    if (endTime != null) data['end_time'] = endTime.toUtc().toIso8601String();

    final response = await SupabaseService.client
        .from('lectures')
        .update(data)
        .eq('id', lectureId)
        .select()
        .single();

    return response;
  }

  @override
  Future<void> deleteLecture({required String lectureId}) async {
    await SupabaseService.client.from('lectures').delete().eq('id', lectureId);
  }

  @override
  Future<Map<String, dynamic>> toggleAttendance({
    required String lectureId,
    required bool isOpen,
  }) async {
    final response = await SupabaseService.client
        .from('lectures')
        .update({'is_attendance_open': isOpen})
        .eq('id', lectureId)
        .select()
        .single();

    return response;
  }

  // ──────────────────────────────────────────────
  // Lecture Files
  // ──────────────────────────────────────────────

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

  @override
  Future<Map<String, dynamic>> addLectureFile({
    required String lectureId,
    required String fileUrl,
    required String fileName,
  }) async {
    final userId = SupabaseService.client.auth.currentUser!.id;

    final response = await SupabaseService.client
        .from('lecture_files')
        .insert({
          'lecture_id': lectureId,
          'file_url': fileUrl,
          'file_name': fileName,
          'uploaded_by': userId,
        })
        .select()
        .single();

    return response;
  }

  @override
  Future<void> deleteLectureFile({required String fileId}) async {
    await SupabaseService.client
        .from('lecture_files')
        .delete()
        .eq('id', fileId);
  }

  // ──────────────────────────────────────────────
  // Attendance
  // ──────────────────────────────────────────────

  @override
  Future<List<Map<String, dynamic>>> getLectureAttendance({
    required String lectureId,
  }) async {
    final response = await SupabaseService.client
        .from('lecture_attendance')
        .select('*, profiles(name, avatar_url)')
        .eq('lecture_id', lectureId)
        .order('checked_in_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<Map<String, dynamic>> checkIn({required String lectureId}) async {
    final userId = SupabaseService.client.auth.currentUser!.id;

    final response = await SupabaseService.client
        .from('lecture_attendance')
        .insert({
          'lecture_id': lectureId,
          'user_id': userId,
          'status': 'present',
        })
        .select()
        .single();

    return response;
  }

  @override
  Future<void> updateAttendanceStatus({
    required String attendanceId,
    required String status,
  }) async {
    await SupabaseService.client
        .from('lecture_attendance')
        .update({'status': status})
        .eq('id', attendanceId);
  }
}
