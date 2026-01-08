import 'package:cloud_user/core/network/api_client.dart';

import 'package:cloud_user/core/storage/token_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStorageProvider),
  );
}

class AuthRepository {
  final Dio _dio;
  final TokenStorage _tokenStorage;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthRepository(this._dio, this._tokenStorage);

  Future<GoogleSignInResult?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Get backend JWT token using Firebase UID
      if (userCredential.user != null) {
        try {
          final response = await _dio.post(
            'user/login',
            data: {'firebaseUid': userCredential.user!.uid},
          );

          if (response.data['token'] != null) {
            await _tokenStorage.saveToken(response.data['token']);

            // Sync MongoDB ID to Firestore
            await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .set({
                  '_id': response.data['_id'],
                  'name': response.data['name'],
                  'email': response.data['email'],
                  'phone': response.data['phone'],
                  'profileImage': response.data['profileImage'],
                }, SetOptions(merge: true));

            print(
              '✅ Google Sign-In: Token and Profile synced for ${userCredential.user!.email}',
            );
            return GoogleSignInResult(
              userCredential: userCredential,
              isAlreadyRegistered: true,
            );
          }
        } catch (e) {
          print(
            '⚠️ Google Sign-In: User not registered in backend. Please complete registration.',
          );
          // User exists in Firebase but not in MongoDB - they need to complete registration
          return GoogleSignInResult(
            userCredential: userCredential,
            isAlreadyRegistered: false,
          );
        }
      }

      return GoogleSignInResult(userCredential: userCredential);
    } catch (e) {
      print('❌ Google Sign-In Error: $e');
      rethrow;
    }
  }

  Future<void> completeRegistration({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String password,
    String? profileImage,
  }) async {
    try {
      // 1. Update Firebase Firestore (Real-time)
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'profileImage': profileImage,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Update MongoDB (Backend)
      final response = await _dio.post(
        'user/register',
        data: {
          'firebaseUid': uid,
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'profileImage': profileImage,
        },
      );

      if (response.data['token'] != null) {
        await _tokenStorage.saveToken(response.data['token']);
      }

      // 3. Save returning data back to Firebase
      final mongoId = response.data['_id'];
      final cloudinaryUrl = response.data['profileImage'];

      await _firestore.collection('users').doc(uid).set({
        '_id': mongoId,
        if (cloudinaryUrl != null) 'profileImage': cloudinaryUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loginOrRegister(String phone) async {
    return;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        'user/login',
        data: {'email': email, 'password': password},
      );

      print('🔑 Login Response: ${response.data}');

      if (response.data['token'] != null) {
        await _tokenStorage.saveToken(response.data['token']);

        // Sync MongoDB ID to Firestore
        final firebaseUser = _auth.currentUser;
        if (firebaseUser != null) {
          await _firestore.collection('users').doc(firebaseUser.uid).set({
            '_id': response.data['_id'],
            'name': response.data['name'],
            'email': response.data['email'],
            'phone': response.data['phone'],
            'profileImage': response.data['profileImage'],
          }, SetOptions(merge: true));
        }
      }

      return response.data;
    } catch (e) {
      print('❌ Login Error: $e');
      rethrow;
    }
  }

  Future<void> verifyOtp(String phone, String otp) async {
    try {
      final response = await _dio.post('user/login', data: {'phone': phone});

      if (response.data['token'] != null) {
        await _tokenStorage.saveToken(response.data['token']);
      }

      // Sync Cloudinary profile image to Firebase after login
      final profileImage = response.data['profileImage'];
      final name = response.data['name'];
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null && profileImage != null) {
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'name': name,
          'profileImage': profileImage,
          'phone': phone,
        }, SetOptions(merge: true));
      }

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await _tokenStorage.getToken();
    return token != null;
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('user/profile');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phone,
    String? profileImage,
  }) async {
    try {
      final response = await _dio.put(
        'user/profile',
        data: {
          'name': name,
          'phone': phone,
          if (profileImage != null) 'profileImage': profileImage,
        },
      );

      // Update Firebase if Cloudinary URL returned
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null && response.data['profileImage'] != null) {
        await _firestore.collection('users').doc(firebaseUser.uid).update({
          'name': name,
          'phone': phone,
          'profileImage': response.data['profileImage'],
        });
      }

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clearToken();
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}

class GoogleSignInResult {
  final UserCredential? userCredential;
  final bool isAlreadyRegistered;

  GoogleSignInResult({this.userCredential, this.isAlreadyRegistered = false});
}
