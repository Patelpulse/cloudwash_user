import 'package:cloud_user/core/storage/token_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_state_provider.g.dart';

@riverpod
Stream<bool> authState(AuthStateRef ref) async* {
  // Listen to Firebase Auth changes
  final firebaseStream = FirebaseAuth.instance.authStateChanges();

  await for (final user in firebaseStream) {
    if (user != null) {
      yield true;
    } else {
      // If Firebase says null, check if we have a legacy token
      final token = await ref.read(tokenStorageProvider).getToken();
      yield token != null;
    }
  }
}
