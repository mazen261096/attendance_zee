import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/enums.dart';
import '../../../core/utils/either_extensions.dart';
import '../../../core/utils/core_utils.dart';
import '../../courses/data/models/course_member_model.dart';
import '../data/grade_repository.dart';
import '../data/models/student_grade_model.dart';
import 'grade_state.dart';

class GradeCubit extends Cubit<GradeState> {
  GradeCubit({required this.repository}) : super(const GradeState());

  final BaseGradeRepository repository;

  // ──────────────────────────────────────────────
  // Grade Items
  // ──────────────────────────────────────────────

  Future<void> getCourseGradeItems({required String courseId}) async {
    emit(state.copyWith(
      getGradeItemsState: RequestState.loading,
      getGradeItemsError: '',
    ));

    try {
      final result = await repository.getCourseGradeItems(courseId: courseId);

      result.fold(
        (failure) => emit(state.copyWith(
          getGradeItemsState: RequestState.error,
          getGradeItemsError: failure.message,
        )),
        (items) => emit(state.copyWith(
          getGradeItemsState: RequestState.loaded,
          gradeItems: items,
          getGradeItemsError: '',
        )),
      );
    } catch (error, stack) {
      print('Error in getCourseGradeItems: $error');
      print(stack);
      emit(state.copyWith(
        getGradeItemsState: RequestState.error,
        getGradeItemsError: error.toString(),
      ));
    }
  }

