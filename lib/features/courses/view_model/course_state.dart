import 'package:equatable/equatable.dart';
import '../../../core/utils/enums.dart';
import '../data/models/course_model.dart';
import '../data/models/course_member_model.dart';
import '../data/models/join_request_model.dart';
import '../data/models/course_file_model.dart';

class CourseState extends Equatable {
  // ── My Courses List ──
  final RequestState getCoursesState;
  final String getCoursesError;
  final List<CourseModel> courses;

  // ── Single Course ──
  final RequestState getCourseState;
  final String getCourseError;
  final CourseModel? currentCourse;

  // ── Create / Update / Delete Course ──
  final RequestState createCourseState;
  final String createCourseError;

  final RequestState updateCourseState;
  final String updateCourseError;

  final RequestState deleteCourseState;
  final String deleteCourseError;

  // ── Members ──
  final RequestState getMembersState;
  final String getMembersError;
  final List<CourseMemberModel> members;

  final RequestState removeMemberState;
  final String removeMemberError;

  // ── Join Requests ──
  final RequestState joinCourseState;
  final String joinCourseError;

  final RequestState getJoinRequestsState;
  final String getJoinRequestsError;
  final List<JoinRequestModel> joinRequests;

  final RequestState approveRequestState;
  final String approveRequestError;

  final RequestState rejectRequestState;
  final String rejectRequestError;

  // ── Course Files ──
  final RequestState getCourseFilesState;
  final String getCourseFilesError;
  final List<CourseFileModel> courseFiles;

  final RequestState uploadFileState;
  final String uploadFileError;

  final RequestState deleteFileState;
  final String deleteFileError;

  const CourseState({
    this.getCoursesState = RequestState.initial,
    this.getCoursesError = '',
    this.courses = const [],
    this.getCourseState = RequestState.initial,
    this.getCourseError = '',
    this.currentCourse,
    this.createCourseState = RequestState.initial,
    this.createCourseError = '',
    this.updateCourseState = RequestState.initial,
    this.updateCourseError = '',
    this.deleteCourseState = RequestState.initial,
    this.deleteCourseError = '',
    this.getMembersState = RequestState.initial,
    this.getMembersError = '',
    this.members = const [],
    this.removeMemberState = RequestState.initial,
    this.removeMemberError = '',
    this.joinCourseState = RequestState.initial,
    this.joinCourseError = '',
    this.getJoinRequestsState = RequestState.initial,
    this.getJoinRequestsError = '',
    this.joinRequests = const [],
    this.approveRequestState = RequestState.initial,
    this.approveRequestError = '',
    this.rejectRequestState = RequestState.initial,
    this.rejectRequestError = '',
    this.getCourseFilesState = RequestState.initial,
    this.getCourseFilesError = '',
    this.courseFiles = const [],
    this.uploadFileState = RequestState.initial,
    this.uploadFileError = '',
    this.deleteFileState = RequestState.initial,
    this.deleteFileError = '',
  });

