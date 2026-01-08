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

  // Create order (MongoDB + Firebase)
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

  // Cancel order
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
        return OrderModel.fromJson(snapshot.data()!);
      }
      return null;
    });
  }

  // Listen to user's orders real-time from Firebase
  Stream<List<OrderModel>> listenToUserOrders() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromJson(doc.data()))
              .toList();
        });
  }
}
