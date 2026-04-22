import 'package:dartz/dartz.dart';
import '../../../core/utils/failure.dart';
import '../../../core/utils/supabase_error_mapper.dart';
import 'grade_data_source.dart';
import 'models/grade_item_model.dart';
import 'models/student_grade_model.dart';

abstract class BaseGradeRepository {
  // ── Grade Items ──
  Future<Either<Failure, List<GradeItemModel>>> getCourseGradeItems({
    required String courseId,
  });
  Future<Either<Failure, GradeItemModel>> createGradeItem({
    required String courseId,
    required String name,
    required String type,
    required double maxDegree,
  });
  Future<Either<Failure, GradeItemModel>> updateGradeItem({
    required String gradeItemId,
    String? name,
    String? type,
    double? maxDegree,
  });
  Future<Either<Failure, void>> deleteGradeItem({
    required String gradeItemId,
  });

  // ── Student Grades ──
  Future<Either<Failure, List<StudentGradeModel>>> getGradesForItem({
    required String gradeItemId,
  });
  Future<Either<Failure, List<StudentGradeModel>>> getMyGrades({
    required String courseId,
  });
  Future<Either<Failure, List<StudentGradeModel>>> getAllMyGrades();
  Future<Either<Failure, StudentGradeModel>> setStudentGrade({
    required String gradeItemId,
    required String userId,
    required double degree,
  });
  Future<Either<Failure, void>> deleteStudentGrade({
    required String gradeId,
  });

  // ── Course Members (for grading) ──
  Future<Either<Failure, List<Map<String, dynamic>>>> getCourseMembersForGrading({
    required String courseId,
  });
  Future<Either<Failure, List<Map<String, dynamic>>>> getTotalGrades({
    required String courseId,
  });
}

class GradeRepository implements BaseGradeRepository {
  final BaseGradeDataSource dataSource;

  GradeRepository({required this.dataSource});

  // ──────────────────────────────────────────────
  // Grade Items
  // ──────────────────────────────────────────────

  @override
  Future<Either<Failure, List<GradeItemModel>>> getCourseGradeItems({
    required String courseId,
  }) async {
    try {
      final result = await dataSource.getCourseGradeItems(courseId: courseId);
      final items = result.map((e) => GradeItemModel.fromJson(e)).toList();
      return Right(items);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in getCourseGradeItems: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, GradeItemModel>> createGradeItem({
    required String courseId,
    required String name,
    required String type,
    required double maxDegree,
  }) async {
    try {
      final result = await dataSource.createGradeItem(
        courseId: courseId,
        name: name,
        type: type,
        maxDegree: maxDegree,
      );
      return Right(GradeItemModel.fromJson(result));
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in createGradeItem: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, GradeItemModel>> updateGradeItem({
    required String gradeItemId,
    String? name,
    String? type,
    double? maxDegree,
  }) async {
    try {
      final result = await dataSource.updateGradeItem(
        gradeItemId: gradeItemId,
        name: name,
        type: type,
        maxDegree: maxDegree,
      );
      return Right(GradeItemModel.fromJson(result));
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in updateGradeItem: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGradeItem({
    required String gradeItemId,
  }) async {
    try {
      await dataSource.deleteGradeItem(gradeItemId: gradeItemId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in deleteGradeItem: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  // ──────────────────────────────────────────────
  // Student Grades
  // ──────────────────────────────────────────────

  @override
  Future<Either<Failure, List<StudentGradeModel>>> getGradesForItem({
    required String gradeItemId,
  }) async {
    try {
      final result =
          await dataSource.getGradesForItem(gradeItemId: gradeItemId);
      final grades =
          result.map((e) => StudentGradeModel.fromJson(e)).toList();
      return Right(grades);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in getGradesForItem: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, List<StudentGradeModel>>> getMyGrades({
    required String courseId,
  }) async {
    try {
      final result = await dataSource.getMyGrades(courseId: courseId);
      final grades =
          result.map((e) => StudentGradeModel.fromJson(e)).toList();
      return Right(grades);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in getMyGrades: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, List<StudentGradeModel>>> getAllMyGrades() async {
    try {
      final result = await dataSource.getAllMyGrades();
      final grades =
          result.map((e) => StudentGradeModel.fromJson(e)).toList();
      return Right(grades);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in getAllMyGrades: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, StudentGradeModel>> setStudentGrade({
    required String gradeItemId,
    required String userId,
    required double degree,
  }) async {
    try {
      final result = await dataSource.setStudentGrade(
        gradeItemId: gradeItemId,
        userId: userId,
        degree: degree,
      );
      return Right(StudentGradeModel.fromJson(result));
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in setStudentGrade: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStudentGrade({
    required String gradeId,
  }) async {
    try {
      await dataSource.deleteStudentGrade(gradeId: gradeId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in deleteStudentGrade: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getCourseMembersForGrading({
    required String courseId,
  }) async {
    try {
      final result =
          await dataSource.getCourseMembersForGrading(courseId: courseId);
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in getCourseMembersForGrading: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTotalGrades({
    required String courseId,
  }) async {
    try {
      final result = await dataSource.getTotalGrades(courseId: courseId);
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in getTotalGrades: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }
}
