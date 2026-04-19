import 'package:dartz/dartz.dart';
import '../../../core/utils/failure.dart';
import '../../../core/utils/supabase_error_mapper.dart';
import 'notification_data_source.dart';
import 'models/notification_model.dart';

abstract class BaseNotificationRepository {
  Future<Either<Failure, List<NotificationModel>>> getNotifications();
  Future<Either<Failure, int>> getUnreadCount();
  Future<Either<Failure, void>> markAsRead({required String notificationId});
  Future<Either<Failure, void>> markAllAsRead();
  Future<Either<Failure, void>> deleteNotification({
    required String notificationId,
  });
}

class NotificationRepository implements BaseNotificationRepository {
  final BaseNotificationDataSource dataSource;

  NotificationRepository({required this.dataSource});

  @override
  Future<Either<Failure, List<NotificationModel>>> getNotifications() async {
    try {
      final result = await dataSource.getNotifications();
      final notifications =
          result.map((e) => NotificationModel.fromJson(e)).toList();
      return Right(notifications);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in getNotifications: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final count = await dataSource.getUnreadCount();
      return Right(count);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in getUnreadCount: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead({
    required String notificationId,
  }) async {
    try {
      await dataSource.markAsRead(notificationId: notificationId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in markAsRead: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await dataSource.markAllAsRead();
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in markAllAsRead: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification({
    required String notificationId,
  }) async {
    try {
      await dataSource.deleteNotification(notificationId: notificationId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stack) {
      print('Error in deleteNotification: $e');
      print(stack);
      return Left(SupabaseErrorMapper.mapException(e));
    }
  }
}
