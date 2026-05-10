import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../files/view/screens/files_tab.dart';

class CourseFilesScreen extends StatelessWidget {
  final String courseId;
  final String courseName;
  final bool isAdmin;

  const CourseFilesScreen({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(courseName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: FilesTab(courseId: courseId, isAdmin: isAdmin),
    );
  }
}
