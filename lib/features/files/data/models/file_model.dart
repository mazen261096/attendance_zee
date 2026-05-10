// ─────────────────────────────────────────────────────────────────────────────
// FileModel — unified model for both course-level and lecture-level files.
// Returned by get_course_files_with_lectures RPC and used throughout the UI.
// ─────────────────────────────────────────────────────────────────────────────

enum FileScope { course, lecture }

extension FileScopeX on FileScope {
  bool get isCourse => this == FileScope.course;
  bool get isLecture => this == FileScope.lecture;
}

class FileModel {
  final String id;
  final String fileName;
  final String objectKey;
  final int? fileSize;         // bytes — may be null for legacy rows
  final String? contentType;
  final String uploadedBy;
  final DateTime createdAt;

  /// Whether this file belongs to the course itself or a specific lecture.
  final FileScope scope;

  /// For scope == course  → courseId
  /// For scope == lecture → lectureId
  final String scopeId;

  /// Human-readable lecture title; null when scope == course.
  final String? lectureTitle;

  const FileModel({
    required this.id,
    required this.fileName,
    required this.objectKey,
    this.fileSize,
    this.contentType,
    required this.uploadedBy,
    required this.createdAt,
    required this.scope,
    required this.scopeId,
    this.lectureTitle,
  });

  // ── Factory — from RPC row ───────────────────────────────────────────────

  factory FileModel.fromRpcJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'] as String,
      fileName: json['file_name'] as String? ?? '',
      objectKey: json['object_key'] as String? ?? '',
      fileSize: json['file_size'] as int?,
      contentType: json['content_type'] as String?,
      uploadedBy: json['uploaded_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      scope: (json['scope'] as String?) == 'lecture'
          ? FileScope.lecture
          : FileScope.course,
      scopeId: json['scope_id'] as String,
      lectureTitle: json['lecture_title'] as String?,
    );
  }

  // ── Convenience ─────────────────────────────────────────────────────────

  /// MIME category: 'image', 'video', 'pdf', or 'file'
  String get mimeCategory {
    final ct = contentType ?? '';
    if (ct.startsWith('image/')) return 'image';
    if (ct.startsWith('video/')) return 'video';
    if (ct == 'application/pdf') return 'pdf';
    return 'file';
  }

  /// Human-readable file size string.
  String get fileSizeLabel {
    if (fileSize == null) return '';
    final kb = fileSize! / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'file_name': fileName,
        'object_key': objectKey,
        'file_size': fileSize,
        'content_type': contentType,
        'uploaded_by': uploadedBy,
        'created_at': createdAt.toIso8601String(),
        'scope': scope.name,
        'scope_id': scopeId,
        'lecture_title': lectureTitle,
      };
}
