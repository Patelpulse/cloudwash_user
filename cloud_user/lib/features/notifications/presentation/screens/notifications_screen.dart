import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final n = notifications[index];
              final isRead = n['isRead'] == true;

              return ListTile(
                tileColor: isRead
                    ? Colors.transparent
                    : Colors.blue.withOpacity(0.05),
                leading: CircleAvatar(
                  backgroundColor: isRead
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  child: Icon(
                    _getIcon(n['type']),
                    color: isRead ? Colors.grey : Colors.blue,
                    size: 20,
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        n['title'] ?? 'Notification',
                        style: TextStyle(
                          fontWeight: isRead
                              ? FontWeight.normal
                              : FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (n['source'] == 'firebase')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'FIREBASE',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      n['message'] ?? '',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (n['createdAt'] != null)
                          Text(
                            DateFormat(
                              'MMM dd, hh:mm a',
                            ).format(DateTime.parse(n['createdAt'])),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        if (!isRead)
                          const Icon(Icons.circle, color: Colors.blue, size: 8),
                      ],
                    ),
                  ],
                ),
                onTap: () {
                  if (!isRead) {
                    ref
                        .read(notificationsProvider.notifier)
                        .markRead(n['_id'], source: n['source']);
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'order_created':
        return Icons.receipt_long;
      case 'order_status':
      case 'order_update':
        return Icons.local_shipping;
      default:
        return Icons.notifications;
    }
  }
}
