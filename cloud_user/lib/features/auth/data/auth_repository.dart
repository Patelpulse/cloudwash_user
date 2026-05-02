// import 'package:cloud_user/core/network/api_client.dart';

// import 'package:cloud_user/core/storage/token_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dio/dio.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:flutter/foundation.dart'
//     show kIsWeb, defaultTargetPlatform, TargetPlatform;

// part 'auth_repository.g.dart';

// @Riverpod(keepAlive: true)
// AuthRepository authRepository(AuthRepositoryRef ref) {
//   return AuthRepository(
//     ref.watch(apiClientProvider),
//     ref.watch(tokenStorageProvider),
//   );
// }

// class AuthRepository {
//   final Dio _dio;
//   final TokenStorage _tokenStorage;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn(
//     clientId: kIsWeb
//         ? '864806051234-ioslqq625a88mpejsj1chsn0bm4cunrf.apps.googleusercontent.com'
//         : (defaultTargetPlatform == TargetPlatform.iOS
//               ? '864806051234-56q2qa18u2eg3gii8r9b3qi78bkhsr2r.apps.googleusercontent.com'
//               : null),
//     serverClientId: kIsWeb
//         ? null
//         : '864806051234-ioslqq625a88mpejsj1chsn0bm4cunrf.apps.googleusercontent.com',
//   );

//   AuthRepository(this._dio, this._tokenStorage);

//   Future<SocialSignInResult?> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) return null;

//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       final userCredential = await _auth.signInWithCredential(credential);

//       // Get backend JWT token using Firebase UID
//       if (userCredential.user != null) {
//         final user = userCredential.user!;
//         try {
//           final response = await _dio.post(
//             'user/login',
//             data: {'firebaseUid': user.uid},
//           );

//           if (response.data['token'] != null) {
//             await _tokenStorage.saveToken(response.data['token']);

//             // Sync MongoDB ID to Firestore
//             await _firestore.collection('users').doc(user.uid).set({
//               '_id': response.data['_id'],
//               'name': response.data['name'] ?? user.displayName ?? '',
//               'email': response.data['email'] ?? user.email ?? '',
//               'phone': response.data['phone'] ?? '',
//               'profileImage':
//                   response.data['profileImage'] ?? user.photoURL ?? '',
//             }, SetOptions(merge: true));

//             print(
//               '✅ Google Sign-In: Token and Profile synced for ${user.email}',
//             );
//             return SocialSignInResult(
//               userCredential: userCredential,
//               isAlreadyRegistered: true,
//             );
//           }
//         } catch (e) {
//           print(
//             '⚠️ Google Sign-In:  User not found in backend, auto-registering...',
//           );

//           try {
//             // Auto-register the new Google user
//             final regResponse = await _dio.post(
//               'user/register',
//               data: {
//                 'firebaseUid': user.uid,
//                 'name': user.displayName ?? 'Google User',
//                 'email': user.email ?? '',
//                 'phone': '', // Social login might not provide phone
//                 'password': user.uid, // Use UID as placeholder password
//                 'role': 'user',
//                 'profileImage': user.photoURL ?? '',
//               },
//             );

//             if (regResponse.data['token'] != null) {
//               await _tokenStorage.saveToken(regResponse.data['token']);

//               // Sync back to Firestore
//               await _firestore.collection('users').doc(user.uid).set({
//                 '_id': regResponse.data['_id'],
//                 'name': user.displayName ?? '',
//                 'email': user.email ?? '',
//                 'profileImage': user.photoURL ?? '',
//                 'updatedAt': FieldValue.serverTimestamp(),
//               }, SetOptions(merge: true));

//               print(
//                 '✅ Google Sign-In: Auto-registered and synced for ${user.email}',
//               );
//               return SocialSignInResult(
//                 userCredential: userCredential,
//                 isAlreadyRegistered: true,
//               );
//             }
//           } catch (regError) {
//             print('❌ Google Sign-In: Auto-registration failed: $regError');
//             // If registration fails (e.g. phone required), fall back to manual registration
//             return SocialSignInResult(
//               userCredential: userCredential,
//               isAlreadyRegistered: false,
//             );
//           }
//         }
//       }

//       return SocialSignInResult(
//         userCredential: userCredential,
//         isAlreadyRegistered: true,
//       );
//     } catch (e) {
//       print('❌ Google Sign-In Error: $e');
//       rethrow;
//     }
//   }