  Future<void> createGradeItem({
    required String courseId,
    required String name,
    required String type,
    required double maxDegree,
  }) async {
    emit(state.copyWith(
      createGradeItemState: RequestState.loading,
      createGradeItemError: '',
    ));

    try {
      final result = await repository.createGradeItem(
        courseId: courseId,
        name: name,
        type: type,
        maxDegree: maxDegree,
      );

      result.showSnackBarOnError().fold(
        (failure) => emit(state.copyWith(
          createGradeItemState: RequestState.error,
          createGradeItemError: failure.message,
        )),
        (item) {
          emit(state.copyWith(
            createGradeItemState: RequestState.loaded,
            gradeItems: [...state.gradeItems, item],
            createGradeItemError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in createGradeItem: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        createGradeItemState: RequestState.error,
        createGradeItemError: error.toString(),
      ));
    }
  }

  Future<void> updateGradeItem({
    required String gradeItemId,
    String? name,
    String? type,
    double? maxDegree,
  }) async {
    emit(state.copyWith(
      updateGradeItemState: RequestState.loading,
      updateGradeItemError: '',
    ));

    try {
      final result = await repository.updateGradeItem(
        gradeItemId: gradeItemId,
        name: name,
        type: type,
        maxDegree: maxDegree,
      );

      result.showSnackBarOnError().fold(
        (failure) => emit(state.copyWith(
          updateGradeItemState: RequestState.error,
          updateGradeItemError: failure.message,
        )),
        (item) {
          final updatedList = state.gradeItems
              .map((i) => i.id == item.id ? item : i)
              .toList();
          emit(state.copyWith(
            updateGradeItemState: RequestState.loaded,
            gradeItems: updatedList,
            updateGradeItemError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in updateGradeItem: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        updateGradeItemState: RequestState.error,
        updateGradeItemError: error.toString(),
      ));
    }
  }

  Future<void> deleteGradeItem({required String gradeItemId}) async {
    emit(state.copyWith(
      deleteGradeItemState: RequestState.loading,
      deleteGradeItemError: '',
    ));

    try {
      final result = await repository.deleteGradeItem(gradeItemId: gradeItemId);

      result.showSnackBarOnError().fold(
        (failure) => emit(state.copyWith(
          deleteGradeItemState: RequestState.error,
          deleteGradeItemError: failure.message,
        )),
        (_) {
          final updatedList =
              state.gradeItems.where((i) => i.id != gradeItemId).toList();
          emit(state.copyWith(
            deleteGradeItemState: RequestState.loaded,
            gradeItems: updatedList,
            deleteGradeItemError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in deleteGradeItem: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        deleteGradeItemState: RequestState.error,
        deleteGradeItemError: error.toString(),
      ));
    }
  }

  // ──────────────────────────────────────────────
  // Student Grades
  // ──────────────────────────────────────────────

  Future<void> getGradesForItem({required String gradeItemId}) async {
    emit(state.copyWith(
      getGradesForItemState: RequestState.loading,
      getGradesForItemError: '',
    ));

    try {
      final result =
          await repository.getGradesForItem(gradeItemId: gradeItemId);

      result.fold(
        (failure) => emit(state.copyWith(
          getGradesForItemState: RequestState.error,
          getGradesForItemError: failure.message,
        )),
        (grades) => emit(state.copyWith(
          getGradesForItemState: RequestState.loaded,
          gradesForItem: grades,
          getGradesForItemError: '',
        )),
      );
    } catch (error, stack) {
      print('Error in getGradesForItem: $error');
      print(stack);
      emit(state.copyWith(
        getGradesForItemState: RequestState.error,
        getGradesForItemError: error.toString(),
      ));
    }
  }

  Future<void> getMyGrades({required String courseId}) async {
    emit(state.copyWith(
      getMyGradesState: RequestState.loading,
      getMyGradesError: '',
    ));

    try {
      final result = await repository.getMyGrades(courseId: courseId);

      result.fold(
        (failure) => emit(state.copyWith(
          getMyGradesState: RequestState.error,
          getMyGradesError: failure.message,
        )),
        (grades) => emit(state.copyWith(
          getMyGradesState: RequestState.loaded,
          myGrades: grades,
          getMyGradesError: '',
        )),
      );
    } catch (error, stack) {
      print('Error in getMyGrades: $error');
      print(stack);
      emit(state.copyWith(
        getMyGradesState: RequestState.error,
        getMyGradesError: error.toString(),
      ));
    }
  }

  Future<void> setStudentGrade({
    required String gradeItemId,
    required String userId,
    required double degree,
  }) async {
    emit(state.copyWith(
      setGradeState: RequestState.loading,
      setGradeError: '',
    ));

    try {
      final result = await repository.setStudentGrade(
        gradeItemId: gradeItemId,
        userId: userId,
        degree: degree,
      );

      result.showSnackBarOnError().fold(
        (failure) => emit(state.copyWith(
          setGradeState: RequestState.error,
          setGradeError: failure.message,
        )),
        (grade) {
          // Replace or add grade in the list
          final updatedList = List.of(state.gradesForItem);
          final existingIndex = updatedList.indexWhere(
            (g) => g.gradeItemId == gradeItemId && g.userId == userId,
          );
          if (existingIndex != -1) {
            updatedList[existingIndex] = grade;
          } else {
            updatedList.add(grade);
          }
          emit(state.copyWith(
            setGradeState: RequestState.loaded,
            gradesForItem: updatedList,
            setGradeError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in setStudentGrade: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        setGradeState: RequestState.error,
        setGradeError: error.toString(),
      ));
    }
  }

  Future<void> deleteStudentGrade({required String gradeId}) async {
    emit(state.copyWith(
      deleteGradeState: RequestState.loading,
      deleteGradeError: '',
    ));

    try {
      final result = await repository.deleteStudentGrade(gradeId: gradeId);

      result.showSnackBarOnError().fold(
        (failure) => emit(state.copyWith(
          deleteGradeState: RequestState.error,
          deleteGradeError: failure.message,
        )),
        (_) {
          final updatedList =
              state.gradesForItem.where((g) => g.id != gradeId).toList();
          emit(state.copyWith(
            deleteGradeState: RequestState.loaded,
            gradesForItem: updatedList,
            deleteGradeError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in deleteStudentGrade: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        deleteGradeState: RequestState.error,
        deleteGradeError: error.toString(),
      ));
    }
  }

  // ──────────────────────────────────────────────
  // All My Grades (global tab)
  // ──────────────────────────────────────────────

  Future<void> getAllMyGrades() async {
    emit(state.copyWith(
      getMyGradesState: RequestState.loading,
      getMyGradesError: '',
    ));

    try {
      final result = await repository.getAllMyGrades();

      result.fold(
        (failure) => emit(state.copyWith(
          getMyGradesState: RequestState.error,
          getMyGradesError: failure.message,
        )),
        (grades) => emit(state.copyWith(
          getMyGradesState: RequestState.loaded,
          myGrades: grades,
          getMyGradesError: '',
        )),
      );
    } catch (error, stack) {
      print('Error in getAllMyGrades: $error');
      print(stack);
      emit(state.copyWith(
        getMyGradesState: RequestState.error,
        getMyGradesError: error.toString(),
      ));
    }
  }

  // ──────────────────────────────────────────────
  // Load Members With Grades (unified view)
  // ──────────────────────────────────────────────

  Future<void> loadMembersWithGrades({
    required String courseId,
    required String gradeItemId,
  }) async {
    emit(state.copyWith(
      getGradesForItemState: RequestState.loading,
      getGradesForItemError: '',
    ));

    try {
      final membersResult =
          await repository.getCourseMembersForGrading(courseId: courseId);
      final gradesResult =
          await repository.getGradesForItem(gradeItemId: gradeItemId);

      final members = membersResult.fold(
        (failure) => throw failure,
        (data) => data,
      );

      final existingGrades = gradesResult.fold(
        (failure) => throw failure,
        (grades) => grades,
      );

      // Map userId -> existing grade
      final gradeMap = <String, StudentGradeModel>{};
      for (final grade in existingGrades) {
        gradeMap[grade.userId] = grade;
      }

      // Build unified list: one entry per course member
      final unified = <StudentGradeModel>[];
      for (final member in members) {
        final userId = member['user_id'] as String;
        final profile = member['profiles'] as Map<String, dynamic>?;

        if (gradeMap.containsKey(userId)) {
          unified.add(gradeMap[userId]!);
        } else {
          // Placeholder: no grade saved yet
          unified.add(StudentGradeModel(
            gradeItemId: gradeItemId,
            userId: userId,
            degree: 0,
            userName: profile?['name'],
            userAvatarUrl: profile?['avatar_url'],
          ));
        }
      }

      emit(state.copyWith(
        getGradesForItemState: RequestState.loaded,
        gradesForItem: unified,
        getGradesForItemError: '',
      ));
    } catch (error, stack) {
      print('Error in loadMembersWithGrades: $error');
      print(stack);
      emit(state.copyWith(
        getGradesForItemState: RequestState.error,
        getGradesForItemError: error.toString(),
      ));
    }
  }

  // ──────────────────────────────────────────────
  // Total Grades
  // ──────────────────────────────────────────────

  Future<void> getTotalGrades({required String courseId}) async {
    emit(state.copyWith(
      getTotalGradesState: RequestState.loading,
      getTotalGradesError: '',
    ));

    try {
      final results = await Future.wait([
        repository.getTotalGrades(courseId: courseId),
        repository.getCourseGradeItems(courseId: courseId),
      ]);

      final membersResult = results[0] as dynamic;
      final itemsResult = results[1] as dynamic;

      // Compute total max from grade items
      double totalMax = 0;
      itemsResult.fold(
        (_) {},
        (items) {
          for (final item in items) {
            totalMax += item.maxDegree;
          }
        },
      );

      membersResult.fold(
        (failure) => emit(state.copyWith(
          getTotalGradesState: RequestState.error,
          getTotalGradesError: failure.message,
        )),
        (members) {
          final parsed = (members as List)
              .map((m) => CourseMemberModel.fromJson(m as Map<String, dynamic>))
              .toList();
          emit(state.copyWith(
            getTotalGradesState: RequestState.loaded,
            totalGradeMembers: parsed,
            totalMaxDegree: totalMax,
            getTotalGradesError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in getTotalGrades: $error');
      print(stack);
      emit(state.copyWith(
        getTotalGradesState: RequestState.error,
        getTotalGradesError: error.toString(),
      ));
    }
  }

  // ── Resets ──
  void resetCreateGradeItemState() {
    emit(state.copyWith(
      createGradeItemState: RequestState.initial,
      createGradeItemError: '',
    ));
  }

  void resetSetGradeState() {
    emit(state.copyWith(
      setGradeState: RequestState.initial,
      setGradeError: '',
    ));
  }
}
