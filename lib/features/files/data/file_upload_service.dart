import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import '../../../../core/services/cloudflare_service.dart';


// ─────────────────────────────────────────────────────────────────────────────
// UploadResult — returned after a successful 3-step upload
// ─────────────────────────────────────────────────────────────────────────────

class UploadResult {
  final String objectKey;
  final String fileName;
  final String contentType;
  final int fileSize;

  const UploadResult({
    required this.objectKey,
    required this.fileName,
    required this.contentType,
    required this.fileSize,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// FileUploadService
// Orchestrates:
//   Step 1 → POST /presign-upload   (Worker — get signed PUT URL)
//   Step 2 → PUT <signedUrl>        (R2 directly — upload bytes)
//   Step 3 → INSERT into Supabase   (metadata only)
// ─────────────────────────────────────────────────────────────────────────────

class FileUploadService {
  final CloudflareService cloudflareService;

  const FileUploadService({required this.cloudflareService});

  // ─────────────────────────────────────────────────────────────────────────
  // Upload a course-level file
  // ─────────────────────────────────────────────────────────────────────────

  Future<UploadResult> uploadCourseFile({
    required String courseId,
    required XFile pickedFile,
    UploadProgressCallback? onProgress,
  }) async {
    return _upload(
      scope: 'course',
      courseId: courseId,
      pickedFile: pickedFile,
      onProgress: onProgress,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Upload a lecture-level file
  // ─────────────────────────────────────────────────────────────────────────

  Future<UploadResult> uploadLectureFile({
    required String courseId,
    required String lectureId,
    required XFile pickedFile,
    UploadProgressCallback? onProgress,
  }) async {
    return _upload(
      scope: 'lecture',
      courseId: courseId,
      lectureId: lectureId,
      pickedFile: pickedFile,
      onProgress: onProgress,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Core upload logic
  // ─────────────────────────────────────────────────────────────────────────

  Future<UploadResult> _upload({
    required String scope,
    required String courseId,
    String? lectureId,
    required XFile pickedFile,
    UploadProgressCallback? onProgress,
  }) async {
    final fileName = pickedFile.name;
    final contentType = _resolveContentType(pickedFile);
    final Uint8List fileBytes = await pickedFile.readAsBytes();
    final fileSize = fileBytes.length;

    // ── Step 1: Get presigned PUT URL ────────────────────────────────────
    final presign = await cloudflareService.requestPresignedUploadUrl(
      scope: scope,
      courseId: courseId,
      lectureId: lectureId,
      fileName: fileName,
      contentType: contentType,
      fileSize: fileSize,
    );

    // ── Step 2: Upload directly to R2 ────────────────────────────────────
    await cloudflareService.uploadFileToR2(
      presignedUrl: presign.uploadUrl,
      fileBytes: fileBytes,
      contentType: contentType,
      onProgress: onProgress,
    );

    // ── Step 3: Return result (caller inserts metadata into Supabase) ─────
    return UploadResult(
      objectKey: presign.objectKey,
      fileName: fileName,
      contentType: contentType,
      fileSize: fileSize,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  String _resolveContentType(XFile file) {
    // image_picker provides mimeType on some platforms; fall back to extension.
    if (file.mimeType != null && file.mimeType!.isNotEmpty) {
      return file.mimeType!;
    }
    final ext = file.name.split('.').last.toLowerCase();
    return _extToMime[ext] ?? 'application/octet-stream';
  }

  static const Map<String, String> _extToMime = {
    // Images
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'heic': 'image/heic',
    // Videos
    'mp4': 'video/mp4',
    'mov': 'video/quicktime',
    'avi': 'video/x-msvideo',
    'mkv': 'video/x-matroska',
    'webm': 'video/webm',
    // Documents
    'pdf': 'application/pdf',
  };
}