//   Future<SocialSignInResult?> signInWithApple() async {
//     try {
//       final appleCredential = await SignInWithApple.getAppleIDCredential(
//         scopes: [
//           AppleIDAuthorizationScopes.email,
//           AppleIDAuthorizationScopes.fullName,
//         ],
//       );

//       final AuthCredential credential = OAuthProvider('apple.com').credential(
//         idToken: appleCredential.identityToken,
//         rawNonce: appleCredential
//             .state, // Nonce is handled by the plugin if using state, but Firebase needs rawNonce if provided. Usually just identityToken is enough for modern Firebase.
//       );

//       final userCredential = await _auth.signInWithCredential(credential);

//       // Get backend JWT token using Firebase UID
//       if (userCredential.user != null) {
//         final user = userCredential.user!;
//         try {
//           final response = await _dio.post(
//             'user/login',
//             data: {'firebaseUid': user.uid},
//           );

//           if (response.data['token'] != null) {
//             await _tokenStorage.saveToken(response.data['token']);

//             // Sync MongoDB ID to Firestore
//             await _firestore.collection('users').doc(user.uid).set({
//               '_id': response.data['_id'],
//               'name': response.data['name'] ?? user.displayName ?? '',
//               'email': response.data['email'] ?? user.email ?? '',
//               'phone': response.data['phone'] ?? '',
//               'profileImage':
//                   response.data['profileImage'] ?? user.photoURL ?? '',
//             }, SetOptions(merge: true));

//             print(
//               '✅ Apple Sign-In: Token and Profile synced for ${user.email}',
//             );
//             return SocialSignInResult(
//               userCredential: userCredential,
//               isAlreadyRegistered: true,
//             );
//           }
//         } catch (e) {
//           print(
//             '⚠️ Apple Sign-In: User not found in backend, auto-registering...',
//           );

//           try {
//             // Auto-register the new Apple user
//             final regResponse = await _dio.post(
//               'user/register',
//               data: {
//                 'firebaseUid': user.uid,
//                 'name': user.displayName ?? 'Apple User',
//                 'email': user.email ?? '',
//                 'phone': '',
//                 'password': user.uid,
//                 'role': 'user',
//                 'profileImage': user.photoURL ?? '',
//               },
//             );

//             if (regResponse.data['token'] != null) {
//               await _tokenStorage.saveToken(regResponse.data['token']);

//               await _firestore.collection('users').doc(user.uid).set({
//                 '_id': regResponse.data['_id'],
//                 'name': user.displayName ?? '',
//                 'email': user.email ?? '',
//                 'profileImage': user.photoURL ?? '',
//                 'updatedAt': FieldValue.serverTimestamp(),
//               }, SetOptions(merge: true));

//               print(
//                 '✅ Apple Sign-In: Auto-registered and synced for ${user.email}',
//               );
//               return SocialSignInResult(
//                 userCredential: userCredential,
//                 isAlreadyRegistered: true,
//               );
//             }
//           } catch (regError) {
//             print('❌ Apple Sign-In: Auto-registration failed: $regError');
//             return SocialSignInResult(
//               userCredential: userCredential,
//               isAlreadyRegistered: false,
//             );
//           }
//         }
//       }

//       return SocialSignInResult(
//         userCredential: userCredential,
//         isAlreadyRegistered: true,
//       );
//     } catch (e) {
//       print('❌ Apple Sign-In Error: $e');
//       rethrow;
//     }
//   }

//   Future<void> completeRegistration({
//     required String uid,
//     required String name,
//     required String email,
//     required String phone,
//     required String password,
//     String? profileImage,
//   }) async {
//     try {
//       // 1. Update Firebase Firestore (Real-time)
//       await _firestore.collection('users').doc(uid).set({
//         'name': name,
//         'email': email,
//         'phone': phone,
//         'profileImage': profileImage,
//         'updatedAt': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));

//       // 2. IMPORTANT: Update Firebase Auth Password
//       final user = _auth.currentUser;
//       if (user != null) {
//         try {
//           await user.updatePassword(password);
//           print('✅ Firebase Auth: Password updated/set for $email');
//         } catch (authError) {
//           print('⚠️ Firebase Auth: Password update failed: $authError');
//         }
//       }

//       final data = {
//         'firebaseUid': uid,
//         'name': name,
//         'email': email,
//         'phone': phone,
//         'password': password,
//         'role': 'user',
//       };
//       if (profileImage != null) {
//         data['profileImage'] = profileImage;
//       }

//       print('🚀 Registering with payload: $data');

//       // 3. Update MongoDB (Backend)
//       final response = await _dio.post('user/register', data: data);

