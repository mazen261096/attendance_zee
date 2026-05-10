import 'package:equatable/equatable.dart';
import '../../../core/utils/enums.dart';
import '../data/models/file_model.dart';

class FileState extends Equatable {
  // ── File list ──
  final RequestState getFilesState;
  final String getFilesError;
  final List<FileModel> files;

  // ── Upload ──
  final RequestState uploadState;
  final String uploadError;
  final double uploadProgress; // 0.0 → 1.0

  // ── Delete ──
  final RequestState deleteState;
  final String deleteError;

  // ── Download / open (per-file) ──
  // fileId → download progress (0.0 → 1.0); entry removed when done/failed
  final Map<String, double> downloadProgress;
  final String downloadError;

  const FileState({
    this.getFilesState = RequestState.initial,
    this.getFilesError = '',
    this.files = const [],
    this.uploadState = RequestState.initial,
    this.uploadError = '',
    this.uploadProgress = 0.0,
    this.deleteState = RequestState.initial,
    this.deleteError = '',
    this.downloadProgress = const {},
    this.downloadError = '',
  });

  FileState copyWith({
    RequestState? getFilesState,
    String? getFilesError,
    List<FileModel>? files,
    RequestState? uploadState,
    String? uploadError,
    double? uploadProgress,
    RequestState? deleteState,
    String? deleteError,
    Map<String, double>? downloadProgress,
    String? downloadError,
  }) {
    return FileState(
      getFilesState: getFilesState ?? this.getFilesState,
      getFilesError: getFilesError ?? this.getFilesError,
      files: files ?? this.files,
      uploadState: uploadState ?? this.uploadState,
      uploadError: uploadError ?? this.uploadError,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      deleteState: deleteState ?? this.deleteState,
      deleteError: deleteError ?? this.deleteError,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadError: downloadError ?? this.downloadError,
    );
  }

  // ── Convenience getters ──
  bool get isLoading => getFilesState == RequestState.loading;
  bool get isUploading => uploadState == RequestState.loading;
  bool get isDeleting => deleteState == RequestState.loading;
  bool get uploadSuccess => uploadState == RequestState.loaded;
  bool get deleteSuccess => deleteState == RequestState.loaded;

  /// Whether a specific file is currently being downloaded
  bool isDownloading(String fileId) => downloadProgress.containsKey(fileId);

  /// Download progress for a specific file (0.0 → 1.0), or null if idle
  double? progressFor(String fileId) => downloadProgress[fileId];

  @override
  List<Object?> get props => [
        getFilesState,
        getFilesError,
        files,
        uploadState,
        uploadError,
        uploadProgress,
        deleteState,
        deleteError,
        downloadProgress,
        downloadError,
      ];
}
