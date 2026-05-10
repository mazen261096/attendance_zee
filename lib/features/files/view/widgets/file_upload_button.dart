import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../view_model/file_cubit.dart';
import '../../view_model/file_state.dart';


// ─────────────────────────────────────────────────────────────────────────────
// FileUploadButton
//
// A self-contained upload widget that:
//  1. Lets the user pick a file (image, video, or PDF via image_picker)
//  2. Triggers the upload via FileCubit
//  3. Shows a progress bar during upload (critical for large videos)
//  4. Reports success / error via SnackBar (handled by FileCubit)
//
// Usage:
//   FileUploadButton(
//     label: 'Attach file',
//     onUpload: (file) => cubit.uploadCourseFile(courseId: id, pickedFile: file),
//   )
// ─────────────────────────────────────────────────────────────────────────────

class FileUploadButton extends StatefulWidget {
  const FileUploadButton({
    super.key,
    this.label = 'Attach file',
    this.icon = Icons.attach_file_rounded,
    required this.onUpload,
  });

  /// Called with the picked XFile — caller decides whether it's a course or
  /// lecture upload and triggers the appropriate cubit method.
  final Future<void> Function(XFile file) onUpload;

  final String label;
  final IconData icon;

  @override
  State<FileUploadButton> createState() => _FileUploadButtonState();
}

class _FileUploadButtonState extends State<FileUploadButton> {
  final _picker = ImagePicker();

  // ── File picker sheet ────────────────────────────────────────────────────

  Future<void> _pickAndUpload() async {
    final choice = await _showPickerSheet();
    if (choice == null || !mounted) return;

    XFile? file;
    switch (choice) {
      case _PickChoice.image:
        file = await _picker.pickImage(source: ImageSource.gallery);
        break;
      case _PickChoice.video:
        file = await _picker.pickVideo(source: ImageSource.gallery);
        break;
      case _PickChoice.pdf:
        // image_picker doesn't support PDF directly; use file_picker if added.
        // For now we show a note to the user.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'PDF uploads require the file_picker package. '
                'Add it to pubspec.yaml and update this picker.',
              ),
            ),
          );
        }
        return;
    }

    if (file == null || !mounted) return;
    await widget.onUpload(file);
  }

  Future<_PickChoice?> _showPickerSheet() {
    return showModalBottomSheet<_PickChoice>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.image_rounded, color: Colors.teal),
              title: const Text('Image'),
              subtitle: const Text('Up to 10 MB'),
              onTap: () => Navigator.pop(context, _PickChoice.image),
            ),
            ListTile(
              leading: const Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.deepPurple,
              ),
              title: const Text('Video'),
              subtitle: const Text('Up to 200 MB'),
              onTap: () => Navigator.pop(context, _PickChoice.video),
            ),
            ListTile(
              leading:
                  Icon(Icons.picture_as_pdf_rounded, color: Colors.red.shade700),
              title: const Text('PDF'),
              subtitle: const Text('Up to 20 MB'),
              onTap: () => Navigator.pop(context, _PickChoice.pdf),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<FileCubit, FileState>(
      buildWhen: (p, c) =>
          p.uploadState != c.uploadState ||
          p.uploadProgress != c.uploadProgress,
      builder: (ctx, fileState) {
        final isUploading = fileState.isUploading;
        final progress = fileState.uploadProgress;

        if (isUploading) {
          return _UploadProgress(progress: progress);
        }

        return FilledButton.icon(
          onPressed: _pickAndUpload,
          icon: Icon(widget.icon, size: 18),
          label: Text(widget.label),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.primaryContainer,
            foregroundColor: theme.colorScheme.onPrimaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _UploadProgress — shown while bytes are being streamed to R2
// ─────────────────────────────────────────────────────────────────────────────

class _UploadProgress extends StatelessWidget {
  const _UploadProgress({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  value: progress > 0 ? progress : null,
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                progress > 0 ? 'Uploading $pct%…' : 'Preparing upload…',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          if (progress > 0) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal enum for bottom sheet selection
// ─────────────────────────────────────────────────────────────────────────────

enum _PickChoice { image, video, pdf }