  CourseState copyWith({
    RequestState? getCoursesState,
    String? getCoursesError,
    List<CourseModel>? courses,
    RequestState? getCourseState,
    String? getCourseError,
    CourseModel? currentCourse,
    RequestState? createCourseState,
    String? createCourseError,
    RequestState? updateCourseState,
    String? updateCourseError,
    RequestState? deleteCourseState,
    String? deleteCourseError,
    RequestState? getMembersState,
    String? getMembersError,
    List<CourseMemberModel>? members,
    RequestState? removeMemberState,
    String? removeMemberError,
    RequestState? joinCourseState,
    String? joinCourseError,
    RequestState? getJoinRequestsState,
    String? getJoinRequestsError,
    List<JoinRequestModel>? joinRequests,
    RequestState? approveRequestState,
    String? approveRequestError,
    RequestState? rejectRequestState,
    String? rejectRequestError,
    RequestState? getCourseFilesState,
    String? getCourseFilesError,
    List<CourseFileModel>? courseFiles,
    RequestState? uploadFileState,
    String? uploadFileError,
    RequestState? deleteFileState,
    String? deleteFileError,
  }) {
    return CourseState(
      getCoursesState: getCoursesState ?? this.getCoursesState,
      getCoursesError: getCoursesError ?? this.getCoursesError,
      courses: courses ?? this.courses,
      getCourseState: getCourseState ?? this.getCourseState,
      getCourseError: getCourseError ?? this.getCourseError,
      currentCourse: currentCourse ?? this.currentCourse,
      createCourseState: createCourseState ?? this.createCourseState,
      createCourseError: createCourseError ?? this.createCourseError,
      updateCourseState: updateCourseState ?? this.updateCourseState,
      updateCourseError: updateCourseError ?? this.updateCourseError,
      deleteCourseState: deleteCourseState ?? this.deleteCourseState,
      deleteCourseError: deleteCourseError ?? this.deleteCourseError,
      getMembersState: getMembersState ?? this.getMembersState,
      getMembersError: getMembersError ?? this.getMembersError,
      members: members ?? this.members,
      removeMemberState: removeMemberState ?? this.removeMemberState,
      removeMemberError: removeMemberError ?? this.removeMemberError,
      joinCourseState: joinCourseState ?? this.joinCourseState,
      joinCourseError: joinCourseError ?? this.joinCourseError,
      getJoinRequestsState: getJoinRequestsState ?? this.getJoinRequestsState,
      getJoinRequestsError: getJoinRequestsError ?? this.getJoinRequestsError,
      joinRequests: joinRequests ?? this.joinRequests,
      approveRequestState: approveRequestState ?? this.approveRequestState,
      approveRequestError: approveRequestError ?? this.approveRequestError,
      rejectRequestState: rejectRequestState ?? this.rejectRequestState,
      rejectRequestError: rejectRequestError ?? this.rejectRequestError,
      getCourseFilesState: getCourseFilesState ?? this.getCourseFilesState,
      getCourseFilesError: getCourseFilesError ?? this.getCourseFilesError,
      courseFiles: courseFiles ?? this.courseFiles,
      uploadFileState: uploadFileState ?? this.uploadFileState,
      uploadFileError: uploadFileError ?? this.uploadFileError,
      deleteFileState: deleteFileState ?? this.deleteFileState,
      deleteFileError: deleteFileError ?? this.deleteFileError,
    );
  }

  // ── Convenience Getters ──
  bool get isGetCoursesLoading => getCoursesState == RequestState.loading;
  bool get isGetCoursesSuccess => getCoursesState == RequestState.loaded;
  bool get hasGetCoursesError => getCoursesState == RequestState.error;

  bool get isCreateCourseLoading => createCourseState == RequestState.loading;
  bool get isCreateCourseSuccess => createCourseState == RequestState.loaded;

  bool get isJoinCourseLoading => joinCourseState == RequestState.loading;
  bool get isJoinCourseSuccess => joinCourseState == RequestState.loaded;

  bool get isGetMembersLoading => getMembersState == RequestState.loading;
  bool get isGetJoinRequestsLoading => getJoinRequestsState == RequestState.loading;
  bool get isGetCourseFilesLoading => getCourseFilesState == RequestState.loading;

  @override
  List<Object?> get props => [
        getCoursesState, getCoursesError, courses,
        getCourseState, getCourseError, currentCourse,
        createCourseState, createCourseError,
        updateCourseState, updateCourseError,
        deleteCourseState, deleteCourseError,
        getMembersState, getMembersError, members,
        removeMemberState, removeMemberError,
        joinCourseState, joinCourseError,
        getJoinRequestsState, getJoinRequestsError, joinRequests,
        approveRequestState, approveRequestError,
        rejectRequestState, rejectRequestError,
        getCourseFilesState, getCourseFilesError, courseFiles,
        uploadFileState, uploadFileError,
        deleteFileState, deleteFileError,
      ];
}
