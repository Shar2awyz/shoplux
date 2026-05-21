import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/notification_model.dart';

class NotificationRepository {
  static final _db = Supabase.instance.client;

  static Future<List<NotificationModel>> fetchNotifications(
      String userId) async {
    final data = await _db
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List<dynamic>)
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> markAllRead(String userId) async {
    await _db
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  static Future<void> markRead(String id) async {
    await _db.from('notifications').update({'is_read': true}).eq('id', id);
  }

  static Future<void> insert({
    required String userId,
    String? orderId,
    required String title,
    required String body,
    String type = 'order_placed',
  }) async {
    await _db.from('notifications').insert({
      'user_id': userId,
      'order_id': orderId,
      'title': title,
      'body': body,
      'type': type,
    });
  }
}
