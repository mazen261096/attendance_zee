import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/notification_service/notification_config.dart';
import '../../../../core/notification_service/models/notification_types.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../view_model/notification_cubit.dart';
import '../../view_model/notification_state.dart';
import '../widgets/notification_tile.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isNearBottom) {
      context.read<NotificationCubit>().loadMoreNotifications();
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger at 200px before the end
    return currentScroll >= (maxScroll - 200);
  }

  void _onNotificationTap(
    BuildContext context,
    NotificationCubit cubit,
    notification,
  ) {
    // Mark as read
    if (!notification.isRead) {
      cubit.markAsRead(notificationId: notification.id);
    }

    // Navigate based on notification type and data
    if (notification.data != null) {
      final notifData = NotificationData(
        notification.type,
        notification.data!,
      );
      NotificationNavigation.navigate(context, notifData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final cubit = context.read<NotificationCubit>();

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              cubit.getNotifications();
            },
            child: CustomScrollView(
              controller: _scrollController,
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
                                : () => cubit.markAllAsRead(),
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
                else ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    sliver: SliverList.separated(
                      itemCount: state.notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final notif = state.notifications[index];
                        return NotificationTile(
                          notification: notif,
                          onTap: () => _onNotificationTap(
                            context,
                            cubit,
                            notif,
                          ),
                          onDismiss: () {
                            cubit.deleteNotification(
                                notificationId: notif.id);
                          },
                        );
                      },
                    ),
                  ),
                  // ── Load More Indicator ──
                  if (state.isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        ),
                      ),
                    ),
                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
