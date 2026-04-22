import '../../../core/services/supabase_service.dart';

abstract class BaseGradeDataSource {
  // ── Grade Items ──
  Future<List<Map<String, dynamic>>> getCourseGradeItems({
    required String courseId,
  });
  Future<Map<String, dynamic>> createGradeItem({
    required String courseId,
    required String name,
    required String type,
    required double maxDegree,
  });
  Future<Map<String, dynamic>> updateGradeItem({
    required String gradeItemId,
    String? name,
    String? type,
    double? maxDegree,
  });
  Future<void> deleteGradeItem({required String gradeItemId});

  // ── Student Grades ──
  Future<List<Map<String, dynamic>>> getGradesForItem({
    required String gradeItemId,
  });
  Future<List<Map<String, dynamic>>> getMyGrades({required String courseId});
  Future<List<Map<String, dynamic>>> getAllMyGrades();
  Future<Map<String, dynamic>> setStudentGrade({
    required String gradeItemId,
    required String userId,
    required double degree,
  });
  Future<void> deleteStudentGrade({required String gradeId});

  // ── Course Members (for grading) ──
  Future<List<Map<String, dynamic>>> getCourseMembersForGrading({
    required String courseId,
  });
  Future<List<Map<String, dynamic>>> getTotalGrades({
    required String courseId,
  });
}

class GradeDataSource implements BaseGradeDataSource {
  final SupabaseService supabaseService;

  const GradeDataSource({required this.supabaseService});

  // ──────────────────────────────────────────────
  // Grade Items
  // ──────────────────────────────────────────────

  @override
  Future<List<Map<String, dynamic>>> getCourseGradeItems({
    required String courseId,
  }) async {
    final response = await SupabaseService.client
        .from('grade_items')
        .select()
        .eq('course_id', courseId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<Map<String, dynamic>> createGradeItem({
    required String courseId,
    required String name,
    required String type,
    required double maxDegree,
  }) async {
    final userId = SupabaseService.client.auth.currentUser!.id;

    final response = await SupabaseService.client
        .from('grade_items')
        .insert({
          'course_id': courseId,
          'name': name,
          'type': type,
          'max_degree': maxDegree,
          'created_by': userId,
        })
        .select()
        .single();

    return response;
  }

  @override
  Future<Map<String, dynamic>> updateGradeItem({
    required String gradeItemId,
    String? name,
    String? type,
    double? maxDegree,
  }) async {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (type != null) data['type'] = type;
    if (maxDegree != null) data['max_degree'] = maxDegree;

    final response = await SupabaseService.client
        .from('grade_items')
        .update(data)
        .eq('id', gradeItemId)
        .select()
        .single();

    return response;
  }

  @override
  Future<void> deleteGradeItem({required String gradeItemId}) async {
    await SupabaseService.client
        .from('grade_items')
        .delete()
        .eq('id', gradeItemId);
  }

  // ──────────────────────────────────────────────
  // Student Grades
  // ──────────────────────────────────────────────

  @override
  Future<List<Map<String, dynamic>>> getGradesForItem({
    required String gradeItemId,
  }) async {
    final response = await SupabaseService.client
        .from('student_grades')
        .select('*, profiles!student_grades_user_id_fkey(name, avatar_url)')
        .eq('grade_item_id', gradeItemId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getMyGrades({
    required String courseId,
  }) async {
    final userId = SupabaseService.client.auth.currentUser!.id;

    final response = await SupabaseService.client
        .from('student_grades')
        .select('*, grade_items(name, max_degree, type)')
        .eq('user_id', userId)
        .eq('grade_items.course_id', courseId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllMyGrades() async {
    final userId = SupabaseService.client.auth.currentUser!.id;

    final response = await SupabaseService.client
        .from('student_grades')
        .select('*, grade_items!inner(name, max_degree, type, course_id, courses(name))')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<Map<String, dynamic>> setStudentGrade({
    required String gradeItemId,
    required String userId,
    required double degree,
  }) async {
    final currentUserId = SupabaseService.client.auth.currentUser!.id;

    final response = await SupabaseService.client
        .from('student_grades')
        .upsert(
          {
            'grade_item_id': gradeItemId,
            'user_id': userId,
            'degree': degree,
            'created_by': currentUserId,
          },
          onConflict: 'grade_item_id,user_id',
        )
        .select('*, profiles!student_grades_user_id_fkey(name, avatar_url)')
        .single();

    return response;
  }

  @override
  Future<void> deleteStudentGrade({required String gradeId}) async {
    await SupabaseService.client
        .from('student_grades')
        .delete()
        .eq('id', gradeId);
  }

  @override
  Future<List<Map<String, dynamic>>> getCourseMembersForGrading({
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
  Future<List<Map<String, dynamic>>> getTotalGrades({
    required String courseId,
  }) async {
    final response = await SupabaseService.client
        .from('course_members')
        .select('*, profiles(name, avatar_url)')
        .eq('course_id', courseId)
        .order('total_degree', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}
