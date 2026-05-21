import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shoplux/features/notifications/data/notification_repository.dart';
import '../states/notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(const NotificationState());

  Future<void> load() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    emit(const NotificationState(isLoading: true));
    try {
      final notifications =
          await NotificationRepository.fetchNotifications(userId);
      emit(NotificationState(notifications: notifications));
    } catch (e) {
      emit(NotificationState(error: e.toString()));
    }
  }

  Future<void> markAllRead() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await NotificationRepository.markAllRead(userId);
      emit(NotificationState(
        notifications:
            state.notifications.map((n) => n.copyWith(isRead: true)).toList(),
      ));
    } catch (_) {}
  }

  Future<void> markRead(String id) async {
    try {
      await NotificationRepository.markRead(id);
      emit(NotificationState(
        notifications: state.notifications
            .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
            .toList(),
      ));
    } catch (_) {}
  }
}