//       if (response.data['token'] != null) {
//         await _tokenStorage.saveToken(response.data['token']);
//       }

//       // 4. Save returning data back to Firebase
//       final mongoId = response.data['_id'];
//       final cloudinaryUrl = response.data['profileImage'];

//       await _firestore.collection('users').doc(uid).set({
//         '_id': mongoId,
//         if (cloudinaryUrl != null) 'profileImage': cloudinaryUrl,
//         'updatedAt': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> loginOrRegister(String phone) async {
//     return;
//   }

//   Future<Map<String, dynamic>> login({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       // 1. Sign in to Firebase Auth
//       final userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       print('✅ Firebase Auth sign-in successful');

//       // 2. Sign in to Backend
//       final response = await _dio.post(
//         'user/login',
//         data: {'email': email, 'password': password},
//       );

//       print('🔑 Login Response: ${response.data}');

//       if (response.data['token'] != null) {
//         await _tokenStorage.saveToken(response.data['token']);

//         // 4. Sync MongoDB ID and info to Firestore
//         final firebaseUser = _auth.currentUser;
//         if (firebaseUser != null) {
//           await _firestore.collection('users').doc(firebaseUser.uid).set({
//             '_id': response.data['_id'],
//             'name': response.data['name'],
//             'email': response.data['email'],
//             'phone': response.data['phone'],
//             'profileImage': response.data['profileImage'],
//             'updatedAt': FieldValue.serverTimestamp(),
//           }, SetOptions(merge: true));
//         }
//       }
//       return response.data;

//       // Return simulated success response
//       // return {
//       //   'success': true,
//       //   'email': userCredential.user?.email,
//       //   'uid': userCredential.user?.uid,
//       // };
//     } catch (e) {
//       print('❌ Login Error: $e');
//       rethrow;
//     }
//   }

//   Future<void> verifyOtp(String phone, String otp) async {
//     try {
//       /*
//       final response = await _dio.post('user/login', data: {'phone': phone});

//       if (response.data['token'] != null) {
//         await _tokenStorage.saveToken(response.data['token']);
//       }

//       // Sync Cloudinary profile image to Firebase after login
//       final profileImage = response.data['profileImage'];
//       final name = response.data['name'];
//       final firebaseUser = _auth.currentUser;
//       if (firebaseUser != null && profileImage != null) {
//         await _firestore.collection('users').doc(firebaseUser.uid).set({
//           'name': name,
//           'profileImage': profileImage,
//           'phone': phone,
//         }, SetOptions(merge: true));
//       }

