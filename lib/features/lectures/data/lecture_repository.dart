import 'package:dartz/dartz.dart';
import '../../../core/utils/failure.dart';
import '../../../core/utils/supabase_error_mapper.dart';
import 'lecture_data_source.dart';
import 'models/lecture_model.dart';
import 'models/lecture_file_model.dart';
import 'models/lecture_attendance_model.dart';

abstract class BaseLectureRepository {
  // ── Lectures ──
  Future<Either<Failure, List<LectureModel>>> getCourseLectures({
    required String courseId,
  });
  Future<Either<Failure, LectureModel>> getLecture({
    required String lectureId,
  });
  Future<Either<Failure, LectureModel>> createLecture({
    required String courseId,
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
  });
  Future<Either<Failure, LectureModel>> updateLecture({
    required String lectureId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
  });
  Future<Either<Failure, void>> deleteLecture({required String lectureId});
  Future<Either<Failure, LectureModel>> toggleAttendance({
    required String lectureId,
    required bool isOpen,
  });

  // ── Lecture Files ──
  Future<Either<Failure, List<LectureFileModel>>> getLectureFiles({
    required String lectureId,
  });
  Future<Either<Failure, LectureFileModel>> addLectureFile({
    required String lectureId,
    required String fileUrl,
    required String fileName,
  });
  Future<Either<Failure, void>> deleteLectureFile({required String fileId});

  // ── Attendance ──
  Future<Either<Failure, List<LectureAttendanceModel>>> getLectureAttendance({
    required String lectureId,
  });
  Future<Either<Failure, LectureAttendanceModel>> checkIn({
    required String lectureId,
  });
  Future<Either<Failure, void>> updateAttendanceStatus({
    required String attendanceId,
    required String status,
  });
}

class LectureRepository implements BaseLectureRepository {
  final BaseLectureDataSource dataSource;

  LectureRepository({required this.dataSource});

  // ──────────────────────────────────────────────
  // Lectures
  // ──────────────────────────────────────────────

  @override
  Future<Either<Failure, List<LectureModel>>> getCourseLectures({
    required String courseId,
  }) async {
    try {
      final result = await dataSource.getCourseLectures(courseId: courseId);
      final lectures = result.map((e) => LectureModel.fromJson(e)).toList();
      return Right(lectures);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in getCourseLectures: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, LectureModel>> getLecture({
    required String lectureId,
  }) async {
    try {
      final result = await dataSource.getLecture(lectureId: lectureId);
      return Right(LectureModel.fromJson(result));
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in getLecture: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, LectureModel>> createLecture({
    required String courseId,
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final result = await dataSource.createLecture(
        courseId: courseId,
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
      );
      return Right(LectureModel.fromJson(result));
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in createLecture: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, LectureModel>> updateLecture({
    required String lectureId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      final result = await dataSource.updateLecture(
        lectureId: lectureId,
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
      );
      return Right(LectureModel.fromJson(result));
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in updateLecture: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLecture({
    required String lectureId,
  }) async {
    try {
      await dataSource.deleteLecture(lectureId: lectureId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in deleteLecture: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, LectureModel>> toggleAttendance({
    required String lectureId,
    required bool isOpen,
  }) async {
    try {
      final result = await dataSource.toggleAttendance(
        lectureId: lectureId,
        isOpen: isOpen,
      );
      return Right(LectureModel.fromJson(result));
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in toggleAttendance: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  // ──────────────────────────────────────────────
  // Lecture Files
  // ──────────────────────────────────────────────

  @override
  Future<Either<Failure, List<LectureFileModel>>> getLectureFiles({
    required String lectureId,
  }) async {
    try {
      final result = await dataSource.getLectureFiles(lectureId: lectureId);
      final files = result.map((e) => LectureFileModel.fromJson(e)).toList();
      return Right(files);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in getLectureFiles: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, LectureFileModel>> addLectureFile({
    required String lectureId,
    required String fileUrl,
    required String fileName,
  }) async {
    try {
      final result = await dataSource.addLectureFile(
        lectureId: lectureId,
        fileUrl: fileUrl,
        fileName: fileName,
      );
      return Right(LectureFileModel.fromJson(result));
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in addLectureFile: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLectureFile({
    required String fileId,
  }) async {
    try {
      await dataSource.deleteLectureFile(fileId: fileId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in deleteLectureFile: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  // ──────────────────────────────────────────────
  // Attendance
  // ──────────────────────────────────────────────

  @override
  Future<Either<Failure, List<LectureAttendanceModel>>> getLectureAttendance({
    required String lectureId,
  }) async {
    try {
      final result =
          await dataSource.getLectureAttendance(lectureId: lectureId);
      final attendance =
          result.map((e) => LectureAttendanceModel.fromJson(e)).toList();
      return Right(attendance);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in getLectureAttendance: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, LectureAttendanceModel>> checkIn({
    required String lectureId,
  }) async {
    try {
      final result = await dataSource.checkIn(lectureId: lectureId);
      return Right(LectureAttendanceModel.fromJson(result));
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in checkIn: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateAttendanceStatus({
    required String attendanceId,
    required String status,
  }) async {
    try {
      await dataSource.updateAttendanceStatus(
        attendanceId: attendanceId,
        status: status,
      );
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in updateAttendanceStatus: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }
}
