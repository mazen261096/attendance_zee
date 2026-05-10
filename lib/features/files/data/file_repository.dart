import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/cloudflare_service.dart';
import '../../../core/utils/failure.dart';
import '../../../core/utils/supabase_error_mapper.dart';
import 'file_data_source.dart';
import 'file_upload_service.dart';
import 'models/file_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Abstract contract
// ─────────────────────────────────────────────────────────────────────────────

abstract class BaseFileRepository {
  Future<Either<Failure, List<FileModel>>> getCourseFilesWithLectures({
    required String courseId,
  });

  Future<Either<Failure, List<FileModel>>> getLectureFiles({
    required String lectureId,
  });

  Future<Either<Failure, FileModel>> uploadCourseFile({
    required String courseId,
    required XFile pickedFile,
    UploadProgressCallback? onProgress,
  });

  Future<Either<Failure, FileModel>> uploadLectureFile({
    required String courseId,
    required String lectureId,
    required XFile pickedFile,
    UploadProgressCallback? onProgress,
  });

  Future<Either<Failure, void>> deleteCourseFile({
    required String fileId,
    required String objectKey,
  });

  Future<Either<Failure, void>> deleteLectureFile({
    required String fileId,
    required String objectKey,
  });

  Future<Either<Failure, String>> getSignedDownloadUrl(String objectKey);
}

// ─────────────────────────────────────────────────────────────────────────────
// Implementation
// ─────────────────────────────────────────────────────────────────────────────

class FileRepository implements BaseFileRepository {
  final BaseFileDataSource dataSource;
  final FileUploadService uploadService;
  final CloudflareService cloudflareService;

  const FileRepository({
    required this.dataSource,
    required this.uploadService,
    required this.cloudflareService,
  });

  // ── Queries ──────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<FileModel>>> getCourseFilesWithLectures({
    required String courseId,
  }) async {
    try {
      final rows =
          await dataSource.getCourseFilesWithLectures(courseId: courseId);
      final files = rows.map(FileModel.fromRpcJson).toList();
      return Right(files);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      debugPrint('Error in getCourseFilesWithLectures: $e\n$stack');
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, List<FileModel>>> getLectureFiles({
    required String lectureId,
  }) async {
    try {
      final rows = await dataSource.getLectureFiles(lectureId: lectureId);
      final files = rows.map((r) {
        // Map lecture_files row into a FileModel (scope = lecture)
        return FileModel(
          id: r['id'] as String,
          fileName: r['file_name'] as String? ?? '',
          objectKey: r['object_key'] as String? ?? '',
          fileSize: r['file_size'] as int?,
          contentType: r['content_type'] as String?,
          uploadedBy: r['uploaded_by'] as String,
          createdAt: DateTime.parse(r['created_at'] as String),
          scope: FileScope.lecture,
          scopeId: r['lecture_id'] as String,
        );
      }).toList();
      return Right(files);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      debugPrint('Error in getLectureFiles: $e\n$stack');
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  // ── Uploads ──────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, FileModel>> uploadCourseFile({
    required String courseId,
    required XFile pickedFile,
    UploadProgressCallback? onProgress,
  }) async {
    try {
      // Steps 1 & 2: presign → upload to R2
      final result = await uploadService.uploadCourseFile(
        courseId: courseId,
        pickedFile: pickedFile,
        onProgress: onProgress,
      );

      // Step 3: insert metadata into Supabase
      final row = await dataSource.insertCourseFileMetadata(
        courseId: courseId,
        objectKey: result.objectKey,
        fileName: result.fileName,
        contentType: result.contentType,
        fileSize: result.fileSize,
      );

      return Right(FileModel(
        id: row['id'] as String,
        fileName: result.fileName,
        objectKey: result.objectKey,
        fileSize: result.fileSize,
        contentType: result.contentType,
        uploadedBy: row['uploaded_by'] as String,
        createdAt: DateTime.parse(row['created_at'] as String),
        scope: FileScope.course,
        scopeId: courseId,
      ));
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      debugPrint('Error in uploadCourseFile: $e\n$stack');
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, FileModel>> uploadLectureFile({
    required String courseId,
    required String lectureId,
    required XFile pickedFile,
    UploadProgressCallback? onProgress,
  }) async {
    try {
      // Steps 1 & 2: presign → upload to R2
      final result = await uploadService.uploadLectureFile(
        courseId: courseId,
        lectureId: lectureId,
        pickedFile: pickedFile,
        onProgress: onProgress,
      );

      // Step 3: insert metadata into Supabase
      final row = await dataSource.insertLectureFileMetadata(
        lectureId: lectureId,
        objectKey: result.objectKey,
        fileName: result.fileName,
        contentType: result.contentType,
        fileSize: result.fileSize,
      );

      return Right(FileModel(
        id: row['id'] as String,
        fileName: result.fileName,
        objectKey: result.objectKey,
        fileSize: result.fileSize,
        contentType: result.contentType,
        uploadedBy: row['uploaded_by'] as String,
        createdAt: DateTime.parse(row['created_at'] as String),
        scope: FileScope.lecture,
        scopeId: lectureId,
      ));
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      debugPrint('Error in uploadLectureFile: $e\n$stack');
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  // ── Deletes ──────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> deleteCourseFile({
    required String fileId,
    required String objectKey,
  }) async {
    try {
      // Delete from R2 first (idempotent if it fails we can retry)
      if (objectKey.isNotEmpty) {
        await cloudflareService.deleteFile(objectKey);
      }
      await dataSource.deleteCourseFileMeta(fileId: fileId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      debugPrint('Error in deleteCourseFile: $e\n$stack');
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLectureFile({
    required String fileId,
    required String objectKey,
  }) async {
    try {
      if (objectKey.isNotEmpty) {
        await cloudflareService.deleteFile(objectKey);
      }
      await dataSource.deleteLectureFileMeta(fileId: fileId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      debugPrint('Error in deleteLectureFile: $e\n$stack');
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  // ── Signed URL ───────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, String>> getSignedDownloadUrl(
    String objectKey,
  ) async {
    try {
      final url = await cloudflareService.getSignedDownloadUrl(objectKey);
      return Right(url);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      debugPrint('Error in getSignedDownloadUrl: $e\n$stack');
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }
}