//       return response.data;
//       */
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<bool> isAuthenticated() async {
//     return _auth.currentUser != null;
//   }

//   Future<Map<String, dynamic>> getProfile() async {
//     try {
//       /*
//       final response = await _dio.get('user/profile');
//       return response.data;
//       */
//       final user = _auth.currentUser;
//       if (user == null) return {};
//       final doc = await _firestore.collection('users').doc(user.uid).get();
//       return doc.data() ?? {};
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<Map<String, dynamic>> updateProfile({
//     required String name,
//     required String phone,
//     String? profileImage,
//   }) async {
//     try {
//       /*
//       final response = await _dio.put(
//         'user/profile',
//         data: {
//           'name': name,
//           'phone': phone,
//           if (profileImage != null) 'profileImage': profileImage,
//         },
//       );
//       */

//       // Update Firebase directly
//       final firebaseUser = _auth.currentUser;
//       if (firebaseUser != null) {
//         final updates = {
//           'name': name,
//           'phone': phone,
//           if (profileImage != null) 'profileImage': profileImage,
//           'updatedAt': FieldValue.serverTimestamp(),
//         };
//         await _firestore
//             .collection('users')
//             .doc(firebaseUser.uid)
//             .set(updates, SetOptions(merge: true));
//         return updates;
//       }
//       return {};
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> logout() async {
//     await _tokenStorage.clearToken();
//     await _auth.signOut();
//     await _googleSignIn.signOut();
//   }
// }

// class SocialSignInResult {
//   final UserCredential? userCredential;
//   final bool isAlreadyRegistered;

//   SocialSignInResult({this.userCredential, this.isAlreadyRegistered = false});
// }



import 'package:cloud_user/core/network/api_client.dart';
import 'package:cloud_user/core/storage/token_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

import '../../../core/utils/apple_auth_helper.dart';

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

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '864806051234-ioslqq625a88mpejsj1chsn0bm4cunrf.apps.googleusercontent.com'
        : (defaultTargetPlatform == TargetPlatform.iOS
            ? '864806051234-56q2qa18u2eg3gii8r9b3qi78bkhsr2r.apps.googleusercontent.com'
            : null),
    serverClientId: kIsWeb
        ? null
        : '864806051234-ioslqq625a88mpejsj1chsn0bm4cunrf.apps.googleusercontent.com',
  );

  AuthRepository(this._dio, this._tokenStorage);

  /// 🔥 COMMON METHOD
  Future<bool> _checkUserExists(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }

  /// 🔥 GOOGLE SIGN-IN
  Future<SocialSignInResult?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('ℹ️ Google Sign-In: User cancelled sign-in');
        return null;
      }

      print('👤 Google User Data:');
      print('   - ID: ${googleUser.id}');
      print('   - Name: ${googleUser.displayName}');
      print('   - Email: ${googleUser.email}');
      print('   - Photo: ${googleUser.photoUrl}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final user = userCredential.user!;
        
        print('🔥 Firebase User Data:');
        print('   - UID: ${user.uid}');
        print('   - Email: ${user.email}');
        print('   - Display Name: ${user.displayName}');
        print('   - Photo URL: ${user.photoURL}');

        // 1. Try to Login with Backend
        try {
          final response = await _dio.post(
            'user/login',
            data: {'firebaseUid': user.uid},
          );

          if (response.data['token'] != null) {
            await _tokenStorage.saveToken(response.data['token']);

            // Sync MongoDB ID and info to Firestore
            await _firestore.collection('users').doc(user.uid).set({
              '_id': response.data['_id'],
              'name': response.data['name'] ?? user.displayName ?? '',
              'email': response.data['email'] ?? user.email ?? '',
              'phone': response.data['phone'] ?? '',
              'profileImage': response.data['profileImage'] ?? user.photoURL ?? '',
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

            print('✅ Google Sign-In: Backend login successful and synced');
            return SocialSignInResult(
              userCredential: userCredential,
              isAlreadyRegistered: true,
            );
          }
        } catch (e) {
          print('⚠️ Google Sign-In: User not found in backend or error: $e');
          // If 404 or other error, assume not registered
          final isAlreadyRegistered = await _checkUserExists(user.uid);
          return SocialSignInResult(
            userCredential: userCredential,
            isAlreadyRegistered: isAlreadyRegistered,
          );
        }
      }

      return null;
    } catch (e) {
      print('❌ Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// 🔥 APPLE SIGN-IN (Secure Nonce Implementation)
  Future<SocialSignInResult?> signInWithApple() async {
    try {
      // 🔐 Step 1: Generate Secure Nonce for Replay Attack Protection
      final rawNonce = AppleAuthHelper.generateNonce();
      final nonce = AppleAuthHelper.sha256ofString(rawNonce);

      // 🍏 Step 2: Request Apple ID Credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // 🔥 Step 3: Create Firebase OAuth Credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode, 
      );

      // 🔐 Step 4: Sign in to Firebase Auth
      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final user = userCredential.user;

      if (user != null) {
        // Step 5: Sync with Backend and Firestore
        try {
          final response = await _dio.post(
            'user/login',
            data: {'firebaseUid': user.uid},
          );

          if (response.data['token'] != null) {
            await _tokenStorage.saveToken(response.data['token']);

            // Sync user data to Firestore
            await _firestore.collection('users').doc(user.uid).set({
              '_id': response.data['_id'],
              'name': response.data['name'] ?? user.displayName ?? '',
              'email': response.data['email'] ?? user.email ?? '',
              'profileImage':
                  response.data['profileImage'] ?? user.photoURL ?? '',
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

            print('✅ Apple Sign-In: Backend login successful');
            return SocialSignInResult(
              userCredential: userCredential,
              isAlreadyRegistered: true,
            );
          }
        } catch (e) {
          print('⚠️ Apple Sign-In: User not found in backend or error: $e');
          final isAlreadyRegistered = await _checkUserExists(user.uid);
          return SocialSignInResult(
            userCredential: userCredential,
            isAlreadyRegistered: isAlreadyRegistered,
          );
        }
      }
      return null;
    } catch (e) {
      print('❌ Apple Sign-In Error: $e');
      rethrow;
    }
  }

  /// 🔥 COMPLETE REGISTRATION (WITH API VERSION)
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
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Update Firebase Auth Password
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(password);
      }

      // 3. Update MongoDB (Backend)
      final data = {
        'firebaseUid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': 'user',
        if (profileImage != null) 'profileImage': profileImage,
      };

      print('🚀 Registering with Backend: $data');
      final response = await _dio.post('user/register', data: data);

      if (response.data['token'] != null) {
        await _tokenStorage.saveToken(response.data['token']);
        
        // Sync MongoDB ID back to Firestore
        await _firestore.collection('users').doc(uid).set({
          '_id': response.data['_id'],
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      print('✅ User Registered Successfully in both Firebase and Backend');
    } catch (e) {
      print('❌ Registration Error: $e');
      rethrow;
    }
  }

  /// 🔥 EMAIL LOGIN WITH SELF-HEALING
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential? userCredential;
      bool firebaseSignInFailed = false;

      // 1. Try to sign in to Firebase Auth first
      try {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('✅ Firebase Auth sign-in successful');
      } on FirebaseAuthException catch (e) {
        print('⚠️ Firebase Auth sign-in failed: ${e.code}');
        firebaseSignInFailed = true;
        // We continue because we want to check if the user exists in MongoDB
      } catch (e) {
        print('⚠️ Unexpected Firebase error: $e');
        firebaseSignInFailed = true;
      }

      // 2. Sign in to Backend (MongoDB)
      // This verifies if the user exists and the password is correct in the main database
      final response = await _dio.post(
        'user/login',
        data: {'email': email, 'password': password},
      );

      if (response.data['token'] != null) {
        await _tokenStorage.saveToken(response.data['token']);

        // 3. SELF-HEALING: If Firebase failed but Backend succeeded
        if (firebaseSignInFailed || userCredential == null) {
          print('🔄 Attempting self-healing: Creating missing Firebase user...');
          try {
            // Try to create the user in Firebase with the same credentials
            userCredential = await _auth.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );
            print('✅ Self-healing successful: Firebase user created');
          } on FirebaseAuthException catch (e) {
            if (e.code == 'email-already-in-use') {
              // This means the user exists but the password might be different 
              // or there's a sync issue. Try to sign in again just in case.
              try {
                userCredential = await _auth.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );
              } catch (retryError) {
                print('❌ Self-healing failed: User exists in Firebase but password mismatch: $retryError');
                throw Exception('Invalid Firebase credentials for existing user');
              }
            } else {
              print('❌ Self-healing failed: ${e.message}');
              // If we can't create the user, we still have the backend token, 
              // but Firebase features (like Firestore) won't work perfectly.
            }
          }
        }

        // 4. Sync MongoDB data to Firestore
        final firebaseUser = userCredential?.user;
        if (firebaseUser != null) {
          await _firestore.collection('users').doc(firebaseUser.uid).set({
            '_id': response.data['_id'],
            'name': response.data['name'],
            'email': response.data['email'],
            'phone': response.data['phone'],
            'profileImage': response.data['profileImage'],
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }

      return response.data;
    } catch (e) {
      print('❌ Login Error: $e');
      rethrow;
    }
  }

  Future<bool> isAuthenticated() async {
    return _auth.currentUser != null;
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      // 1. Try Firestore first (Real-time source)
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()?['_id'] != null) {
        return doc.data()!;
      }

      // 2. Fallback to Backend API if Firestore is empty or missing MongoDB ID
      print('🔄 Firestore profile missing, fetching from backend...');
      final response = await _dio.get('user/profile');
      final profileData = Map<String, dynamic>.from(response.data);

      // 3. Sync to Firestore for next time
      await _firestore.collection('users').doc(user.uid).set({
        ...profileData,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return profileData;
    } catch (e) {
      print('❌ Get Profile Error: $e');
      // If API fails, return whatever we have in Firestore or empty
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        return doc.data() ?? {};
      }
      return {};
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phone,
    String? profileImage,
  }) async {
    try {
      // 1. Update Backend
      final response = await _dio.put(
        'user/profile',
        data: {
          'name': name,
          'phone': phone,
          if (profileImage != null) 'profileImage': profileImage,
        },
      );

      // 2. Sync to Firestore
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        final updates = {
          'name': name,
          'phone': phone,
          if (profileImage != null) 'profileImage': profileImage,
          'updatedAt': FieldValue.serverTimestamp(),
          if (response.data['_id'] != null) '_id': response.data['_id'],
        };
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(updates, SetOptions(merge: true));
        return updates;
      }
      return response.data;
    } catch (e) {
      print('❌ Update Profile Error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clearToken();
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}

class SocialSignInResult {
  final UserCredential? userCredential;
  final bool isAlreadyRegistered;

  SocialSignInResult({
    this.userCredential,
    this.isAlreadyRegistered = false,
  });
}