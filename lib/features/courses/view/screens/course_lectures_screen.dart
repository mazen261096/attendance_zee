import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../lectures/view/widgets/lecture_card.dart';
import '../../../lectures/view_model/lecture_cubit.dart';
import '../../../lectures/view_model/lecture_state.dart';

class CourseLecturesScreen extends StatefulWidget {
  final String courseId;
  final String courseName;
  final bool isAdmin;

  const CourseLecturesScreen({
    super.key,
    required this.courseId,
    required this.courseName,
    this.isAdmin = false,
  });

  @override
  State<CourseLecturesScreen> createState() => _CourseLecturesScreenState();
}

class _CourseLecturesScreenState extends State<CourseLecturesScreen> {
  late final LectureCubit _lectureCubit;

  @override
  void initState() {
    super.initState();
    _lectureCubit = getIt<LectureCubit>();
    _lectureCubit.getCourseLectures(courseId: widget.courseId);
  }

  @override
  void dispose() {
    _lectureCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _lectureCubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.courseName),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocBuilder<LectureCubit, LectureState>(
          builder: (context, state) {
            if (state.isGetLecturesLoading) {
              return const AppLoadingIndicator();
            }
            if (state.hasGetLecturesError) {
              return AppErrorWidget(
                message: state.getLecturesError,
                onRetry: () => _lectureCubit.getCourseLectures(
                    courseId: widget.courseId),
              );
            }
            if (state.lectures.isEmpty) {
              return AppEmptyState(
                icon: Icons.event_note_outlined,
                title: 'No Lectures Yet',
                subtitle: widget.isAdmin
                    ? 'Tap + to create your first lecture'
                    : 'No lectures have been added yet',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _lectureCubit.getCourseLectures(courseId: widget.courseId);
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: state.lectures.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final lecture = state.lectures[index];
                  return LectureCard(
                    lecture: lecture,
                    onTap: () => context.push(
                      Routes.lectureDetailPath(
                        widget.courseId,
                        lecture.id,
                      ),
                      extra: lecture,
                    ),
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: widget.isAdmin
            ? FloatingActionButton.extended(
                onPressed: () {
                  context.push(Routes.createLecturePath(widget.courseId));
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Lecture'),
                backgroundColor: AppConfig.primaryColor,
                foregroundColor: Colors.white,
              )
            : null,
      ),
    );
  }
}
