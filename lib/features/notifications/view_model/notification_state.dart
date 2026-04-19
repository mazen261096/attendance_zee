import 'package:equatable/equatable.dart';
import '../../../core/utils/enums.dart';
import '../data/models/notification_model.dart';

class NotificationState extends Equatable {
  final RequestState getNotificationsState;
  final String getNotificationsError;
  final List<NotificationModel> notifications;

  final RequestState getUnreadCountState;
  final int unreadCount;

  final RequestState markAsReadState;
  final String markAsReadError;

  final RequestState markAllAsReadState;
  final String markAllAsReadError;

  final RequestState deleteNotificationState;
  final String deleteNotificationError;

  const NotificationState({
    this.getNotificationsState = RequestState.initial,
    this.getNotificationsError = '',
    this.notifications = const [],
    this.getUnreadCountState = RequestState.initial,
    this.unreadCount = 0,
    this.markAsReadState = RequestState.initial,
    this.markAsReadError = '',
    this.markAllAsReadState = RequestState.initial,
    this.markAllAsReadError = '',
    this.deleteNotificationState = RequestState.initial,
    this.deleteNotificationError = '',
  });

  NotificationState copyWith({
    RequestState? getNotificationsState,
    String? getNotificationsError,
    List<NotificationModel>? notifications,
    RequestState? getUnreadCountState,
    int? unreadCount,
    RequestState? markAsReadState,
    String? markAsReadError,
    RequestState? markAllAsReadState,
    String? markAllAsReadError,
    RequestState? deleteNotificationState,
    String? deleteNotificationError,
  }) {
    return NotificationState(
      getNotificationsState:
          getNotificationsState ?? this.getNotificationsState,
      getNotificationsError:
          getNotificationsError ?? this.getNotificationsError,
      notifications: notifications ?? this.notifications,
      getUnreadCountState: getUnreadCountState ?? this.getUnreadCountState,
      unreadCount: unreadCount ?? this.unreadCount,
      markAsReadState: markAsReadState ?? this.markAsReadState,
      markAsReadError: markAsReadError ?? this.markAsReadError,
      markAllAsReadState: markAllAsReadState ?? this.markAllAsReadState,
      markAllAsReadError: markAllAsReadError ?? this.markAllAsReadError,
      deleteNotificationState:
          deleteNotificationState ?? this.deleteNotificationState,
      deleteNotificationError:
          deleteNotificationError ?? this.deleteNotificationError,
    );
  }

  // ── Convenience Getters ──
  bool get isGetNotificationsLoading =>
      getNotificationsState == RequestState.loading;
  bool get isGetNotificationsSuccess =>
      getNotificationsState == RequestState.loaded;
  bool get hasGetNotificationsError =>
      getNotificationsState == RequestState.error;

  bool get hasUnread => unreadCount > 0;

  bool get isMarkAllAsReadLoading =>
      markAllAsReadState == RequestState.loading;

  @override
  List<Object?> get props => [
        getNotificationsState, getNotificationsError, notifications,
        getUnreadCountState, unreadCount,
        markAsReadState, markAsReadError,
        markAllAsReadState, markAllAsReadError,
        deleteNotificationState, deleteNotificationError,
      ];
}
