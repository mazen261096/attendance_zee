import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/enums.dart';
import '../../../core/utils/either_extensions.dart';
import '../../../core/utils/core_utils.dart';
import '../data/notification_repository.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({required this.repository})
      : super(const NotificationState());

  final BaseNotificationRepository repository;

  Future<void> getNotifications() async {
    emit(state.copyWith(
      getNotificationsState: RequestState.loading,
      getNotificationsError: '',
    ));

    try {
      final result = await repository.getNotifications();

      result.fold(
        (failure) => emit(state.copyWith(
          getNotificationsState: RequestState.error,
          getNotificationsError: failure.message,
        )),
        (notifications) {
          final unread = notifications.where((n) => !n.isRead).length;
          emit(state.copyWith(
            getNotificationsState: RequestState.loaded,
            notifications: notifications,
            unreadCount: unread,
            getNotificationsError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in getNotifications: $error');
      print(stack);
      emit(state.copyWith(
        getNotificationsState: RequestState.error,
        getNotificationsError: error.toString(),
      ));
    }
  }

  Future<void> getUnreadCount() async {
    emit(state.copyWith(getUnreadCountState: RequestState.loading));

    try {
      final result = await repository.getUnreadCount();

      result.fold(
        (failure) => emit(state.copyWith(
          getUnreadCountState: RequestState.error,
        )),
        (count) => emit(state.copyWith(
          getUnreadCountState: RequestState.loaded,
          unreadCount: count,
        )),
      );
    } catch (error, stack) {
      print('Error in getUnreadCount: $error');
      print(stack);
      emit(state.copyWith(getUnreadCountState: RequestState.error));
    }
  }

  Future<void> markAsRead({required String notificationId}) async {
    emit(state.copyWith(
      markAsReadState: RequestState.loading,
      markAsReadError: '',
    ));

    try {
      final result =
          await repository.markAsRead(notificationId: notificationId);

      result.fold(
        (failure) => emit(state.copyWith(
          markAsReadState: RequestState.error,
          markAsReadError: failure.message,
        )),
        (_) {
          // Update the notification in the list optimistically
          final updatedList = state.notifications
              .map((n) =>
                  n.id == notificationId ? n.copyWith(isRead: true) : n)
              .toList();
          final unread = updatedList.where((n) => !n.isRead).length;
          emit(state.copyWith(
            markAsReadState: RequestState.loaded,
            notifications: updatedList,
            unreadCount: unread,
            markAsReadError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in markAsRead: $error');
      print(stack);
      emit(state.copyWith(
        markAsReadState: RequestState.error,
        markAsReadError: error.toString(),
      ));
    }
  }

  Future<void> markAllAsRead() async {
    emit(state.copyWith(
      markAllAsReadState: RequestState.loading,
      markAllAsReadError: '',
    ));

    try {
      final result = await repository.markAllAsRead();

      result.showSnackBarOnError().fold(
        (failure) => emit(state.copyWith(
          markAllAsReadState: RequestState.error,
          markAllAsReadError: failure.message,
        )),
        (_) {
          final updatedList = state.notifications
              .map((n) => n.copyWith(isRead: true))
              .toList();
          emit(state.copyWith(
            markAllAsReadState: RequestState.loaded,
            notifications: updatedList,
            unreadCount: 0,
            markAllAsReadError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in markAllAsRead: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        markAllAsReadState: RequestState.error,
        markAllAsReadError: error.toString(),
      ));
    }
  }

  Future<void> deleteNotification({required String notificationId}) async {
    emit(state.copyWith(
      deleteNotificationState: RequestState.loading,
      deleteNotificationError: '',
    ));

    try {
      final result =
          await repository.deleteNotification(notificationId: notificationId);

      result.showSnackBarOnError().fold(
        (failure) => emit(state.copyWith(
          deleteNotificationState: RequestState.error,
          deleteNotificationError: failure.message,
        )),
        (_) {
          final removedNotification = state.notifications.firstWhere(
            (n) => n.id == notificationId,
          );
          final updatedList = state.notifications
              .where((n) => n.id != notificationId)
              .toList();
          final unreadDiff = removedNotification.isRead ? 0 : 1;
          emit(state.copyWith(
            deleteNotificationState: RequestState.loaded,
            notifications: updatedList,
            unreadCount: state.unreadCount - unreadDiff,
            deleteNotificationError: '',
          ));
        },
      );
    } catch (error, stack) {
      print('Error in deleteNotification: $error');
      print(stack);
      CoreUtils.showErrorSnackBar(message: error.toString());
      emit(state.copyWith(
        deleteNotificationState: RequestState.error,
        deleteNotificationError: error.toString(),
      ));
    }
  }
}
