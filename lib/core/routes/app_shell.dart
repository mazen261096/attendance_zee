import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/courses/view/screens/courses_tab.dart';
import '../../features/courses/view_model/course_cubit.dart';
import '../../features/grades/view/screens/my_grades_tab.dart';
import '../../features/grades/view_model/grade_cubit.dart';
import '../../features/notifications/view/screens/notifications_tab.dart';
import '../../features/notifications/view_model/notification_cubit.dart';
import '../../features/notifications/view_model/notification_state.dart';
import '../../features/profile/view/screens/profile_tab.dart';
import '../../features/profile/view_model/profile_cubit.dart';
import '../di/service_locator.dart';
import '../services/supabase_service.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  late final CourseCubit _courseCubit;
  late final GradeCubit _gradeCubit;
  late final NotificationCubit _notificationCubit;
  late final ProfileCubit _profileCubit;

  @override
  void initState() {
    super.initState();
    _courseCubit = getIt<CourseCubit>();
    _gradeCubit = getIt<GradeCubit>();
    _notificationCubit = getIt<NotificationCubit>();
    _profileCubit = getIt<ProfileCubit>();

    // Load initial data — cubit methods take no userId param
    _courseCubit.getMyCourses();
    _notificationCubit.getNotifications();
    _notificationCubit.getUnreadCount();

    final userId = SupabaseService().currentUser?.id;
    if (userId != null) {
      _profileCubit.getProfile(profileId: userId);
    }
  }

  @override
  void dispose() {
    _courseCubit.close();
    _gradeCubit.close();
    _notificationCubit.close();
    _profileCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _courseCubit),
        BlocProvider.value(value: _gradeCubit),
        BlocProvider.value(value: _notificationCubit),
        BlocProvider.value(value: _profileCubit),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: const [
            CoursesTab(),
            MyGradesTab(),
            NotificationsTab(),
            ProfileTab(),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BlocBuilder<NotificationCubit, NotificationState>(
      bloc: _notificationCubit,
      builder: (context, state) {
        return NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          animationDuration: const Duration(milliseconds: 400),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded),
              label: 'Courses',
            ),
            const NavigationDestination(
              icon: Icon(Icons.assessment_outlined),
              selectedIcon: Icon(Icons.assessment_rounded),
              label: 'Grades',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: state.hasUnread,
                label: Text('${state.unreadCount}'),
                child: const Icon(Icons.notifications_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: state.hasUnread,
                label: Text('${state.unreadCount}'),
                child: const Icon(Icons.notifications_rounded),
              ),
              label: 'Notifications',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outlined),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        );
      },
    );
  }
}
