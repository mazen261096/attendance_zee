import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../data/models/join_request_model.dart';

class JoinRequestTile extends StatelessWidget {
  final JoinRequestModel request;
  final bool isApproving;
  final bool isRejecting;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const JoinRequestTile({
    super.key,
    required this.request,
    this.isApproving = false,
    this.isRejecting = false,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppConfig.warningColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          _buildAvatar(),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.userName ?? 'Unknown User',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _timeAgo(request.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Reject
              _ActionButton(
                icon: Icons.close_rounded,
                color: AppConfig.errorColor,
                isLoading: isRejecting,
                onTap: onReject,
              ),
              const SizedBox(width: 8),
              // Approve
              _ActionButton(
                icon: Icons.check_rounded,
                color: AppConfig.successColor,
                isLoading: isApproving,
                onTap: onApprove,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (request.userAvatarUrl != null) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(request.userAvatarUrl!),
      );
    }
    final initial = (request.userName ?? '?')[0].toUpperCase();
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppConfig.warningColor.withValues(alpha: 0.15),
      child: Text(
        initial,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppConfig.warningColor,
          fontSize: 16,
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: isLoading
            ? Padding(
                padding: const EdgeInsets.all(8),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              )
            : Icon(icon, color: color, size: 20),
      ),
    );
  }
}
