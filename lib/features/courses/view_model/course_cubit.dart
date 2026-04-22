import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/enums.dart';
import '../../../core/utils/either_extensions.dart';
import '../../../core/utils/core_utils.dart';
import '../data/course_repository.dart';
import 'course_state.dart';

class CourseCubit extends Cubit<CourseState> {
  CourseCubit({required this.repository}) : super(const CourseState());

  final BaseCourseRepository repository;

  // ──────────────────────────────────────────────
  // Courses
  // ──────────────────────────────────────────────

  Future<void> getMyCourses() async {
    emit(state.copyWith(
      getCoursesState: RequestState.loading,
      getCoursesError: '',
    ));

    try {
      final result = await repository.getMyCourses();

      result.fold(
        (failure) => emit(state.copyWith(
          getCoursesState: RequestState.error,
          getCoursesError: failure.message,
        )),
        (courses) => emit(state.copyWith(
          getCoursesState: RequestState.loaded,
          courses: courses,
          getCoursesError: '',
        )),
      );
    } catch (error, stack) {
      print('Error in getMyCourses: $error');
      print(stack);
      emit(state.copyWith(
        getCoursesState: RequestState.error,
        getCoursesError: error.toString(),
      ));
    }
  }

  Future<void> getCourse({required String courseId}) async {
    emit(state.copyWith(
      getCourseState: RequestState.loading,
      getCourseError: '',
    ));

    try {
      final result = await repository.getCourse(courseId: courseId);

      result.fold(
        (failure) => emit(state.copyWith(
          getCourseState: RequestState.error,
          getCourseError: failure.message,
        )),
        (course) => emit(state.copyWith(
          getCourseState: RequestState.loaded,
          currentCourse: course,
          getCourseError: '',
        )),
      );
    } catch (error, stack) {
      print('Error in getCourse: $error');
      print(stack);
      emit(state.copyWith(
        getCourseState: RequestState.error,
        getCourseError: error.toString(),
      ));
    }
  }

