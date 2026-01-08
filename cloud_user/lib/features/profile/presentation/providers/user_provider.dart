import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_user/features/auth/data/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';

part 'user_provider.g.dart';

@riverpod
class UserProfile extends _$UserProfile {
  StreamSubscription? _subscription;

  @override
  FutureOr<Map<String, dynamic>?> build() async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user == null) {
      _subscription?.cancel();
      return null;
    }

    // Cancel existing subscription if any
    _subscription?.cancel();

    // Listen for real-time updates from Firestore
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) async {
          if (snapshot.exists) {
            final data = snapshot.data();
            if (data != null) {
              // Self-healing: If MongoDB ID is missing in Firestore, fetch from API and sync
              if (data['_id'] == null) {
                try {
                  final repo = ref.read(authRepositoryProvider);
                  final profile = await repo.getProfile();
                  if (profile['_id'] != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update({'_id': profile['_id']});
                    print('🔄 Self-healed missing MongoDB ID in Firestore');
                    return; // The next snapshot will have the ID
                  }
                } catch (e) {
                  print('⚠️ Failed to self-heal MongoDB ID: $e');
                }
              }

              // Sync timestamps for year parsing
              if (data['createdAt'] is Timestamp) {
                data['createdAt'] = (data['createdAt'] as Timestamp)
                    .toDate()
                    .toIso8601String();
              }
              state = AsyncValue.data(data);
            }
          }
        });

    // Cleanup on dispose
    ref.onDispose(() {
      _subscription?.cancel();
    });

    // Return the current data as initial state
    final initialDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final initialData = initialDoc.data();
    if (initialData != null && initialData['createdAt'] is Timestamp) {
      initialData['createdAt'] = (initialData['createdAt'] as Timestamp)
          .toDate()
          .toIso8601String();
    }
    return initialData;
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    String? base64Image,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final updatedUser = await repo.updateProfile(
        name: name,
        phone: phone,
        profileImage: base64Image,
      );
      state = AsyncValue.data(updatedUser);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
