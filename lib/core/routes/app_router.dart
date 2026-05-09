import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/view/screens/login_screen.dart';
import '../../features/auth/view/screens/signup_screen.dart';
import '../../features/auth/view/screens/forgot_password_screen.dart';
import '../../features/splash/view/splash_screen.dart';
import '../../features/courses/data/models/course_model.dart';
import '../../features/courses/view/screens/course_detail_screen.dart';
import '../../features/courses/view/screens/course_lectures_screen.dart';
import '../../features/courses/view/screens/course_members_screen.dart';
import '../../features/courses/view/screens/course_attendance_screen.dart';
import '../../features/courses/view/screens/course_files_screen.dart';
import '../../features/courses/view/screens/course_settings_screen.dart';
import '../../features/grades/data/models/grade_item_model.dart';
import '../../features/grades/view/screens/course_grades_screen.dart';
import '../../features/grades/view/screens/grade_item_detail_screen.dart';
import '../../features/lectures/data/models/lecture_model.dart';
import '../../features/lectures/view/screens/create_lecture_screen.dart';
import '../../features/lectures/view/screens/lecture_detail_screen.dart';
import '../../features/profile/view/screens/edit_profile_screen.dart';
import '../../features/profile/view_model/profile_cubit.dart';
import '../../features/settings/view/screens/change_password_screen.dart';
import '../../features/settings/view/screens/settings_screen.dart';
import '../di/service_locator.dart';
import '../services/supabase_service.dart';
import 'app_shell.dart';
import 'routes.dart';

class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  /// Public access to navigator key
  static GlobalKey<NavigatorState> get navigatorKey => rootNavigatorKey;

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.splash,
    refreshListenable: GoRouterRefreshStream(
      SupabaseService().authStateChanges,
    ),
    redirect: (context, state) {
      final session = SupabaseService().currentUser;
      final path = state.uri.path;

      // Splash is always accessible
      if (path == Routes.splash) return null;

      // Auth routes — if already logged in, go home
      if (path == Routes.login ||
          path == Routes.signup ||
          path == Routes.forgotPassword) {
        return session != null ? Routes.home : null;
      }

      // Protected routes — require auth
      if (session == null) {
        return Routes.login;
      }

      return null;
    },
    routes: [
      // ── Splash ──
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Auth ──
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ── Home (AppShell with 4 tabs) ──
      GoRoute(path: Routes.home, builder: (context, state) => const AppShell()),

      // ── Course Detail ──
      GoRoute(
        path: Routes.courseDetail,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is CourseModel) {
            return CourseDetailScreen(course: extra);
          }
          if (extra is Map<String, dynamic>) {
            return CourseDetailScreen(course: CourseModel.fromJson(extra));
          }
          // Deep-link / notification: fetch by ID
          final courseId = state.pathParameters['courseId']!;
          return _AsyncScreen<CourseModel>(
            future: Supabase.instance.client
                .from('courses')
                .select()
                .eq('id', courseId)
                .single()
                .then((json) => CourseModel.fromJson(json)),
            builder: (course) => CourseDetailScreen(course: course),
          );
        },
      ),

      // ── Lecture Routes ──
      GoRoute(
        path: Routes.createLecture,
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return CreateLectureScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: Routes.lectureDetail,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is LectureModel) {
            return LectureDetailScreen(lecture: extra);
          }
          if (extra is Map<String, dynamic>) {
            return LectureDetailScreen(lecture: LectureModel.fromJson(extra));
          }
          final lectureId = state.pathParameters['lectureId']!;
          return _AsyncScreen<LectureModel>(
            future: Supabase.instance.client
                .from('lectures')
                .select()
                .eq('id', lectureId)
                .single()
                .then((json) => LectureModel.fromJson(json)),
            builder: (lecture) => LectureDetailScreen(lecture: lecture),
          );
        },
      ),

      // ── Grade Routes ──
      GoRoute(
        path: Routes.courseGrades,
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return CourseGradesScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: Routes.gradeItemDetail,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is GradeItemModel) {
            return GradeItemDetailScreen(gradeItem: extra);
          }
          if (extra is Map<String, dynamic>) {
            return GradeItemDetailScreen(gradeItem: GradeItemModel.fromJson(extra));
          }
          final gradeItemId = state.pathParameters['gradeItemId']!;
          return _AsyncScreen<GradeItemModel>(
            future: Supabase.instance.client
                .from('grade_items')
                .select()
                .eq('id', gradeItemId)
                .single()
                .then((json) => GradeItemModel.fromJson(json)),
            builder: (gradeItem) => GradeItemDetailScreen(gradeItem: gradeItem),
          );
        },
      ),

      // ── Course Sub-Screens ──
      GoRoute(
        path: Routes.courseLectures,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final courseId = state.pathParameters['courseId']!;
          return CourseLecturesScreen(
            courseId: courseId,
            courseName: extra?['courseName'] as String? ?? '',
            isAdmin: extra?['isAdmin'] as bool? ?? false,
          );
        },
      ),
      GoRoute(
        path: Routes.courseMembers,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final courseId = state.pathParameters['courseId']!;
          return CourseMembersScreen(
            courseId: courseId,
            courseName: extra?['courseName'] as String? ?? '',
            isAdmin: extra?['isAdmin'] as bool? ?? false,
          );
        },
      ),
      GoRoute(
        path: Routes.courseAttendance,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final courseId = state.pathParameters['courseId']!;
          return CourseAttendanceScreen(
            courseId: courseId,
            courseName: extra?['courseName'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: Routes.courseFiles,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final courseId = state.pathParameters['courseId']!;
          return CourseFilesScreen(
            courseId: courseId,
            courseName: extra?['courseName'] as String? ?? '',
            isAdmin: extra?['isAdmin'] as bool? ?? false,
          );
        },
      ),
      GoRoute(
        path: Routes.courseSettings,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is CourseModel) {
            return CourseSettingsScreen(course: extra);
          }
          final courseId = state.pathParameters['courseId']!;
          return _AsyncScreen<CourseModel>(
            future: Supabase.instance.client
                .from('courses')
                .select()
                .eq('id', courseId)
                .single()
                .then((json) => CourseModel.fromJson(json)),
            builder: (course) => CourseSettingsScreen(course: course),
          );
        },
      ),

      // ── Profile ──
      GoRoute(
        path: Routes.editProfile,
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<ProfileCubit>(),
          child: const EditProfileScreen(),
        ),
      ),

      // ── Settings ──
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
    ],
  );
}

/// A generic widget that shows a loading spinner while fetching data,
/// then builds the target screen. Used for deep-link / notification navigation.
class _AsyncScreen<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(T data) builder;

  const _AsyncScreen({required this.future, required this.builder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Could not load data',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }
        return builder(snapshot.data as T);
      },
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