  Future<void> createCourse({
    required String name,
    String? description,
    required String code,
  }) async {
    emit(state.copyWith(
      createCourseState: RequestState.loading,
      createCourseError: '',
    ));

    try {
      final result = await repository.createCourse(
        name: name,
        description: description,
        code: code,
      );

      result.showSnackBarOnError().fold(
        (failure) => emit(state.copyWith(
          createCourseState: RequestState.error,
          createCourseError: failure.message,
        )),
        (course) {
          emit(state.copyWith(
            createCourseState: RequestState.loaded,
            currentCourse: course,
            courses: [course, ...state.courses],
            createCourseError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in createCourse: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        createCourseState: RequestState.error,
        createCourseError: error.toString(),
      ));
    }
  }

  Future<void> updateCourse({
    required String courseId,
    String? name,
    String? description,
  }) async {
    emit(state.copyWith(
      updateCourseState: RequestState.loading,
      updateCourseError: '',
    ));

    try {
      final result = await repository.updateCourse(
        courseId: courseId,
        name: name,
        description: description,
      );

      result.showSnackBarOnError().fold(
        (failure) => emit(state.copyWith(
          updateCourseState: RequestState.error,
          updateCourseError: failure.message,
        )),
        (course) {
          final updatedList = state.courses
              .map((c) => c.id == course.id ? course : c)
              .toList();
          emit(state.copyWith(
            updateCourseState: RequestState.loaded,
            currentCourse: course,
            courses: updatedList,
            updateCourseError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in updateCourse: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        updateCourseState: RequestState.error,
        updateCourseError: error.toString(),
      ));
    }
  }

  Future<void> deleteCourse({required String courseId}) async {
    emit(state.copyWith(
      deleteCourseState: RequestState.loading,
      deleteCourseError: '',
    ));

    try {
      final result = await repository.deleteCourse(courseId: courseId);

      result.showSnackBarOnError().fold(
        (failure) => emit(state.copyWith(
          deleteCourseState: RequestState.error,
          deleteCourseError: failure.message,
        )),
        (_) {
          final updatedList =
              state.courses.where((c) => c.id != courseId).toList();
          emit(state.copyWith(
            deleteCourseState: RequestState.loaded,
            courses: updatedList,
            deleteCourseError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in deleteCourse: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        deleteCourseState: RequestState.error,
        deleteCourseError: error.toString(),
      ));
    }
  }

  // ──────────────────────────────────────────────
  // Members
  // ──────────────────────────────────────────────

  Future<void> getCourseMembers({required String courseId}) async {
    emit(state.copyWith(
      getMembersState: RequestState.loading,
      getMembersError: '',
    ));

    try {
      final result = await repository.getCourseMembers(courseId: courseId);

      result.fold(
        (failure) => emit(state.copyWith(
          getMembersState: RequestState.error,
          getMembersError: failure.message,
        )),
        (members) => emit(state.copyWith(
          getMembersState: RequestState.loaded,
          members: members,
          getMembersError: '',
        )),
      );
    } catch (error, stack) {
      print('Error in getCourseMembers: $error');
      print(stack);
      emit(state.copyWith(
        getMembersState: RequestState.error,
        getMembersError: error.toString(),
      ));
    }
  }

  Future<void> removeMember({required String memberId}) async {
    emit(state.copyWith(
      removeMemberState: RequestState.loading,
      removeMemberError: '',
    ));

    try {
      final result = await repository.removeMember(memberId: memberId);

      result.showSnackBarOnError().fold(
        (failure) => emit(state.copyWith(
          removeMemberState: RequestState.error,
          removeMemberError: failure.message,
        )),
        (_) {
          final updatedMembers =
              state.members.where((m) => m.id != memberId).toList();
          emit(state.copyWith(
            removeMemberState: RequestState.loaded,
            members: updatedMembers,
            removeMemberError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in removeMember: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        removeMemberState: RequestState.error,
        removeMemberError: error.toString(),
      ));
    }
  }

  // ──────────────────────────────────────────────
  // Join Requests
  // ──────────────────────────────────────────────

  Future<void> joinCourseByCode({required String code}) async {
    emit(state.copyWith(
      joinCourseState: RequestState.loading,
      joinCourseError: '',
    ));

    try {
      final result = await repository.joinCourseByCode(code: code);

      result.showSnackBarOnError().fold(
        (failure) => emit(state.copyWith(
          joinCourseState: RequestState.error,
          joinCourseError: failure.message,
        )),
        (response) {
          final success = response['success'] as bool? ?? false;
          if (success) {
            emit(state.copyWith(
              joinCourseState: RequestState.loaded,
              joinCourseError: '',
            ));
          } else {
            final error = response['error'] as String? ?? 'Unknown error';
            CoreUtils.showErrorSnackBar(message: error);
            emit(state.copyWith(
              joinCourseState: RequestState.error,
              joinCourseError: error,
            ));
          }
        },
      );
    } catch (error, stack) {
      print('Error in joinCourseByCode: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        joinCourseState: RequestState.error,
        joinCourseError: error.toString(),
      ));
    }
  }

  Future<void> getJoinRequests({required String courseId}) async {
    emit(state.copyWith(
      getJoinRequestsState: RequestState.loading,
      getJoinRequestsError: '',
    ));

    try {
      final result = await repository.getJoinRequests(courseId: courseId);

      result.fold(
        (failure) => emit(state.copyWith(
          getJoinRequestsState: RequestState.error,
          getJoinRequestsError: failure.message,
        )),
        (requests) => emit(state.copyWith(
          getJoinRequestsState: RequestState.loaded,
          joinRequests: requests,
          getJoinRequestsError: '',
        )),
      );
    } catch (error, stack) {
      print('Error in getJoinRequests: $error');
      print(stack);
      emit(state.copyWith(
        getJoinRequestsState: RequestState.error,
        getJoinRequestsError: error.toString(),
      ));
    }
  }

  Future<void> approveJoinRequest({required String requestId}) async {
    emit(state.copyWith(
      approveRequestState: RequestState.loading,
      approveRequestError: '',
    ));

    try {
      final result = await repository.approveJoinRequest(requestId: requestId);

      result.showSnackBarOnError().fold(
        (failure) => emit(state.copyWith(
          approveRequestState: RequestState.error,
          approveRequestError: failure.message,
        )),
        (_) {
          final updatedRequests =
              state.joinRequests.where((r) => r.id != requestId).toList();
          emit(state.copyWith(
            approveRequestState: RequestState.loaded,
            joinRequests: updatedRequests,
            approveRequestError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in approveJoinRequest: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        approveRequestState: RequestState.error,
        approveRequestError: error.toString(),
      ));
    }
  }

  Future<void> rejectJoinRequest({required String requestId}) async {
    emit(state.copyWith(
      rejectRequestState: RequestState.loading,
      rejectRequestError: '',
    ));

    try {
      final result = await repository.rejectJoinRequest(requestId: requestId);

      result.showSnackBarOnError().fold(
        (failure) => emit(state.copyWith(
          rejectRequestState: RequestState.error,
          rejectRequestError: failure.message,
        )),
        (_) {
          final updatedRequests =
              state.joinRequests.where((r) => r.id != requestId).toList();
          emit(state.copyWith(
            rejectRequestState: RequestState.loaded,
            joinRequests: updatedRequests,
            rejectRequestError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in rejectJoinRequest: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        rejectRequestState: RequestState.error,
        rejectRequestError: error.toString(),
      ));
    }
  }

  // ──────────────────────────────────────────────
  // Course Files
  // ──────────────────────────────────────────────

  Future<void> getCourseFiles({required String courseId}) async {
    emit(state.copyWith(
      getCourseFilesState: RequestState.loading,
      getCourseFilesError: '',
    ));

    try {
      final result = await repository.getCourseFiles(courseId: courseId);

      result.fold(
        (failure) => emit(state.copyWith(
          getCourseFilesState: RequestState.error,
          getCourseFilesError: failure.message,
        )),
        (files) => emit(state.copyWith(
          getCourseFilesState: RequestState.loaded,
          courseFiles: files,
          getCourseFilesError: '',
        )),
      );
    } catch (error, stack) {
      print('Error in getCourseFiles: $error');
      print(stack);
      emit(state.copyWith(
        getCourseFilesState: RequestState.error,
        getCourseFilesError: error.toString(),
      ));
    }
  }

  Future<void> uploadCourseFile({
    required String courseId,
    required String fileUrl,
    required String fileName,
  }) async {
    emit(state.copyWith(
      uploadFileState: RequestState.loading,
      uploadFileError: '',
    ));

    try {
      final result = await repository.uploadCourseFile(
        courseId: courseId,
        fileUrl: fileUrl,
        fileName: fileName,
      );

      result.showSnackBarOnError().fold(
        (failure) => emit(state.copyWith(
          uploadFileState: RequestState.error,
          uploadFileError: failure.message,
        )),
        (file) {
          emit(state.copyWith(
            uploadFileState: RequestState.loaded,
            courseFiles: [file, ...state.courseFiles],
            uploadFileError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in uploadCourseFile: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        uploadFileState: RequestState.error,
        uploadFileError: error.toString(),
      ));
    }
  }

  Future<void> deleteCourseFile({required String fileId}) async {
    emit(state.copyWith(
      deleteFileState: RequestState.loading,
      deleteFileError: '',
    ));

    try {
      final result = await repository.deleteCourseFile(fileId: fileId);

      result.showSnackBarOnError().fold(
        (failure) => emit(state.copyWith(
          deleteFileState: RequestState.error,
          deleteFileError: failure.message,
        )),
        (_) {
          final updatedFiles =
              state.courseFiles.where((f) => f.id != fileId).toList();
          emit(state.copyWith(
            deleteFileState: RequestState.loaded,
            courseFiles: updatedFiles,
            deleteFileError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in deleteCourseFile: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        deleteFileState: RequestState.error,
        deleteFileError: error.toString(),
      ));
    }
  }

  // ──────────────────────────────────────────────
  // Attendance Summary
  // ──────────────────────────────────────────────

  Future<void> getAttendanceSummary({required String courseId}) async {
    emit(state.copyWith(
      getAttendanceSummaryState: RequestState.loading,
      getAttendanceSummaryError: '',
    ));

    try {
      final result = await repository.getAttendanceSummary(courseId: courseId);

      result.fold(
        (failure) => emit(state.copyWith(
          getAttendanceSummaryState: RequestState.error,
          getAttendanceSummaryError: failure.message,
        )),
        (data) {
          final members = List<Map<String, dynamic>>.from(data['members'] ?? []);
          final totalLectures = data['total_lectures'] as int? ?? 0;
          emit(state.copyWith(
            getAttendanceSummaryState: RequestState.loaded,
            attendanceSummary: members,
            totalLectures: totalLectures,
            getAttendanceSummaryError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in getAttendanceSummary: $error');
      print(stack);
      emit(state.copyWith(
        getAttendanceSummaryState: RequestState.error,
        getAttendanceSummaryError: error.toString(),
      ));
    }
  }

  // ── Resets ──
  void resetCreateCourseState() {
    emit(state.copyWith(
      createCourseState: RequestState.initial,
      createCourseError: '',
    ));
  }

  void resetJoinCourseState() {
    emit(state.copyWith(
      joinCourseState: RequestState.initial,
      joinCourseError: '',
    ));
  }
}
