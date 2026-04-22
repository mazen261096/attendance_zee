class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // ── Shell Tabs ──
  static const String home = '/home';
  static const String courses = '/home/courses';
  static const String grades = '/home/grades';
  static const String notifications = '/home/notifications';
  static const String profile = '/home/profile';

  // ── Courses ──
  static const String courseDetail = '/course/:courseId';
  static String courseDetailPath(String courseId) => '/course/$courseId';

  static const String courseGrades = '/course/:courseId/grades';
  static String courseGradesPath(String courseId) => '/course/$courseId/grades';

  static const String gradeItemDetail = '/course/:courseId/grades/:gradeItemId';
  static String gradeItemDetailPath(String courseId, String gradeItemId) =>
      '/course/$courseId/grades/$gradeItemId';

  static const String totalGrades = '/course/:courseId/total-grades';
  static String totalGradesPath(String courseId) =>
      '/course/$courseId/total-grades';

  // ── Lectures ──
  static const String createLecture = '/course/:courseId/create-lecture';
  static String createLecturePath(String courseId) =>
      '/course/$courseId/create-lecture';

  static const String lectureDetail = '/course/:courseId/lecture/:lectureId';
  static String lectureDetailPath(String courseId, String lectureId) =>
      '/course/$courseId/lecture/$lectureId';

  // ── Profile ──
  static const String editProfile = '/edit-profile';

  // ── Settings ──
  static const String settings = '/settings';
  static const String changePassword = '/settings/change-password';
}
