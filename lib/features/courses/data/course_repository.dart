import 'package:dartz/dartz.dart';
import '../../../core/utils/failure.dart';
import '../../../core/utils/supabase_error_mapper.dart';
import 'course_data_source.dart';
import 'models/course_model.dart';
import 'models/course_member_model.dart';
import 'models/join_request_model.dart';
import 'models/course_file_model.dart';

abstract class BaseCourseRepository {
  // ── Courses ──
  Future<Either<Failure, List<CourseModel>>> getMyCourses();
  Future<Either<Failure, CourseModel>> getCourse({required String courseId});
  Future<Either<Failure, CourseModel>> createCourse({
    required String name,
    String? description,
    required String code,
  });
  Future<Either<Failure, CourseModel>> updateCourse({
    required String courseId,
    String? name,
    String? description,
  });
  Future<Either<Failure, void>> deleteCourse({required String courseId});

  // ── Members ──
  Future<Either<Failure, List<CourseMemberModel>>> getCourseMembers({
    required String courseId,
  });
  Future<Either<Failure, void>> removeMember({required String memberId});
  Future<Either<Failure, void>> updateMemberRole({
    required String memberId,
    required String role,
  });

  // ── Join Requests ──
  Future<Either<Failure, Map<String, dynamic>>> joinCourseByCode({
    required String code,
  });
  Future<Either<Failure, List<JoinRequestModel>>> getJoinRequests({
    required String courseId,
  });
  Future<Either<Failure, Map<String, dynamic>>> approveJoinRequest({
    required String requestId,
  });
  Future<Either<Failure, Map<String, dynamic>>> rejectJoinRequest({
    required String requestId,
  });

  // ── Course Files ──
  Future<Either<Failure, List<CourseFileModel>>> getCourseFiles({
    required String courseId,
  });
  Future<Either<Failure, CourseFileModel>> uploadCourseFile({
    required String courseId,
    required String fileUrl,
    required String fileName,
  });
  Future<Either<Failure, void>> deleteCourseFile({required String fileId});

  // ── Attendance Summary ──
  Future<Either<Failure, Map<String, dynamic>>> getAttendanceSummary({
    required String courseId,
  });
}

class CourseRepository implements BaseCourseRepository {
  final BaseCourseDataSource dataSource;

  CourseRepository({required this.dataSource});

  // ──────────────────────────────────────────────
  // Courses
  // ──────────────────────────────────────────────

  @override
  Future<Either<Failure, List<CourseModel>>> getMyCourses() async {
    try {
      final result = await dataSource.getMyCourses();
      final courses = result.map((e) => CourseModel.fromJson(e)).toList();
      return Right(courses);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in getMyCourses: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, CourseModel>> getCourse({
    required String courseId,
  }) async {
    try {
      final result = await dataSource.getCourse(courseId: courseId);
      return Right(CourseModel.fromJson(result));
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in getCourse: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, CourseModel>> createCourse({
    required String name,
    String? description,
    required String code,
  }) async {
    try {
      final result = await dataSource.createCourse(
        name: name,
        description: description,
        code: code,
      );
      return Right(CourseModel.fromJson(result));
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in createCourse: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, CourseModel>> updateCourse({
    required String courseId,
    String? name,
    String? description,
  }) async {
    try {
      final result = await dataSource.updateCourse(
        courseId: courseId,
        name: name,
        description: description,
      );
      return Right(CourseModel.fromJson(result));
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in updateCourse: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCourse({
    required String courseId,
  }) async {
    try {
      await dataSource.deleteCourse(courseId: courseId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in deleteCourse: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  // ──────────────────────────────────────────────
  // Members
  // ──────────────────────────────────────────────

  @override
  Future<Either<Failure, List<CourseMemberModel>>> getCourseMembers({
    required String courseId,
  }) async {
    try {
      final result = await dataSource.getCourseMembers(courseId: courseId);
      final members =
          result.map((e) => CourseMemberModel.fromJson(e)).toList();
      return Right(members);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in getCourseMembers: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> removeMember({
    required String memberId,
  }) async {
    try {
      await dataSource.removeMember(memberId: memberId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in removeMember: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateMemberRole({
    required String memberId,
    required String role,
  }) async {
    try {
      await dataSource.updateMemberRole(memberId: memberId, role: role);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in updateMemberRole: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  // ──────────────────────────────────────────────
  // Join Requests
  // ──────────────────────────────────────────────

  @override
  Future<Either<Failure, Map<String, dynamic>>> joinCourseByCode({
    required String code,
  }) async {
    try {
      final result = await dataSource.joinCourseByCode(code: code);
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in joinCourseByCode: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, List<JoinRequestModel>>> getJoinRequests({
    required String courseId,
  }) async {
    try {
      final result = await dataSource.getJoinRequests(courseId: courseId);
      final requests =
          result.map((e) => JoinRequestModel.fromJson(e)).toList();
      return Right(requests);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in getJoinRequests: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> approveJoinRequest({
    required String requestId,
  }) async {
    try {
      final result =
          await dataSource.approveJoinRequest(requestId: requestId);
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in approveJoinRequest: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> rejectJoinRequest({
    required String requestId,
  }) async {
    try {
      final result =
          await dataSource.rejectJoinRequest(requestId: requestId);
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in rejectJoinRequest: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  // ──────────────────────────────────────────────
  // Course Files
  // ──────────────────────────────────────────────

  @override
  Future<Either<Failure, List<CourseFileModel>>> getCourseFiles({
    required String courseId,
  }) async {
    try {
      final result = await dataSource.getCourseFiles(courseId: courseId);
      final files = result.map((e) => CourseFileModel.fromJson(e)).toList();
      return Right(files);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in getCourseFiles: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, CourseFileModel>> uploadCourseFile({
    required String courseId,
    required String fileUrl,
    required String fileName,
  }) async {
    try {
      final result = await dataSource.uploadCourseFile(
        courseId: courseId,
        fileUrl: fileUrl,
        fileName: fileName,
      );
      return Right(CourseFileModel.fromJson(result));
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in uploadCourseFile: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCourseFile({
    required String fileId,
  }) async {
    try {
      await dataSource.deleteCourseFile(fileId: fileId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in deleteCourseFile: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  // ──────────────────────────────────────────────
  // Attendance Summary
  // ──────────────────────────────────────────────

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAttendanceSummary({
    required String courseId,
  }) async {
    try {
      final result = await dataSource.getAttendanceSummary(courseId: courseId);
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in getAttendanceSummary: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }
}
