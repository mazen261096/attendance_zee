import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/file_cache_service.dart';
import '../../data/models/file_model.dart';
import '../../view_model/file_cubit.dart';
import '../../view_model/file_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FileListTile
//
// Displays a single file row.
//  • Tap  → cache-first download then open with native app (no browser!)
//  • Long-press (admin) → confirm delete dialog
//
// Tracks local cache status so it shows ✓ when already downloaded.
// ─────────────────────────────────────────────────────────────────────────────

class FileListTile extends StatefulWidget {
  const FileListTile({
    super.key,
    required this.file,
    required this.isAdmin,
    this.onDeleted,
  });

  final FileModel file;
  final bool isAdmin;
  final VoidCallback? onDeleted;

  @override
  State<FileListTile> createState() => _FileListTileState();
}

class _FileListTileState extends State<FileListTile> {
  bool _isCached = false;

  @override
  void initState() {
    super.initState();
    _checkCache();
  }

  Future<void> _checkCache() async {
    final path = await FileCacheService.instance
        .getCachedPath(widget.file.objectKey);
    if (mounted && path != null) {
      setState(() => _isCached = true);
    }
  }

  // ── Icon per MIME category ──────────────────────────────────────────────

  IconData _icon() {
    switch (widget.file.mimeCategory) {
      case 'video':
        return Icons.play_circle_fill_rounded;
      case 'image':
        return Icons.image_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _iconColor(BuildContext ctx) {
    switch (widget.file.mimeCategory) {
      case 'video':
        return Colors.deepPurple;
      case 'image':
        return Colors.teal;
      case 'pdf':
        return Colors.red.shade700;
      default:
        return Theme.of(ctx).colorScheme.primary;
    }
  }

  // ── Long-press: delete (admin only) ────────────────────────────────────

  Future<void> _confirmDelete(BuildContext ctx) async {
    final confirm = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Delete file?'),
        content: Text(
            'Remove "${widget.file.fileName}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !ctx.mounted) return;

    final cubit = ctx.read<FileCubit>();
    if (widget.file.scope.isCourse) {
      await cubit.deleteCourseFile(
        fileId: widget.file.id,
        objectKey: widget.file.objectKey,
      );
    } else {
      await cubit.deleteLectureFile(
        fileId: widget.file.id,
        objectKey: widget.file.objectKey,
      );
    }
    widget.onDeleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _iconColor(context);

    return BlocConsumer<FileCubit, FileState>(
      // Rebuild only when this file's download state changes
      listenWhen: (p, c) =>
          p.isDownloading(widget.file.id) != c.isDownloading(widget.file.id),
      listener: (ctx, state) {
        // When download finishes (entry removed from map) → re-check cache
        if (!state.isDownloading(widget.file.id)) {
          _checkCache();
        }
      },
      buildWhen: (p, c) =>
          p.isDownloading(widget.file.id) != c.isDownloading(widget.file.id) ||
          p.progressFor(widget.file.id) != c.progressFor(widget.file.id),
      builder: (ctx, fileState) {
        final downloading = fileState.isDownloading(widget.file.id);
        final progress = fileState.progressFor(widget.file.id) ?? 0.0;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.4),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: downloading
                ? null
                : () => ctx.read<FileCubit>().openFile(
                      fileId: widget.file.id,
                      objectKey: widget.file.objectKey,
                    ),
            onLongPress:
                widget.isAdmin ? () => _confirmDelete(ctx) : null,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      // ── File type icon ──
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(_icon(), color: color, size: 24),
                      ),
                      const SizedBox(width: 12),

                      // ── Name + metadata ──
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.file.fileName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                if (widget.file.scope.isLecture &&
                                    widget.file.lectureTitle != null) ...[
                                  Icon(
                                    Icons.video_library_rounded,
                                    size: 12,
                                    color: theme.colorScheme.secondary,
                                  ),
                                  const SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      widget.file.lectureTitle!,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: theme.colorScheme.secondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                if (widget.file.fileSizeLabel.isNotEmpty)
                                  Text(
                                    widget.file.fileSizeLabel,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ── Action icon (right side) ──
                      const SizedBox(width: 8),
                      _buildActionIcon(downloading, progress, color),
                    ],
                  ),
                ),

                // ── Thin progress bar at bottom while downloading ──
                if (downloading && progress > 0)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 3,
                      color: color,
                      backgroundColor: color.withValues(alpha: 0.12),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionIcon(bool downloading, double progress, Color color) {
    if (downloading) {
      // Circular indicator with % text
      return SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: progress > 0 ? progress : null,
              strokeWidth: 2.5,
              color: color,
            ),
            if (progress > 0)
              Center(
                child: Text(
                  '${(progress * 100).round()}',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    if (_isCached) {
      // Already on device — show open/check icon
      return Icon(
        Icons.check_circle_rounded,
        size: 20,
        color: Colors.green.shade600,
      );
    }

    // Not yet downloaded
    return Icon(
      Icons.download_rounded,
      size: 20,
      color: Colors.grey.withValues(alpha: 0.5),
    );
  }
}
