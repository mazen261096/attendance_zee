import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/enums.dart';
import '../../../files/view/widgets/file_list_tile.dart';
import '../../../files/view/widgets/file_upload_button.dart';
import '../../../files/view_model/file_cubit.dart';
import '../../../files/view_model/file_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LectureFilesTab
//
// Shows only this lecture's files.
// Pass [courseId] (needed for the upload call) and [lectureId].
// ─────────────────────────────────────────────────────────────────────────────

class LectureFilesTab extends StatelessWidget {
  const LectureFilesTab({
    super.key,
    required this.courseId,
    required this.lectureId,
    required this.isAdmin,
  });

  final String courseId;
  final String lectureId;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FileCubit>(
      create: (_) =>
          getIt<FileCubit>()..getLectureFiles(lectureId: lectureId),
      child: _LectureFilesBody(
        courseId: courseId,
        lectureId: lectureId,
        isAdmin: isAdmin,
      ),
    );
  }
}

class _LectureFilesBody extends StatelessWidget {
  const _LectureFilesBody({
    required this.courseId,
    required this.lectureId,
    required this.isAdmin,
  });

  final String courseId;
  final String lectureId;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<FileCubit, FileState>(
      listenWhen: (p, c) =>
          p.uploadState != c.uploadState || p.deleteState != c.deleteState,
      listener: (ctx, state) {
        if (state.uploadSuccess) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text('File uploaded'),
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
          ctx.read<FileCubit>().resetDeleteState();
        }
      },
      builder: (ctx, state) {
        return RefreshIndicator(
          onRefresh: () =>
              ctx.read<FileCubit>().getLectureFiles(lectureId: lectureId),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Upload button (admin only) ─────────────────────────────
              if (isAdmin)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: FileUploadButton(
                      label: 'Attach to lecture',
                      icon: Icons.video_library_rounded,
                      onUpload: (file) =>
                          ctx.read<FileCubit>().uploadLectureFile(
                                courseId: courseId,
                                lectureId: lectureId,
                                pickedFile: file,
                              ),
                    ),
                  ),
                ),

              // ── States ────────────────────────────────────────────────
              if (state.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.getFilesState == RequestState.error)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_off_rounded,
                            size: 56,
                            color: theme.colorScheme.error.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text(state.getFilesError,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => ctx
                              .read<FileCubit>()
                              .getLectureFiles(lectureId: lectureId),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (state.files.isEmpty &&
                  state.getFilesState == RequestState.loaded)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.folder_open_rounded,
                            size: 64,
                            color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        Text(
                          'No lecture files yet',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => FileListTile(
                      file: state.files[i],
                      isAdmin: isAdmin,
                    ),
                    childCount: state.files.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      },
    );
  }
}
