import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/enums.dart';
import '../../data/models/course_member_model.dart';

class MemberTile extends StatelessWidget {
  final CourseMemberModel member;
  final bool isCurrentUserAdmin;
  final String currentUserId;
  final void Function(CourseMemberModel member)? onRemove;
  final void Function(CourseMemberModel member, MemberRole newRole)? onRoleChange;

  const MemberTile({
    super.key,
    required this.member,
    required this.isCurrentUserAdmin,
    required this.currentUserId,
    this.onRemove,
    this.onRoleChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMe = member.userId == currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: _buildAvatar(),
        title: Row(
          children: [
            Expanded(
              child: Text(
                member.userName ?? 'Unknown',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            if (isMe)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'You',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: member.isAdmin
                    ? AppConfig.primaryColor.withValues(alpha: 0.1)
                    : AppConfig.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                member.isAdmin ? 'Admin' : 'Student',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: member.isAdmin
                      ? AppConfig.primaryColor
                      : AppConfig.accentColor,
                ),
              ),
            ),
          ],
        ),
        trailing: (isCurrentUserAdmin && !isMe)
            ? PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                  size: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'role',
                    child: Row(
                      children: [
                        const Icon(Icons.swap_horiz_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(member.isAdmin
                            ? 'Make Student'
                            : 'Make Admin'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.person_remove_outlined,
                            size: 18, color: AppConfig.errorColor),
                        SizedBox(width: 8),
                        Text('Remove',
                            style: TextStyle(color: AppConfig.errorColor)),
                      ],
                    ),
                  ),
                ],
                onSelected: (val) {
                  if (val == 'role') {
                    final newRole = member.isAdmin
                        ? MemberRole.student
                        : MemberRole.admin;
                    onRoleChange?.call(member, newRole);
                  } else if (val == 'remove') {
                    onRemove?.call(member);
                  }
                },
              )
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (member.userAvatarUrl != null) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(member.userAvatarUrl!),
      );
    }
    final initial = (member.userName ?? '?')[0].toUpperCase();
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
}
