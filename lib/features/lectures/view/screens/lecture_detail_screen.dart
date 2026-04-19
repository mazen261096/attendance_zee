import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../data/models/lecture_model.dart';
import '../../view_model/lecture_cubit.dart';
import '../../view_model/lecture_state.dart';
import '../widgets/attendance_tile.dart';

class LectureDetailScreen extends StatefulWidget {
  final LectureModel lecture;

  const LectureDetailScreen({super.key, required this.lecture});

  @override
  State<LectureDetailScreen> createState() => _LectureDetailScreenState();
}

class _LectureDetailScreenState extends State<LectureDetailScreen> {
  late final LectureCubit _lectureCubit;
  late final String _currentUserId;
  late bool _isAdmin;

  // Local copy of the lecture so we can reflect toggle changes instantly
  late LectureModel _lecture;

  @override
  void initState() {
    super.initState();
    _currentUserId = SupabaseService().currentUser?.id ?? '';
    _isAdmin = widget.lecture.createdBy == _currentUserId;
    _lecture = widget.lecture;
    _lectureCubit = getIt<LectureCubit>();

    _lectureCubit.getLectureAttendance(lectureId: widget.lecture.id);
    _lectureCubit.getLectureFiles(lectureId: widget.lecture.id);
  }

  @override
  void dispose() {
    _lectureCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider.value(
      value: _lectureCubit,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text(
            _lecture.title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
        ),
        body: BlocConsumer<LectureCubit, LectureState>(
          listener: (context, state) {
            // Reflect attendance toggle in local state
            if (state.toggleAttendanceState == RequestState.loaded &&
                state.currentLecture != null &&
                state.currentLecture!.id == _lecture.id) {
              setState(() => _lecture = state.currentLecture!);
            }
            if (state.isCheckInSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Checked in successfully!'),
                  backgroundColor: AppConfig.successColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                _lectureCubit.getLectureAttendance(lectureId: _lecture.id);
                _lectureCubit.getLectureFiles(lectureId: _lecture.id);
              },
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ── Lecture Info Card ──
                  _buildInfoCard(theme, isDark, state),
                  const SizedBox(height: 20),

                  // ── Admin: Toggle Attendance Button ──
                  if (_isAdmin) ...[
                    _buildToggleButton(context, state, isDark),
                    const SizedBox(height: 20),
                  ],

                  // ── Student: Check-In Button (only when open) ──
                  if (!_isAdmin && _lecture.isAttendanceOpen) ...[
                    _buildCheckInButton(context, state, isDark),
                    const SizedBox(height: 20),
                  ],

                  // ── Attendance Section ──
                  _buildSectionHeader(
                    theme,
                    isDark,
                    Icons.fact_check_outlined,
                    'Attendance (${state.attendanceList.length})',
                  ),
                  const SizedBox(height: 12),
                  if (state.isGetAttendanceLoading)
                    const AppLoadingIndicator(itemCount: 3)
                  else if (state.attendanceList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: AppEmptyState(
                        icon: Icons.person_off_outlined,
                        title: 'No Check-Ins',
                        subtitle: 'No students have checked in yet',
                      ),
                    )
                  else
                    ...state.attendanceList.map(
                      (a) => AttendanceTile(
                        attendance: a,
                        isAdmin: _isAdmin,
                        onStatusChange: (newStatus) {
                          _lectureCubit.updateAttendanceStatus(
                            attendanceId: a.id,
                            status: newStatus.value,
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 24),

                  // ── Files Section ──
                  _buildSectionHeader(
                    theme,
                    isDark,
                    Icons.attach_file_rounded,
                    'Files (${state.lectureFiles.length})',
                  ),
                  const SizedBox(height: 12),
                  if (state.isGetLectureFilesLoading)
                    const AppLoadingIndicator(itemCount: 2)
                  else if (state.lectureFiles.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: AppEmptyState(
                        icon: Icons.folder_open_outlined,
                        title: 'No Files',
                        subtitle: 'No materials attached to this lecture',
                      ),
                    )
                  else
                    ...state.lectureFiles.map(
                      (f) => ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppConfig.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.insert_drive_file_outlined,
                            color: AppConfig.accentColor,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          f.fileName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        trailing: _isAdmin
                            ? IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppConfig.errorColor,
                                  size: 20,
                                ),
                                onPressed: () => _lectureCubit
                                    .deleteLectureFile(fileId: f.id),
                              )
                            : const Icon(Icons.download_outlined, size: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Info Card ──
  Widget _buildInfoCard(ThemeData theme, bool isDark, LectureState state) {
    final status = _lecture.lectureStatus;
    final attendanceOpen = _lecture.isAttendanceOpen;

    final statusColor = switch (status) {
      LectureStatus.upcoming => AppConfig.primaryColor,
      LectureStatus.active => AppConfig.successColor,
      LectureStatus.ended => Colors.grey,
    };
    final statusLabel = switch (status) {
      LectureStatus.upcoming => '● Upcoming',
      LectureStatus.active => '● Active',
      LectureStatus.ended => '● Ended',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1E38), const Color(0xFF1A1A2E)]
              : [
                  AppConfig.primaryColor.withValues(alpha: 0.06),
                  AppConfig.primaryLightColor.withValues(alpha: 0.03),
                ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppConfig.primaryColor.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _lecture.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Time-based status badge
              _InfoBadge(label: statusLabel, color: statusColor),
            ],
          ),
          const SizedBox(height: 8),
          // Attendance open/closed badge (manual)
          _InfoBadge(
            label: attendanceOpen
                ? '🔓 Attendance Open'
                : '🔒 Attendance Closed',
            color: attendanceOpen ? AppConfig.successColor : Colors.grey,
            small: true,
          ),
          if (_lecture.description != null) ...[
            const SizedBox(height: 8),
            Text(
              _lecture.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.play_circle_outline_rounded,
            label: 'Start',
            value: _format(_lecture.startTime),
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.stop_circle_outlined,
            label: 'End',
            value: _format(_lecture.endTime),
          ),
        ],
      ),
    );
  }

  // ── Admin Toggle Button ──
  Widget _buildToggleButton(
    BuildContext context,
    LectureState state,
    bool isDark,
  ) {
    final isOpen = _lecture.isAttendanceOpen;
    final isLoading = state.isToggleAttendanceLoading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isLoading
            ? null
            : () => _lectureCubit.toggleAttendance(
                lectureId: _lecture.id,
                isOpen: !isOpen,
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isOpen
              ? AppConfig.errorColor.withValues(alpha: 0.9)
              : AppConfig.successColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        icon: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Icon(
                isOpen ? Icons.fingerprint_outlined : Icons.fingerprint,
                size: 26,
              ),
        label: Text(
          isLoading
              ? 'Updating...'
              : isOpen
              ? 'Close Attendance'
              : 'Open Attendance',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // ── Student Check-In Button ──
  Widget _buildCheckInButton(
    BuildContext context,
    LectureState state,
    bool isDark,
  ) {
    final alreadyCheckedIn = state.attendanceList.any(
      (a) => a.userId == _currentUserId,
    );

    if (alreadyCheckedIn) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppConfig.successColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppConfig.successColor.withValues(alpha: 0.25),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AppConfig.successColor,
              size: 24,
            ),
            SizedBox(width: 10),
            Text(
              'Already Checked In',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppConfig.successColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: state.isCheckInLoading
            ? null
            : () => _lectureCubit.checkIn(lectureId: _lecture.id),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConfig.successColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: state.isCheckInLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.how_to_reg_rounded, size: 24),
        label: Text(
          state.isCheckInLoading ? 'Checking In...' : 'Check In Now',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    ThemeData theme,
    bool isDark,
    IconData icon,
    String title,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? Colors.grey[400] : Colors.grey[700],
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _format(DateTime dt) {
    // Convert to device local timezone for display
    final local = dt.toLocal();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    final min = local.minute.toString().padLeft(2, '0');
    return '${months[local.month - 1]} ${local.day} at $h:$min $ampm';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 16, color: AppConfig.primaryLightColor),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool small;

  const _InfoBadge({
    required this.label,
    required this.color,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: small ? 11 : 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
