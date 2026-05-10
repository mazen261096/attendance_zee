import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/file_cache_service.dart';
import '../../../core/utils/core_utils.dart';
import '../../../core/utils/enums.dart';
import '../data/file_repository.dart';
import 'file_state.dart';

class FileCubit extends Cubit<FileState> {
  FileCubit({required this.repository}) : super(const FileState());

  final BaseFileRepository repository;

  // ─────────────────────────────────────────────────────────────────────────
  // Load — merged course + lecture files
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> getCourseFilesWithLectures({required String courseId}) async {
    emit(state.copyWith(
      getFilesState: RequestState.loading,
      getFilesError: '',
    ));

    final result = await repository.getCourseFilesWithLectures(
      courseId: courseId,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        getFilesState: RequestState.error,
        getFilesError: failure.message,
      )),
      (files) => emit(state.copyWith(
        getFilesState: RequestState.loaded,
        files: files,
        getFilesError: '',
      )),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Load — lecture-scoped only
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> getLectureFiles({required String lectureId}) async {
    emit(state.copyWith(
      getFilesState: RequestState.loading,
      getFilesError: '',
    ));

    final result = await repository.getLectureFiles(lectureId: lectureId);

    result.fold(
      (failure) => emit(state.copyWith(
        getFilesState: RequestState.error,
        getFilesError: failure.message,
      )),
      (files) => emit(state.copyWith(
        getFilesState: RequestState.loaded,
        files: files,
        getFilesError: '',
      )),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Upload — course file
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> uploadCourseFile({
    required String courseId,
    required XFile pickedFile,
  }) async {
    emit(state.copyWith(
      uploadState: RequestState.loading,
      uploadProgress: 0.0,
      uploadError: '',
    ));

    final result = await repository.uploadCourseFile(
      courseId: courseId,
      pickedFile: pickedFile,
      onProgress: (sent, total) {
        if (!isClosed) {
          emit(state.copyWith(uploadProgress: sent / total));
        }
      },
    );

    result.fold(
      (failure) {
        CoreUtils.showErrorSnackBar(message: failure.message);
        emit(state.copyWith(
          uploadState: RequestState.error,
          uploadError: failure.message,
        ));
      },
      (file) => emit(state.copyWith(
        uploadState: RequestState.loaded,
        uploadProgress: 1.0,
        files: [file, ...state.files],
        uploadError: '',
      )),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Upload — lecture file
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> uploadLectureFile({
    required String courseId,
    required String lectureId,
    required XFile pickedFile,
  }) async {
    emit(state.copyWith(
      uploadState: RequestState.loading,
      uploadProgress: 0.0,
      uploadError: '',
    ));

    final result = await repository.uploadLectureFile(
      courseId: courseId,
      lectureId: lectureId,
      pickedFile: pickedFile,
      onProgress: (sent, total) {
        if (!isClosed) {
          emit(state.copyWith(uploadProgress: sent / total));
        }
      },
    );

    result.fold(
      (failure) {
        CoreUtils.showErrorSnackBar(message: failure.message);
        emit(state.copyWith(
          uploadState: RequestState.error,
          uploadError: failure.message,
        ));
      },
      (file) => emit(state.copyWith(
        uploadState: RequestState.loaded,
        uploadProgress: 1.0,
        files: [file, ...state.files],
        uploadError: '',
      )),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Delete — course file
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> deleteCourseFile({
    required String fileId,
    required String objectKey,
  }) async {
    emit(state.copyWith(
      deleteState: RequestState.loading,
      deleteError: '',
    ));

    final result = await repository.deleteCourseFile(
      fileId: fileId,
      objectKey: objectKey,
    );

    result.fold(
      (failure) {
        CoreUtils.showErrorSnackBar(message: failure.message);
        emit(state.copyWith(
          deleteState: RequestState.error,
          deleteError: failure.message,
        ));
      },
      (_) => emit(state.copyWith(
        deleteState: RequestState.loaded,
        files: state.files.where((f) => f.id != fileId).toList(),
        deleteError: '',
      )),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Delete — lecture file
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> deleteLectureFile({
    required String fileId,
    required String objectKey,
  }) async {
    emit(state.copyWith(
      deleteState: RequestState.loading,
      deleteError: '',
    ));

    final result = await repository.deleteLectureFile(
      fileId: fileId,
      objectKey: objectKey,
    );

    result.fold(
      (failure) {
        CoreUtils.showErrorSnackBar(message: failure.message);
        emit(state.copyWith(
          deleteState: RequestState.error,
          deleteError: failure.message,
        ));
      },
      (_) => emit(state.copyWith(
        deleteState: RequestState.loaded,
        files: state.files.where((f) => f.id != fileId).toList(),
        deleteError: '',
      )),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Open file — cache-first then download
  //
  // Flow:
  //   1. Check local cache  →  if found, open immediately (no loading)
  //   2. Fetch signed URL from Worker
  //   3. Stream download into cache dir, emitting progress per tick
  //   4. Open local file with native viewer
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> openFile({
    required String fileId,
    required String objectKey,
  }) async {
    if (objectKey.isEmpty) return;
    if (isClosed) return;

    final cache = FileCacheService.instance;

    // ── 1. Check cache ──
    final cached = await cache.getCachedPath(objectKey);
    if (cached != null) {
      debugPrint('[FileCubit] Cache hit → opening $cached');
      await cache.openLocal(cached);
      return;
    }

    // ── 2. Fetch signed URL ──
    _setDownloadProgress(fileId, 0.0);

    final urlResult = await repository.getSignedDownloadUrl(objectKey);

    if (urlResult.isLeft()) {
      final failure = urlResult.fold((f) => f, (_) => null)!;
      CoreUtils.showErrorSnackBar(message: 'Could not get download URL: ${failure.message}');
      _clearDownloadProgress(fileId);
      return;
    }

    final signedUrl = urlResult.fold((_) => '', (url) => url);

    // ── 3. Stream download ──
    final localPath = await cache.downloadToCache(
      signedUrl: signedUrl,
      objectKey: objectKey,
      onProgress: (p) {
        if (!isClosed) _setDownloadProgress(fileId, p);
      },
    );

    _clearDownloadProgress(fileId);

    if (localPath == null) {
      CoreUtils.showErrorSnackBar(message: 'Download failed. Please try again.');
      return;
    }

    // ── 4. Open locally ──
    try {
      await cache.openLocal(localPath);
    } catch (e) {
      CoreUtils.showErrorSnackBar(
        message: 'Cannot open file: please restart the app and try again.',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Resets
  // ─────────────────────────────────────────────────────────────────────────

  void resetUploadState() {
    emit(state.copyWith(
      uploadState: RequestState.initial,
      uploadProgress: 0.0,
      uploadError: '',
    ));
  }

  void resetDeleteState() {
    emit(state.copyWith(
      deleteState: RequestState.initial,
      deleteError: '',
    ));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────

  void _setDownloadProgress(String fileId, double progress) {
    if (isClosed) return;
    final updated = Map<String, double>.from(state.downloadProgress);
    updated[fileId] = progress;
    emit(state.copyWith(downloadProgress: updated));
  }

  void _clearDownloadProgress(String fileId) {
    if (isClosed) return;
    final updated = Map<String, double>.from(state.downloadProgress);
    updated.remove(fileId);
    emit(state.copyWith(downloadProgress: updated));
  }
}
