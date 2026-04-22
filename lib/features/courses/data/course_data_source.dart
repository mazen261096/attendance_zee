import '../../../core/services/supabase_service.dart';

abstract class BaseCourseDataSource {
  // ── Courses ──
  Future<List<Map<String, dynamic>>> getMyCourses();
  Future<Map<String, dynamic>> getCourse({required String courseId});
  Future<Map<String, dynamic>> createCourse({
    required String name,
    String? description,
    required String code,
  });
  Future<Map<String, dynamic>> updateCourse({
    required String courseId,
    String? name,
    String? description,
  });
  Future<void> deleteCourse({required String courseId});

  // ── Members ──
  Future<List<Map<String, dynamic>>> getCourseMembers({required String courseId});
  Future<void> removeMember({required String memberId});
  Future<void> updateMemberRole({
    required String memberId,
    required String role,
  });

  // ── Join Requests ──
  Future<Map<String, dynamic>> joinCourseByCode({required String code});
  Future<List<Map<String, dynamic>>> getJoinRequests({required String courseId});
  Future<Map<String, dynamic>> approveJoinRequest({required String requestId});
  Future<Map<String, dynamic>> rejectJoinRequest({required String requestId});

  // ── Course Files ──
  Future<List<Map<String, dynamic>>> getCourseFiles({required String courseId});
  Future<Map<String, dynamic>> uploadCourseFile({
    required String courseId,
    required String fileUrl,
    required String fileName,
  });
  Future<void> deleteCourseFile({required String fileId});

  // ── Attendance Summary ──
  Future<Map<String, dynamic>> getAttendanceSummary({required String courseId});
}

class CourseDataSource implements BaseCourseDataSource {
  final SupabaseService supabaseService;

  const CourseDataSource({required this.supabaseService});

  // ──────────────────────────────────────────────
  // Courses
  // ──────────────────────────────────────────────

