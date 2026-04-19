import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/enums.dart';
import '../../../core/utils/either_extensions.dart';
import '../../../core/utils/core_utils.dart';
import '../data/lecture_repository.dart';
import 'lecture_state.dart';

class LectureCubit extends Cubit<LectureState> {
  LectureCubit({required this.repository}) : super(const LectureState());

  final BaseLectureRepository repository;

  // ──────────────────────────────────────────────
  // Lectures
  // ──────────────────────────────────────────────

  Future<void> getCourseLectures({required String courseId}) async {
    emit(state.copyWith(
      getLecturesState: RequestState.loading,
      getLecturesError: '',
    ));

    try {
      final result = await repository.getCourseLectures(courseId: courseId);

      result.fold(
        (failure) => emit(state.copyWith(
          getLecturesState: RequestState.error,
          getLecturesError: failure.message,
        )),
        (lectures) => emit(state.copyWith(
          getLecturesState: RequestState.loaded,
          lectures: lectures,
          getLecturesError: '',
        )),
      );
    } catch (error, stack) {
      print('Error in getCourseLectures: $error');
      print(stack);
      emit(state.copyWith(
        getLecturesState: RequestState.error,
        getLecturesError: error.toString(),
      ));
    }
  }

  Future<void> getLecture({required String lectureId}) async {
    emit(state.copyWith(
      getLectureState: RequestState.loading,
      getLectureError: '',
    ));

    try {
      final result = await repository.getLecture(lectureId: lectureId);

      result.fold(
        (failure) => emit(state.copyWith(
          getLectureState: RequestState.error,
          getLectureError: failure.message,
        )),
        (lecture) => emit(state.copyWith(
          getLectureState: RequestState.loaded,
          currentLecture: lecture,
          getLectureError: '',
        )),
      );
    } catch (error, stack) {
      print('Error in getLecture: $error');
      print(stack);
      emit(state.copyWith(
        getLectureState: RequestState.error,
        getLectureError: error.toString(),
      ));
    }
  }

