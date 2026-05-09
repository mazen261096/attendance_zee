import '../../../core/services/supabase_service.dart';

abstract class BaseNotificationDataSource {
  Future<List<Map<String, dynamic>>> getNotifications({
    required int offset,
    required int limit,
  });
  Future<int> getUnreadCount();
  Future<void> markAsRead({required String notificationId});
  Future<void> markAllAsRead();
  Future<void> deleteNotification({required String notificationId});
}

class NotificationDataSource implements BaseNotificationDataSource {
  final SupabaseService supabaseService;

  /// Page size for pagination
  static const int pageSize = 20;

  const NotificationDataSource({required this.supabaseService});

  @override
  Future<List<Map<String, dynamic>>> getNotifications({
    required int offset,
    required int limit,
  }) async {
    final userId = SupabaseService.client.auth.currentUser!.id;

    final response = await SupabaseService.client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<int> getUnreadCount() async {
    final userId = SupabaseService.client.auth.currentUser!.id;

    // Use .count() to get just the number — no data transfer overhead
    final response = await SupabaseService.client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .eq('is_read', false)
        .count();

    return response.count;
  }

  @override
  Future<void> markAsRead({required String notificationId}) async {
    await SupabaseService.client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  @override
  Future<void> markAllAsRead() async {
    final userId = SupabaseService.client.auth.currentUser!.id;

    await SupabaseService.client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  @override
  Future<void> deleteNotification({required String notificationId}) async {
    await SupabaseService.client
        .from('notifications')
        .delete()
        .eq('id', notificationId);
  }
}
