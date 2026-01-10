import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_user/core/network/api_client.dart';
import 'package:cloud_user/features/orders/data/order_model.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'order_repository.g.dart';

@Riverpod(keepAlive: true)
OrderRepository orderRepository(OrderRepositoryRef ref) {
  return OrderRepository(ref.watch(apiClientProvider));
}

class OrderRepository {
  final Dio _dio;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  OrderRepository(this._dio);

  // Create order in Firebase ONLY (no MongoDB)
  Future<Map<String, dynamic>> createOrderFirebase(
    Map<String, dynamic> orderData,
  ) async {
    try {
      String uid;
      if (_auth.currentUser != null) {
        uid = _auth.currentUser!.uid;
      } else {
        // Fallback: If no Firebase user, check if we have a backend ID passed in the data
        // This handles cases where Firebase Auth failed/not synced but user is logged in via backend
        uid =
            orderData['userId'] ??
            orderData['_id'] ??
            'guest_${DateTime.now().millisecondsSinceEpoch}';
        print('⚠️ No Firebase User found. Using ID: $uid for order creation.');
      }

      // Generate order number and OTP
      final orderNumber = 'ORD${DateTime.now().millisecondsSinceEpoch}';
      final otp = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000))
          .toString();

      // Add to main orders collection first to get the document ID
      final docRef = await _firestore.collection('orders').add({
        ...orderData,
        'orderNumber': orderNumber,
        'otp': otp,
        'userId': uid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Now create the complete order document with the ID
      final orderDoc = {
        ...orderData,
        '_id': docRef.id, // ✅ Include the document ID
        'orderNumber': orderNumber,
        'otp': otp,
        'userId': uid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update the main collection with the ID
      await docRef.update({'_id': docRef.id});

      // Add to user's orders subcollection with the ID included
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('orders')
          .doc(docRef.id)
          .set(orderDoc);

      print('✅ Order ${docRef.id} created successfully in Firebase');

      return {
        'success': true,
        'order': {
          '_id': docRef.id,
          'orderNumber': orderNumber,
          'otp': otp,
          ...orderDoc,
        },
      };
    } catch (e) {
      print('🔥 Firebase order creation error: $e');
      rethrow;
    }
  }

  // Create order (MongoDB + Firebase) - LEGACY
  Future<Map<String, dynamic>> createOrder(
    Map<String, dynamic> orderData,
  ) async {
    try {
      final response = await _dio.post('orders', data: orderData);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Get user orders from MongoDB
  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await _dio.get('orders');
      final data = response.data['orders'] as List;
      return data.map((e) => OrderModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get single order from MongoDB
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await _dio.get('orders/$orderId');
      return OrderModel.fromJson(response.data['order']);
    } catch (e) {
      rethrow;
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOTP(String orderId, String otp) async {
    try {
      final response = await _dio.post(
        'orders/verify-otp',
        data: {'orderId': orderId, 'otp': otp},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Update order status
  Future<OrderModel> updateOrderStatus(
    String orderId,
    String status, {
    String? cancellationReason,
  }) async {
    try {
      final response = await _dio.patch(
        'orders/$orderId/status',
        data: {
          'status': status,
          if (cancellationReason != null)
            'cancellationReason': cancellationReason,
        },
      );
      return OrderModel.fromJson(response.data['order']);
    } catch (e) {
      rethrow;
    }
  }

  // Cancel order in Firebase ONLY
  Future<void> cancelOrderFirebase(
    String orderId,
    String reason, {
    String? userId,
  }) async {
    try {
      final uid = userId ?? _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      final updates = {
        'status': 'cancelled',
        'cancellationReason': reason,
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update in main orders collection
      await _firestore.collection('orders').doc(orderId).update(updates);

      // Update in user's orders subcollection
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('orders')
          .doc(orderId)
          .update(updates);

      print('✅ Order $orderId cancelled successfully in Firebase');
    } catch (e) {
      print('❌ Firebase cancel order error: $e');
      rethrow;
    }
  }

  // Cancel order (MongoDB) - LEGACY
  Future<OrderModel> cancelOrder(String orderId, String reason) async {
    try {
      final response = await _dio.post(
        'orders/$orderId/cancel',
        data: {'cancellationReason': reason},
      );
      return OrderModel.fromJson(response.data['order']);
    } catch (e) {
      rethrow;
    }
  }

  // Get booked slots for a date
  Future<List<Map<String, dynamic>>> getBookedSlots(DateTime date) async {
    try {
      final response = await _dio.get(
        'orders/slots',
        queryParameters: {'date': date.toIso8601String()},
      );
      return List<Map<String, dynamic>>.from(response.data['slots']);
    } catch (e) {
      // Just return empty if error, but logging would be good
      return [];
    }
  }

  // Listen to real-time order updates from Firebase
  Stream<OrderModel?> listenToOrder(String orderId) {
    return _firestore.collection('orders').doc(orderId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        if (!data.containsKey('_id')) {
          data['_id'] = snapshot.id;
        }
        return OrderModel.fromJson(data);
      }
      return null;
    });
  }

  // Listen to user's orders real-time from Firebase
  Stream<List<OrderModel>> listenToUserOrders({String? userId}) {
    final uid = userId ?? _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('orders')
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs.map((doc) {
            final data = doc.data();
            // Ensure ID is present for cancellation/updates
            if (!data.containsKey('_id')) {
              data['_id'] = doc.id;
            }
            return OrderModel.fromJson(data);
          }).toList();

          // Sort in memory instead of Firestore to avoid index requirement
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }
}
