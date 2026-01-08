import 'package:cloud_user/core/services/notification_service.dart';
import 'package:cloud_user/core/services/socket_service.dart';
import 'package:cloud_user/features/notifications/data/notification_repository.dart';
import 'package:cloud_user/features/profile/presentation/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationsProvider =
    StateNotifierProvider<
      NotificationNotifier,
      AsyncValue<List<Map<String, dynamic>>>
    >((ref) {
      return NotificationNotifier(ref);
    });

class NotificationNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final Ref ref;
  final Set<String> _notifiedIds = {};

  NotificationNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final repo = ref.read(notificationRepositoryProvider);

      // Load initial API notifications
      final apiList = await repo.getNotifications();
      // Add existing unread IDs to _notifiedIds to avoid alerts for old notifications
      for (var n in apiList) {
        if (n['_id'] != null) _notifiedIds.add(n['_id']);
      }
      state = AsyncValue.data(apiList);

      // Listen to Firebase Notifications
      repo.listenToFirebaseNotifications().listen((fbList) {
        final currentList = state.value ?? [];
        final freshNotifications = <Map<String, dynamic>>[];

        for (var n in fbList) {
          final id = n['_id'];
          if (id != null && !_notifiedIds.contains(id)) {
            _notifiedIds.add(id);
            freshNotifications.add(n);

            // Only alert if isRead is false
            if (n['isRead'] == false) {
              ref
                  .read(notificationServiceProvider)
                  .showNotification(
                    title: n['title'] ?? 'New Notification',
                    body: n['message'] ?? '',
                  );
            }
          }
        }

        // Efficiently merge lists by ID to avoid duplicates
        final merged = [...fbList];
        for (var apiItem in currentList) {
          if (!merged.any((item) => item['_id'] == apiItem['_id'])) {
            merged.add(apiItem);
          }
        }
        // Sort by date (newest first)
        merged.sort((a, b) {
          final dateA = DateTime.parse(
            a['createdAt'] ?? DateTime.now().toIso8601String(),
          );
          final dateB = DateTime.parse(
            b['createdAt'] ?? DateTime.now().toIso8601String(),
          );
          return dateB.compareTo(dateA);
        });
        state = AsyncValue.data(merged);
      });

      // Socket Setup
      final socket = ref.read(socketServiceProvider);
      socket.init();

      // Listen for User to join room
      ref.listen(userProfileProvider, (previous, next) {
        next.whenData((user) {
          if (user != null && (user['_id'] != null || user['id'] != null)) {
            socket.joinRoom(user['_id'] ?? user['id']);
          }
        });
      });

      // Trigger initial check if already loaded
      ref.read(userProfileProvider).whenData((user) {
        if (user != null) {
          socket.joinRoom(user['_id'] ?? user['id']);
        }
      });

      socket.onNotification((data) {
        final currentList = state.value ?? [];
        final id = data['_id'];
        if (id != null && !currentList.any((n) => n['_id'] == id)) {
          state = AsyncValue.data([data, ...currentList]);

          // Show local notification for socket
          if (!_notifiedIds.contains(id)) {
            _notifiedIds.add(id);
            ref
                .read(notificationServiceProvider)
                .showNotification(
                  title: data['title'] ?? 'New Notification',
                  body: data['message'] ?? '',
                );
          }
        }
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markRead(String id, {String? source}) async {
    await ref
        .read(notificationRepositoryProvider)
        .markAsRead(id, source: source);
    if (source != 'firebase') {
      final currentList = state.value ?? [];
      final newList = currentList.map((n) {
        if (n['_id'] == id) {
          return {...n, 'isRead': true};
        }
        return n;
      }).toList();
      state = AsyncValue.data(newList);
    }
  }
}

final unreadNotificationsCountProvider = Provider.autoDispose<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.maybeWhen(
    data: (list) => list.where((n) => n['isRead'] == false).length,
    orElse: () => 0,
  );
});