  @override
  Future<List<Map<String, dynamic>>> getMyCourses() async {
    final userId = SupabaseService.client.auth.currentUser!.id;

    // Get all courses where I'm a member
    final memberRows = await SupabaseService.client
        .from('course_members')
        .select('course_id, role')
        .eq('user_id', userId);

    if (memberRows.isEmpty) return [];

    final courseIds =
        memberRows.map((row) => row['course_id'] as String).toList();

    final courses = await SupabaseService.client
        .from('courses')
        .select()
        .inFilter('id', courseIds)
        .order('created_at', ascending: false);

    // Attach role to each course
    final roleMap = {
      for (final row in memberRows) row['course_id'] as String: row['role']
    };

    return courses.map((course) {
      return {
        ...course,
        'my_role': roleMap[course['id']],
      };
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> getCourse({required String courseId}) async {
    final response = await SupabaseService.client
        .from('courses')
        .select()
        .eq('id', courseId)
        .single();

    return response;
  }

  @override
  Future<Map<String, dynamic>> createCourse({
    required String name,
    String? description,
    required String code,
  }) async {
    final userId = SupabaseService.client.auth.currentUser!.id;

    final response = await SupabaseService.client
        .from('courses')
        .insert({
          'name': name,
          'description': description,
          'code': code,
          'owner_id': userId,
        })
        .select()
        .single();

    return response;
  }

  @override
  Future<Map<String, dynamic>> updateCourse({
    required String courseId,
    String? name,
    String? description,
  }) async {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;

    final response = await SupabaseService.client
        .from('courses')
        .update(data)
        .eq('id', courseId)
        .select()
        .single();

    return response;
  }

  @override
  Future<void> deleteCourse({required String courseId}) async {
    await SupabaseService.client.from('courses').delete().eq('id', courseId);
  }

  // ──────────────────────────────────────────────
  // Members
  // ──────────────────────────────────────────────

  @override
  Future<List<Map<String, dynamic>>> getCourseMembers({
    required String courseId,
  }) async {
    final response = await SupabaseService.client
        .from('course_members')
        .select('*, profiles(name, avatar_url)')
        .eq('course_id', courseId)
        .order('joined_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> removeMember({required String memberId}) async {
    await SupabaseService.client
        .from('course_members')
        .delete()
        .eq('id', memberId);
  }

  @override
  Future<void> updateMemberRole({
    required String memberId,
    required String role,
  }) async {
    await SupabaseService.client
        .from('course_members')
        .update({'role': role})
        .eq('id', memberId);
  }

  // ──────────────────────────────────────────────
  // Join Requests
  // ──────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> joinCourseByCode({required String code}) async {
    final response = await SupabaseService.client.rpc(
      'join_course_by_code',
      params: {'p_code': code},
    );
    return Map<String, dynamic>.from(response as Map);
  }

  @override
  Future<List<Map<String, dynamic>>> getJoinRequests({
    required String courseId,
  }) async {
    final response = await SupabaseService.client
        .from('join_requests')
        .select('*, profiles(name, avatar_url)')
        .eq('course_id', courseId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<Map<String, dynamic>> approveJoinRequest({
    required String requestId,
  }) async {
    final response = await SupabaseService.client.rpc(
      'approve_join_request',
      params: {'p_request_id': requestId},
    );
    return Map<String, dynamic>.from(response as Map);
  }

  @override
  Future<Map<String, dynamic>> rejectJoinRequest({
    required String requestId,
  }) async {
    final response = await SupabaseService.client.rpc(
      'reject_join_request',
      params: {'p_request_id': requestId},
    );
    return Map<String, dynamic>.from(response as Map);
  }

  // ──────────────────────────────────────────────
  // Course Files
  // ──────────────────────────────────────────────

  @override
  Future<List<Map<String, dynamic>>> getCourseFiles({
    required String courseId,
  }) async {
    final response = await SupabaseService.client
        .from('course_files')
        .select()
        .eq('course_id', courseId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<Map<String, dynamic>> uploadCourseFile({
    required String courseId,
    required String fileUrl,
    required String fileName,
  }) async {
    final userId = SupabaseService.client.auth.currentUser!.id;

    final response = await SupabaseService.client
        .from('course_files')
        .insert({
          'course_id': courseId,
          'file_url': fileUrl,
          'file_name': fileName,
          'uploaded_by': userId,
        })
        .select()
        .single();

    return response;
  }

  @override
  Future<void> deleteCourseFile({required String fileId}) async {
    await SupabaseService.client.from('course_files').delete().eq('id', fileId);
  }

  // ──────────────────────────────────────────────
  // Attendance Summary
  // ──────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> getAttendanceSummary({
    required String courseId,
  }) async {
    // 1. Get all course members with profiles
    final members = await SupabaseService.client
        .from('course_members')
        .select('user_id, profiles(name, avatar_url)')
        .eq('course_id', courseId);

    // 2. Get total lectures count
    final lectures = await SupabaseService.client
        .from('lectures')
        .select('id')
        .eq('course_id', courseId);
    final totalLectures = lectures.length;

    // 3. Get all attendance records for this course's lectures
    final lectureIds = lectures.map((l) => l['id'] as String).toList();
    List<Map<String, dynamic>> attendanceRecords = [];
    if (lectureIds.isNotEmpty) {
      attendanceRecords = await SupabaseService.client
          .from('lecture_attendance')
          .select('user_id')
          .inFilter('lecture_id', lectureIds)
          .eq('status', 'present');
    }

    // 4. Count attendance per member
    final Map<String, int> attendanceCount = {};
    for (final record in attendanceRecords) {
      final uid = record['user_id'] as String;
      attendanceCount[uid] = (attendanceCount[uid] ?? 0) + 1;
    }

    // 5. Build result
    final List<Map<String, dynamic>> result = [];
    for (final m in List<Map<String, dynamic>>.from(members)) {
      final uid = m['user_id'] as String;
      final profile = m['profiles'] as Map<String, dynamic>?;
      result.add({
        'user_id': uid,
        'user_name': profile?['name'],
        'user_avatar_url': profile?['avatar_url'],
        'attended_count': attendanceCount[uid] ?? 0,
        'total_lectures': totalLectures,
      });
    }

    // Sort by attended_count descending
    result.sort((a, b) => (b['attended_count'] as int).compareTo(a['attended_count'] as int));

    return {
      'members': result,
      'total_lectures': totalLectures,
    };
  }
}
