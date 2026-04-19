import 'package:equatable/equatable.dart';
import '../../../core/utils/enums.dart';
import '../data/models/grade_item_model.dart';
import '../data/models/student_grade_model.dart';

class GradeState extends Equatable {
  // ── Grade Items ──
  final RequestState getGradeItemsState;
  final String getGradeItemsError;
  final List<GradeItemModel> gradeItems;

  final RequestState createGradeItemState;
  final String createGradeItemError;

  final RequestState updateGradeItemState;
  final String updateGradeItemError;

  final RequestState deleteGradeItemState;
  final String deleteGradeItemError;

  // ── Student Grades (admin view: all grades for an item) ──
  final RequestState getGradesForItemState;
  final String getGradesForItemError;
  final List<StudentGradeModel> gradesForItem;

  // ── My Grades (student view: my grades in a course) ──
  final RequestState getMyGradesState;
  final String getMyGradesError;
  final List<StudentGradeModel> myGrades;

  // ── Set / Delete Grade ──
  final RequestState setGradeState;
  final String setGradeError;

  final RequestState deleteGradeState;
  final String deleteGradeError;

  const GradeState({
    this.getGradeItemsState = RequestState.initial,
    this.getGradeItemsError = '',
    this.gradeItems = const [],
    this.createGradeItemState = RequestState.initial,
    this.createGradeItemError = '',
    this.updateGradeItemState = RequestState.initial,
    this.updateGradeItemError = '',
    this.deleteGradeItemState = RequestState.initial,
    this.deleteGradeItemError = '',
    this.getGradesForItemState = RequestState.initial,
    this.getGradesForItemError = '',
    this.gradesForItem = const [],
    this.getMyGradesState = RequestState.initial,
    this.getMyGradesError = '',
    this.myGrades = const [],
    this.setGradeState = RequestState.initial,
    this.setGradeError = '',
    this.deleteGradeState = RequestState.initial,
    this.deleteGradeError = '',
  });

  GradeState copyWith({
    RequestState? getGradeItemsState,
    String? getGradeItemsError,
    List<GradeItemModel>? gradeItems,
    RequestState? createGradeItemState,
    String? createGradeItemError,
    RequestState? updateGradeItemState,
    String? updateGradeItemError,
    RequestState? deleteGradeItemState,
    String? deleteGradeItemError,
    RequestState? getGradesForItemState,
    String? getGradesForItemError,
    List<StudentGradeModel>? gradesForItem,
    RequestState? getMyGradesState,
    String? getMyGradesError,
    List<StudentGradeModel>? myGrades,
    RequestState? setGradeState,
    String? setGradeError,
    RequestState? deleteGradeState,
    String? deleteGradeError,
  }) {
    return GradeState(
      getGradeItemsState: getGradeItemsState ?? this.getGradeItemsState,
      getGradeItemsError: getGradeItemsError ?? this.getGradeItemsError,
      gradeItems: gradeItems ?? this.gradeItems,
      createGradeItemState: createGradeItemState ?? this.createGradeItemState,
      createGradeItemError: createGradeItemError ?? this.createGradeItemError,
      updateGradeItemState: updateGradeItemState ?? this.updateGradeItemState,
      updateGradeItemError: updateGradeItemError ?? this.updateGradeItemError,
      deleteGradeItemState: deleteGradeItemState ?? this.deleteGradeItemState,
      deleteGradeItemError: deleteGradeItemError ?? this.deleteGradeItemError,
      getGradesForItemState: getGradesForItemState ?? this.getGradesForItemState,
      getGradesForItemError: getGradesForItemError ?? this.getGradesForItemError,
      gradesForItem: gradesForItem ?? this.gradesForItem,
      getMyGradesState: getMyGradesState ?? this.getMyGradesState,
      getMyGradesError: getMyGradesError ?? this.getMyGradesError,
      myGrades: myGrades ?? this.myGrades,
      setGradeState: setGradeState ?? this.setGradeState,
      setGradeError: setGradeError ?? this.setGradeError,
      deleteGradeState: deleteGradeState ?? this.deleteGradeState,
      deleteGradeError: deleteGradeError ?? this.deleteGradeError,
    );
  }

  // ── Convenience Getters ──
  bool get isGetGradeItemsLoading => getGradeItemsState == RequestState.loading;
  bool get isGetGradeItemsSuccess => getGradeItemsState == RequestState.loaded;
  bool get hasGetGradeItemsError => getGradeItemsState == RequestState.error;

  bool get isCreateGradeItemLoading => createGradeItemState == RequestState.loading;
  bool get isCreateGradeItemSuccess => createGradeItemState == RequestState.loaded;

  bool get isGetGradesForItemLoading => getGradesForItemState == RequestState.loading;
  bool get isGetMyGradesLoading => getMyGradesState == RequestState.loading;
  bool get isGetMyGradesSuccess => getMyGradesState == RequestState.loaded;

  bool get isSetGradeLoading => setGradeState == RequestState.loading;
  bool get isSetGradeSuccess => setGradeState == RequestState.loaded;

  @override
  List<Object?> get props => [
        getGradeItemsState, getGradeItemsError, gradeItems,
        createGradeItemState, createGradeItemError,
        updateGradeItemState, updateGradeItemError,
        deleteGradeItemState, deleteGradeItemError,
        getGradesForItemState, getGradesForItemError, gradesForItem,
        getMyGradesState, getMyGradesError, myGrades,
        setGradeState, setGradeError,
        deleteGradeState, deleteGradeError,
      ];
}
