import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/enums.dart';
import '../../../files/data/models/file_model.dart';
import '../../../files/view/widgets/file_list_tile.dart';
import '../../../files/view/widgets/file_upload_button.dart';
import '../../../files/view_model/file_cubit.dart';
import '../../../files/view_model/file_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FilesTab
//
// Drop this widget into any tab bar as a child tab for a course detail screen.
// Pass [courseId] and [isAdmin] from the parent.
// ─────────────────────────────────────────────────────────────────────────────

class FilesTab extends StatelessWidget {
  const FilesTab({
    super.key,
    required this.courseId,
    required this.isAdmin,
  });

  final String courseId;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FileCubit>(
      create: (_) => getIt<FileCubit>()
        ..getCourseFilesWithLectures(courseId: courseId),
      child: _FilesTabBody(courseId: courseId, isAdmin: isAdmin),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _FilesTabBody — internal stateful body
// ─────────────────────────────────────────────────────────────────────────────

class _FilesTabBody extends StatelessWidget {
  const _FilesTabBody({
    required this.courseId,
    required this.isAdmin,
  });

  final String courseId;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FileCubit, FileState>(
      listenWhen: (p, c) =>
          p.uploadState != c.uploadState ||
          p.deleteState != c.deleteState,

      listener: (ctx, state) {
        if (state.uploadSuccess) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text('File uploaded successfully'),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
          ctx.read<FileCubit>().resetUploadState();
        }

        if (state.deleteSuccess) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: const Text('File deleted'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
          ctx.read<FileCubit>().resetDeleteState();
        }

      },

      builder: (ctx, state) {
        return RefreshIndicator(
          onRefresh: () =>
              ctx.read<FileCubit>().getCourseFilesWithLectures(courseId: courseId),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Upload button (admin only) ─────────────────────────────
              if (isAdmin)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: FileUploadButton(
                      label: 'Upload file',
                      onUpload: (file) =>
                          ctx.read<FileCubit>().uploadCourseFile(
                                courseId: courseId,
                                pickedFile: file,
                              ),
                    ),
                  ),
                ),

              // ── Loading state ──────────────────────────────────────────
              if (state.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )

              // ── Error state ────────────────────────────────────────────
              else if (state.getFilesState == RequestState.error)
                SliverFillRemaining(
                  child: _ErrorPlaceholder(
                    message: state.getFilesError,
                    onRetry: () => ctx
                        .read<FileCubit>()
                        .getCourseFilesWithLectures(courseId: courseId),
                  ),
                )

              // ── Empty state ────────────────────────────────────────────
              else if (state.files.isEmpty &&
                  state.getFilesState == RequestState.loaded)
                SliverFillRemaining(
                  child: _EmptyPlaceholder(isAdmin: isAdmin),
                )

              // ── File list ─────────────────────────────────────────────
              else ...[
                // Group label: Course files
                if (state.files.any((f) => f.scope.isCourse)) ...[
                  _SectionHeader(
                    icon: Icons.folder_rounded,
                    label: 'Course Files',
                    count: state.files
                        .where((f) => f.scope.isCourse)
                        .length,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final courseFiles =
                            state.files.where((f) => f.scope.isCourse).toList();
                        return FileListTile(
                          file: courseFiles[i],
                          isAdmin: isAdmin,
                        );
                      },
                      childCount: state.files
                          .where((f) => f.scope.isCourse)
                          .length,
                    ),
                  ),
                ],

                // Group label: Lecture files (grouped by lecture title)
                if (state.files.any((f) => f.scope.isLecture)) ...[
                  _SectionHeader(
                    icon: Icons.video_library_rounded,
                    label: 'Lecture Files',
                    count: state.files
                        .where((f) => f.scope.isLecture)
                        .length,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final lectureFiles = state.files
                            .where((f) => f.scope.isLecture)
                            .toList();
                        return _LectureFileSection(
                          file: lectureFiles[i],
                          isAdmin: isAdmin,
                          showLectureHeader: i == 0 ||
                              lectureFiles[i].scopeId !=
                                  lectureFiles[i - 1].scopeId,
                        );
                      },
                      childCount: state.files
                          .where((f) => f.scope.isLecture)
                          .length,
                    ),
                  ),
                ],

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LectureFileSection — shows lecture title header before first file in group
// ─────────────────────────────────────────────────────────────────────────────

class _LectureFileSection extends StatelessWidget {
  const _LectureFileSection({
    required this.file,
    required this.isAdmin,
    required this.showLectureHeader,
  });

  final FileModel file;
  final bool isAdmin;
  final bool showLectureHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLectureHeader && file.lectureTitle != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 16, 4),
            child: Row(
              children: [
                Icon(
                  Icons.smart_display_rounded,
                  size: 14,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    file.lectureTitle!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        FileListTile(file: file, isAdmin: isAdmin),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SectionHeader
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EmptyPlaceholder
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder({required this.isAdmin});
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: 72,
              color: theme.colorScheme.outline.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No files yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (isAdmin) ...[
              const SizedBox(height: 8),
              Text(
                'Tap "Upload file" above to add course\nmaterials or lecture resources.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ErrorPlaceholder
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 72,
              color: theme.colorScheme.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load files',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