  Future<void> createLecture({
    required String courseId,
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    emit(state.copyWith(
      createLectureState: RequestState.loading,
      createLectureError: '',
    ));

    try {
      final result = await repository.createLecture(
        courseId: courseId,
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
      );

      result.showSnackBarOnError().fold(
        (failure) => emit(state.copyWith(
          createLectureState: RequestState.error,
          createLectureError: failure.message,
        )),
        (lecture) {
          emit(state.copyWith(
            createLectureState: RequestState.loaded,
            currentLecture: lecture,
            lectures: [lecture, ...state.lectures],
            createLectureError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in createLecture: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        createLectureState: RequestState.error,
        createLectureError: error.toString(),
      ));
    }
  }

  Future<void> updateLecture({
    required String lectureId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    emit(state.copyWith(
      updateLectureState: RequestState.loading,
      updateLectureError: '',
    ));

    try {
      final result = await repository.updateLecture(
        lectureId: lectureId,
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
      );

      result.showSnackBarOnError().fold(
        (failure) => emit(state.copyWith(
          updateLectureState: RequestState.error,
          updateLectureError: failure.message,
        )),
        (lecture) {
          final updatedList = state.lectures
              .map((l) => l.id == lecture.id ? lecture : l)
              .toList();
          emit(state.copyWith(
            updateLectureState: RequestState.loaded,
            currentLecture: lecture,
            lectures: updatedList,
            updateLectureError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in updateLecture: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        updateLectureState: RequestState.error,
        updateLectureError: error.toString(),
      ));
    }
  }

  Future<void> deleteLecture({required String lectureId}) async {
    emit(state.copyWith(
      deleteLectureState: RequestState.loading,
      deleteLectureError: '',
    ));

    try {
      final result = await repository.deleteLecture(lectureId: lectureId);

      result.showSnackBarOnError().fold(
        (failure) => emit(state.copyWith(
          deleteLectureState: RequestState.error,
          deleteLectureError: failure.message,
        )),
        (_) {
          final updatedList =
              state.lectures.where((l) => l.id != lectureId).toList();
          emit(state.copyWith(
            deleteLectureState: RequestState.loaded,
            lectures: updatedList,
            deleteLectureError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in deleteLecture: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        deleteLectureState: RequestState.error,
        deleteLectureError: error.toString(),
      ));
    }
  }

  Future<void> toggleAttendance({
    required String lectureId,
    required bool isOpen,
  }) async {
    emit(state.copyWith(
      toggleAttendanceState: RequestState.loading,
      toggleAttendanceError: '',
    ));

    try {
      final result = await repository.toggleAttendance(
        lectureId: lectureId,
        isOpen: isOpen,
      );

      result.showSnackBarOnError().fold(
        (failure) => emit(state.copyWith(
          toggleAttendanceState: RequestState.error,
          toggleAttendanceError: failure.message,
        )),
        (lecture) {
          // Update the lecture in the list too
          final updatedList = state.lectures
              .map((l) => l.id == lecture.id ? lecture : l)
              .toList();
          emit(state.copyWith(
            toggleAttendanceState: RequestState.loaded,
            currentLecture: lecture,
            lectures: updatedList,
            toggleAttendanceError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in toggleAttendance: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        toggleAttendanceState: RequestState.error,
        toggleAttendanceError: error.toString(),
      ));
    }
  }

  // ──────────────────────────────────────────────
  // Lecture Files
  // ──────────────────────────────────────────────

  Future<void> getLectureFiles({required String lectureId}) async {
    emit(state.copyWith(
      getLectureFilesState: RequestState.loading,
      getLectureFilesError: '',
    ));

    try {
      final result = await repository.getLectureFiles(lectureId: lectureId);

      result.fold(
        (failure) => emit(state.copyWith(
          getLectureFilesState: RequestState.error,
          getLectureFilesError: failure.message,
        )),
        (files) => emit(state.copyWith(
          getLectureFilesState: RequestState.loaded,
          lectureFiles: files,
          getLectureFilesError: '',
        )),
      );
    } catch (error, stack) {
      print('Error in getLectureFiles: $error');
      print(stack);
      emit(state.copyWith(
        getLectureFilesState: RequestState.error,
        getLectureFilesError: error.toString(),
      ));
    }
  }

  Future<void> addLectureFile({
    required String lectureId,
    required String fileUrl,
    required String fileName,
  }) async {
    emit(state.copyWith(
      addLectureFileState: RequestState.loading,
      addLectureFileError: '',
    ));

    try {
      final result = await repository.addLectureFile(
        lectureId: lectureId,
        fileUrl: fileUrl,
        fileName: fileName,
      );

      result.showSnackBarOnError().fold(
        (failure) => emit(state.copyWith(
          addLectureFileState: RequestState.error,
          addLectureFileError: failure.message,
        )),
        (file) {
          emit(state.copyWith(
            addLectureFileState: RequestState.loaded,
            lectureFiles: [file, ...state.lectureFiles],
            addLectureFileError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in addLectureFile: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        addLectureFileState: RequestState.error,
        addLectureFileError: error.toString(),
      ));
    }
  }

  Future<void> deleteLectureFile({required String fileId}) async {
    emit(state.copyWith(
      deleteLectureFileState: RequestState.loading,
      deleteLectureFileError: '',
    ));

    try {
      final result = await repository.deleteLectureFile(fileId: fileId);

      result.showSnackBarOnError().fold(
        (failure) => emit(state.copyWith(
          deleteLectureFileState: RequestState.error,
          deleteLectureFileError: failure.message,
        )),
        (_) {
          final updatedFiles =
              state.lectureFiles.where((f) => f.id != fileId).toList();
          emit(state.copyWith(
            deleteLectureFileState: RequestState.loaded,
            lectureFiles: updatedFiles,
            deleteLectureFileError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in deleteLectureFile: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        deleteLectureFileState: RequestState.error,
        deleteLectureFileError: error.toString(),
      ));
    }
  }

  // ──────────────────────────────────────────────
  // Attendance
  // ──────────────────────────────────────────────

  Future<void> getLectureAttendance({required String lectureId}) async {
    emit(state.copyWith(
      getAttendanceState: RequestState.loading,
      getAttendanceError: '',
    ));

    try {
      final result =
          await repository.getLectureAttendance(lectureId: lectureId);

      result.fold(
        (failure) => emit(state.copyWith(
          getAttendanceState: RequestState.error,
          getAttendanceError: failure.message,
        )),
        (attendance) => emit(state.copyWith(
          getAttendanceState: RequestState.loaded,
          attendanceList: attendance,
          getAttendanceError: '',
        )),
      );
    } catch (error, stack) {
      print('Error in getLectureAttendance: $error');
      print(stack);
      emit(state.copyWith(
        getAttendanceState: RequestState.error,
        getAttendanceError: error.toString(),
      ));
    }
  }

  Future<void> checkIn({required String lectureId}) async {
    emit(state.copyWith(
      checkInState: RequestState.loading,
      checkInError: '',
    ));

    try {
      final result = await repository.checkIn(lectureId: lectureId);

      result.showSnackBarOnError().fold(
        (failure) => emit(state.copyWith(
          checkInState: RequestState.error,
          checkInError: failure.message,
        )),
        (attendance) {
          emit(state.copyWith(
            checkInState: RequestState.loaded,
            attendanceList: [...state.attendanceList, attendance],
            checkInError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in checkIn: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        checkInState: RequestState.error,
        checkInError: error.toString(),
      ));
    }
  }

  Future<void> updateAttendanceStatus({
    required String attendanceId,
    required String status,
  }) async {
    emit(state.copyWith(
      updateAttendanceState: RequestState.loading,
      updateAttendanceError: '',
    ));

    try {
      final result = await repository.updateAttendanceStatus(
        attendanceId: attendanceId,
        status: status,
      );

      result.showSnackBarOnError().fold(
        (failure) => emit(state.copyWith(
          updateAttendanceState: RequestState.error,
          updateAttendanceError: failure.message,
        )),
        (_) => emit(state.copyWith(
          updateAttendanceState: RequestState.loaded,
          updateAttendanceError: '',
        )),
      );
    } catch (error, stack) {
      print('Error in updateAttendanceStatus: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        updateAttendanceState: RequestState.error,
        updateAttendanceError: error.toString(),
      ));
    }
  }

  // ── Resets ──
  void resetCreateLectureState() {
    emit(state.copyWith(
      createLectureState: RequestState.initial,
      createLectureError: '',
    ));
  }

  void resetCheckInState() {
    emit(state.copyWith(
      checkInState: RequestState.initial,
      checkInError: '',
    ));
  }
}
