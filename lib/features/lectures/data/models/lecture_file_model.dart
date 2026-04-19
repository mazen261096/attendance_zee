class LectureFileModel {
  final String id;
  final String lectureId;
  final String fileUrl;
  final String fileName;
  final String uploadedBy;
  final DateTime createdAt;

  LectureFileModel({
    required this.id,
    required this.lectureId,
    required this.fileUrl,
    required this.fileName,
    required this.uploadedBy,
    required this.createdAt,
  });

  factory LectureFileModel.fromJson(Map<String, dynamic> json) {
    return LectureFileModel(
      id: json['id'],
      lectureId: json['lecture_id'],
      fileUrl: json['file_url'] ?? '',
      fileName: json['file_name'] ?? '',
      uploadedBy: json['uploaded_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lecture_id': lectureId,
        'file_url': fileUrl,
        'file_name': fileName,
        'uploaded_by': uploadedBy,
        'created_at': createdAt.toIso8601String(),
      };
}
