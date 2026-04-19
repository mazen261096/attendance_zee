class CourseFileModel {
  final String id;
  final String courseId;
  final String fileUrl;
  final String fileName;
  final String uploadedBy;
  final DateTime createdAt;

  CourseFileModel({
    required this.id,
    required this.courseId,
    required this.fileUrl,
    required this.fileName,
    required this.uploadedBy,
    required this.createdAt,
  });

  factory CourseFileModel.fromJson(Map<String, dynamic> json) {
    return CourseFileModel(
      id: json['id'],
      courseId: json['course_id'],
      fileUrl: json['file_url'] ?? '',
      fileName: json['file_name'] ?? '',
      uploadedBy: json['uploaded_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'course_id': courseId,
        'file_url': fileUrl,
        'file_name': fileName,
        'uploaded_by': uploadedBy,
        'created_at': createdAt.toIso8601String(),
      };
}
