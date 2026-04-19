import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/auth_data_source.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/view_model/auth_cubit.dart';
import '../../features/profile/data/profile_data_source.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/profile/view_model/profile_cubit.dart';
import '../../features/courses/data/course_data_source.dart';
import '../../features/courses/data/course_repository.dart';
import '../../features/courses/view_model/course_cubit.dart';
import '../../features/lectures/data/lecture_data_source.dart';
import '../../features/lectures/data/lecture_repository.dart';
import '../../features/lectures/view_model/lecture_cubit.dart';
import '../../features/grades/data/grade_data_source.dart';
import '../../features/grades/data/grade_repository.dart';
import '../../features/grades/view_model/grade_cubit.dart';
import '../../features/notifications/data/notification_data_source.dart';
import '../../features/notifications/data/notification_repository.dart';
import '../../features/notifications/view_model/notification_cubit.dart';
import '../services/supabase_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Services
  getIt.registerLazySingleton<SupabaseService>(() => SupabaseService());

  // ── Auth Module ──
  getIt.registerLazySingleton<BaseAuthDataSource>(
    () => AuthDataSource(supabaseService: getIt()),
  );
  getIt.registerLazySingleton<BaseAuthRepository>(
    () => AuthRepository(dataSource: getIt()),
  );
  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(repository: getIt()),
  );

  // ── Profile Module ──
  getIt.registerLazySingleton<BaseProfileDataSource>(
    () => ProfileDataSource(supabaseService: getIt()),
  );
  getIt.registerLazySingleton<BaseProfileRepository>(
    () => ProfileRepository(dataSource: getIt()),
  );
  getIt.registerFactory<ProfileCubit>(() => ProfileCubit(repository: getIt()));

  // ── Courses Module ──
  getIt.registerLazySingleton<BaseCourseDataSource>(
    () => CourseDataSource(supabaseService: getIt()),
  );
  getIt.registerLazySingleton<BaseCourseRepository>(
    () => CourseRepository(dataSource: getIt()),
  );
  getIt.registerFactory<CourseCubit>(() => CourseCubit(repository: getIt()));

  // ── Lectures Module ──
  getIt.registerLazySingleton<BaseLectureDataSource>(
    () => LectureDataSource(supabaseService: getIt()),
  );
  getIt.registerLazySingleton<BaseLectureRepository>(
    () => LectureRepository(dataSource: getIt()),
  );
  getIt.registerFactory<LectureCubit>(() => LectureCubit(repository: getIt()));

  // ── Grades Module ──
  getIt.registerLazySingleton<BaseGradeDataSource>(
    () => GradeDataSource(supabaseService: getIt()),
  );
  getIt.registerLazySingleton<BaseGradeRepository>(
    () => GradeRepository(dataSource: getIt()),
  );
  getIt.registerFactory<GradeCubit>(() => GradeCubit(repository: getIt()));

  // ── Notifications Module ──
  getIt.registerLazySingleton<BaseNotificationDataSource>(
    () => NotificationDataSource(supabaseService: getIt()),
  );
  getIt.registerLazySingleton<BaseNotificationRepository>(
    () => NotificationRepository(dataSource: getIt()),
  );
  getIt.registerFactory<NotificationCubit>(
    () => NotificationCubit(repository: getIt()),
  );
}
