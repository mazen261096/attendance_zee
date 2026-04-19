import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/enums.dart';
import '../../data/models/lecture_attendance_model.dart';

class AttendanceTile extends StatelessWidget {
  final LectureAttendanceModel attendance;
  final bool isAdmin;
  final void Function(AttendanceStatus newStatus)? onStatusChange;

  const AttendanceTile({
    super.key,
    required this.attendance,
    this.isAdmin = false,
    this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: _buildAvatar(),
        title: Text(
          attendance.userName ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              _formatTime(attendance.checkedInAt),
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: isAdmin
            ? PopupMenuButton<AttendanceStatus>(
                onSelected: onStatusChange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _StatusChip(status: attendance.status),
                itemBuilder: (_) =>
                    AttendanceStatus.values.map((s) {
                      return PopupMenuItem(
                        value: s,
                        child: Row(
                          children: [
                            _statusDot(s),
                            const SizedBox(width: 8),
                            Text(_statusLabel(s)),
                          ],
                        ),
                      );
                    }).toList(),
              )
            : _StatusChip(status: attendance.status),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (attendance.userAvatarUrl != null) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(attendance.userAvatarUrl!),
      );
    }
    final initial = (attendance.userName ?? '?')[0].toUpperCase();
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppConfig.primaryColor.withValues(alpha: 0.15),
      child: Text(
        initial,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppConfig.primaryColor,
          fontSize: 16,
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$h:$min $ampm';
  }

  static Widget _statusDot(AttendanceStatus status) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _statusColor(status),
      ),
    );
  }

  static Color _statusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return AppConfig.successColor;
      case AttendanceStatus.late_:
        return AppConfig.warningColor;
      case AttendanceStatus.absent:
        return AppConfig.errorColor;
    }
  }

  static String _statusLabel(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.late_:
        return 'Late';
      case AttendanceStatus.absent:
        return 'Absent';
    }
  }
}

class _StatusChip extends StatelessWidget {
  final AttendanceStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AttendanceTile._statusColor(status);
    final label = AttendanceTile._statusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
