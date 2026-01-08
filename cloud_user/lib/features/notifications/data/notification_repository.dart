import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_user/core/network/api_client.dart';

final notificationRepositoryProvider = Provider((ref) {
  return NotificationRepository(ref.watch(apiClientProvider));
});

class NotificationRepository {
  final Dio _dio;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  NotificationRepository(this._dio);

  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await _dio.get('notifications');
      return (response.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Notification Fetch Error: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> listenToFirebaseNotifications() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return {...data, '_id': doc.id, 'source': 'firebase'};
          }).toList();
        });
  }

  Future<void> markAsRead(String id, {String? source}) async {
    try {
      if (source == 'firebase') {
        await _firestore.collection('notifications').doc(id).update({
          'isRead': true,
        });
      } else {
        await _dio.patch('notifications/$id/read');
      }
    } catch (e) {
      print('Mark Read Error: $e');
    }
  }
}
