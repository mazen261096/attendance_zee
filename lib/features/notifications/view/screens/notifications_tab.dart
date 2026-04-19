import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../view_model/notification_cubit.dart';
import '../../view_model/notification_state.dart';
import '../widgets/notification_tile.dart';

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              // These cubit methods take no params
              context.read<NotificationCubit>().getNotifications();
              context.read<NotificationCubit>().getUnreadCount();
            },
            child: CustomScrollView(
              slivers: [
                // ── Header ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notifications',
                                style:
                                    theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              if (state.hasUnread) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '${state.unreadCount} unread',
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (state.hasUnread)
                          TextButton(
                            onPressed: state.isMarkAllAsReadLoading
                                ? null
                                : () => context
                                    .read<NotificationCubit>()
                                    .markAllAsRead(),
                            child: const Text(
                              'Mark All Read',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // ── Content ──
                if (state.isGetNotificationsLoading)
                  const SliverFillRemaining(
                    child: AppLoadingIndicator(),
                  )
                else if (state.notifications.isEmpty)
                  const SliverFillRemaining(
                    child: AppEmptyState(
                      icon: Icons.notifications_off_outlined,
                      title: 'No Notifications',
                      subtitle:
                          "You're all caught up!\nNotifications will appear here.",
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    sliver: SliverList.separated(
                      itemCount: state.notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final notif = state.notifications[index];
                        return NotificationTile(
                          notification: notif,
                          onTap: () {
                            if (!notif.isRead) {
                              context
                                  .read<NotificationCubit>()
                                  .markAsRead(notificationId: notif.id);
                            }
                          },
                          onDismiss: () {
                            context
                                .read<NotificationCubit>()
                                .deleteNotification(
                                    notificationId: notif.id);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
