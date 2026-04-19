import '../../../core/services/supabase_service.dart';

abstract class BaseNotificationDataSource {
  Future<List<Map<String, dynamic>>> getNotifications();
  Future<int> getUnreadCount();
  Future<void> markAsRead({required String notificationId});
  Future<void> markAllAsRead();
  Future<void> deleteNotification({required String notificationId});
}

class NotificationDataSource implements BaseNotificationDataSource {
  final SupabaseService supabaseService;

  const NotificationDataSource({required this.supabaseService});

  @override
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final userId = SupabaseService.client.auth.currentUser!.id;

    final response = await SupabaseService.client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<int> getUnreadCount() async {
    final userId = SupabaseService.client.auth.currentUser!.id;

    final response = await SupabaseService.client
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);

    return (response as List).length;
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
