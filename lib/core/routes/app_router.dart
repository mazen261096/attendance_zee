import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/view/screens/login_screen.dart';
import '../../features/auth/view/screens/signup_screen.dart';
import '../../features/auth/view/screens/forgot_password_screen.dart';
import '../../features/splash/view/splash_screen.dart';
import '../../features/courses/data/models/course_model.dart';
import '../../features/courses/view/screens/course_detail_screen.dart';
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
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const AppShell(),
      ),

      // ── Course Detail ──
      GoRoute(
        path: Routes.courseDetail,
        builder: (context, state) {
          final course = state.extra as CourseModel;
          return CourseDetailScreen(course: course);
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
          final lecture = state.extra as LectureModel;
          return LectureDetailScreen(lecture: lecture);
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
          final gradeItem = state.extra as GradeItemModel;
          return GradeItemDetailScreen(gradeItem: gradeItem);
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

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription =
        stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
