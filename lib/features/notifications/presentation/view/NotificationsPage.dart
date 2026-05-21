import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shoplux/constants/AppColors.dart';
import 'package:shoplux/core/app_color_scheme.dart';
import 'package:shoplux/features/notifications/domain/models/notification_model.dart';
import 'package:shoplux/features/notifications/presentation/states/notification_state.dart';
import 'package:shoplux/features/notifications/presentation/viewmodels/notification_cubit.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: colors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              'Notifications',
              style: TextStyle(
                color: colors.text,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              if (state.unreadCount > 0)
                TextButton(
                  onPressed: () =>
                      context.read<NotificationCubit>().markAllRead(),
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          body: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : state.error != null
                  ? _ErrorState(
                      onRetry: () =>
                          context.read<NotificationCubit>().load())
                  : state.notifications.isEmpty
                      ? const _EmptyState()
                      : RefreshIndicator(
                          color: AppColors.primary,
                          backgroundColor: colors.fieldBackground,
                          onRefresh: () =>
                              context.read<NotificationCubit>().load(),
                          child: ListView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(20, 8, 20, 24),
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            itemCount: state.notifications.length,
                            itemBuilder: (context, index) {
                              final n = state.notifications[index];
                              return _NotificationCard(
                                notification: n,
                                onTap: () {
                                  if (!n.isRead) {
                                    context
                                        .read<NotificationCubit>()
                                        .markRead(n.id);
                                  }
                                },
                              );
                            },
                          ),
                        ),
        );
      },
    );
  }
}

// ─── Notification card ────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isUnread = !notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colors.fieldBackground,
          borderRadius: BorderRadius.circular(16),
          border: isUnread
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4), width: 1)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _iconBg(notification.type),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _icon(notification.type),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              color: colors.text,
                              fontSize: 14,
                              fontWeight: isUnread
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: colors.grey,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(notification.createdAt),
                      style: TextStyle(
                        color: colors.grey.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _icon(String type) => switch (type) {
        'order_placed' => '🛍️',
        'order_shipped' => '🚚',
        'order_delivered' => '✅',
        'order_status' => '📦',
        _ => '🔔',
      };

  Color _iconBg(String type) => switch (type) {
        'order_placed' => const Color(0xFF3A1800),
        'order_shipped' => const Color(0xFF0D2B1A),
        'order_delivered' => const Color(0xFF0D2B1A),
        'order_status' => const Color(0xFF0A1C35),
        _ => const Color(0xFF1E1500),
      };

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d, yyyy').format(dt);
  }
}

// ─── Empty / error states ─────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔔', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              color: colors.text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Order updates will appear here.',
            style: TextStyle(color: colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('😕', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'Could not load notifications',
            style: TextStyle(
              color: colors.text,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
