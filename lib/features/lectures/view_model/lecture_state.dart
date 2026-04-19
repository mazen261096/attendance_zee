import 'package:equatable/equatable.dart';
import '../../../core/utils/enums.dart';
import '../data/models/lecture_model.dart';
import '../data/models/lecture_file_model.dart';
import '../data/models/lecture_attendance_model.dart';

class LectureState extends Equatable {
  // ── Lectures List ──
  final RequestState getLecturesState;
  final String getLecturesError;
  final List<LectureModel> lectures;

  // ── Single Lecture ──
  final RequestState getLectureState;
  final String getLectureError;
  final LectureModel? currentLecture;

  // ── Create / Update / Delete ──
  final RequestState createLectureState;
  final String createLectureError;

  final RequestState updateLectureState;
  final String updateLectureError;

  final RequestState deleteLectureState;
  final String deleteLectureError;

  // ── Toggle Attendance ──
  final RequestState toggleAttendanceState;
  final String toggleAttendanceError;

  // ── Lecture Files ──
  final RequestState getLectureFilesState;
  final String getLectureFilesError;
  final List<LectureFileModel> lectureFiles;

  final RequestState addLectureFileState;
  final String addLectureFileError;

  final RequestState deleteLectureFileState;
  final String deleteLectureFileError;

  // ── Attendance ──
  final RequestState getAttendanceState;
  final String getAttendanceError;
  final List<LectureAttendanceModel> attendanceList;

  final RequestState checkInState;
  final String checkInError;

  final RequestState updateAttendanceState;
  final String updateAttendanceError;

  const LectureState({
    this.getLecturesState = RequestState.initial,
    this.getLecturesError = '',
    this.lectures = const [],
    this.getLectureState = RequestState.initial,
    this.getLectureError = '',
    this.currentLecture,
    this.createLectureState = RequestState.initial,
    this.createLectureError = '',
    this.updateLectureState = RequestState.initial,
    this.updateLectureError = '',
    this.deleteLectureState = RequestState.initial,
    this.deleteLectureError = '',
    this.toggleAttendanceState = RequestState.initial,
    this.toggleAttendanceError = '',
    this.getLectureFilesState = RequestState.initial,
    this.getLectureFilesError = '',
    this.lectureFiles = const [],
    this.addLectureFileState = RequestState.initial,
    this.addLectureFileError = '',
    this.deleteLectureFileState = RequestState.initial,
    this.deleteLectureFileError = '',
    this.getAttendanceState = RequestState.initial,
    this.getAttendanceError = '',
    this.attendanceList = const [],
    this.checkInState = RequestState.initial,
    this.checkInError = '',
    this.updateAttendanceState = RequestState.initial,
    this.updateAttendanceError = '',
  });

  LectureState copyWith({
    RequestState? getLecturesState,
    String? getLecturesError,
    List<LectureModel>? lectures,
    RequestState? getLectureState,
    String? getLectureError,
    LectureModel? currentLecture,
    RequestState? createLectureState,
    String? createLectureError,
    RequestState? updateLectureState,
    String? updateLectureError,
    RequestState? deleteLectureState,
    String? deleteLectureError,
    RequestState? toggleAttendanceState,
    String? toggleAttendanceError,
    RequestState? getLectureFilesState,
    String? getLectureFilesError,
    List<LectureFileModel>? lectureFiles,
    RequestState? addLectureFileState,
    String? addLectureFileError,
    RequestState? deleteLectureFileState,
    String? deleteLectureFileError,
    RequestState? getAttendanceState,
    String? getAttendanceError,
    List<LectureAttendanceModel>? attendanceList,
    RequestState? checkInState,
    String? checkInError,
    RequestState? updateAttendanceState,
    String? updateAttendanceError,
  }) {
    return LectureState(
      getLecturesState: getLecturesState ?? this.getLecturesState,
      getLecturesError: getLecturesError ?? this.getLecturesError,
      lectures: lectures ?? this.lectures,
      getLectureState: getLectureState ?? this.getLectureState,
      getLectureError: getLectureError ?? this.getLectureError,
      currentLecture: currentLecture ?? this.currentLecture,
      createLectureState: createLectureState ?? this.createLectureState,
      createLectureError: createLectureError ?? this.createLectureError,
      updateLectureState: updateLectureState ?? this.updateLectureState,
      updateLectureError: updateLectureError ?? this.updateLectureError,
      deleteLectureState: deleteLectureState ?? this.deleteLectureState,
      deleteLectureError: deleteLectureError ?? this.deleteLectureError,
      toggleAttendanceState:
          toggleAttendanceState ?? this.toggleAttendanceState,
      toggleAttendanceError:
          toggleAttendanceError ?? this.toggleAttendanceError,
      getLectureFilesState: getLectureFilesState ?? this.getLectureFilesState,
      getLectureFilesError: getLectureFilesError ?? this.getLectureFilesError,
      lectureFiles: lectureFiles ?? this.lectureFiles,
      addLectureFileState: addLectureFileState ?? this.addLectureFileState,
      addLectureFileError: addLectureFileError ?? this.addLectureFileError,
      deleteLectureFileState:
          deleteLectureFileState ?? this.deleteLectureFileState,
      deleteLectureFileError:
          deleteLectureFileError ?? this.deleteLectureFileError,
      getAttendanceState: getAttendanceState ?? this.getAttendanceState,
      getAttendanceError: getAttendanceError ?? this.getAttendanceError,
      attendanceList: attendanceList ?? this.attendanceList,
      checkInState: checkInState ?? this.checkInState,
      checkInError: checkInError ?? this.checkInError,
      updateAttendanceState:
          updateAttendanceState ?? this.updateAttendanceState,
      updateAttendanceError:
          updateAttendanceError ?? this.updateAttendanceError,
    );
  }

  // ── Convenience Getters ──
  bool get isGetLecturesLoading => getLecturesState == RequestState.loading;
  bool get isGetLecturesSuccess => getLecturesState == RequestState.loaded;
  bool get hasGetLecturesError => getLecturesState == RequestState.error;

  bool get isCreateLectureLoading => createLectureState == RequestState.loading;
  bool get isCreateLectureSuccess => createLectureState == RequestState.loaded;

  bool get isToggleAttendanceLoading =>
      toggleAttendanceState == RequestState.loading;

  bool get isCheckInLoading => checkInState == RequestState.loading;
  bool get isCheckInSuccess => checkInState == RequestState.loaded;
  bool get hasCheckInError => checkInState == RequestState.error;

  bool get isGetAttendanceLoading =>
      getAttendanceState == RequestState.loading;
  bool get isGetLectureFilesLoading =>
      getLectureFilesState == RequestState.loading;

  @override
  List<Object?> get props => [
        getLecturesState, getLecturesError, lectures,
        getLectureState, getLectureError, currentLecture,
        createLectureState, createLectureError,
        updateLectureState, updateLectureError,
        deleteLectureState, deleteLectureError,
        toggleAttendanceState, toggleAttendanceError,
        getLectureFilesState, getLectureFilesError, lectureFiles,
        addLectureFileState, addLectureFileError,
        deleteLectureFileState, deleteLectureFileError,
        getAttendanceState, getAttendanceError, attendanceList,
        checkInState, checkInError,
        updateAttendanceState, updateAttendanceError,
      ];
}
