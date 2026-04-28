import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_user/features/orders/data/order_model.dart';
import 'package:cloud_user/features/orders/data/order_repository.dart';
import 'package:cloud_user/features/profile/presentation/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'order_provider.g.dart';

final bookedSlotsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, DateTime>((ref, date) {
      return ref.watch(orderRepositoryProvider).getBookedSlots(date);
    });

// User's orders from MongoDB
@riverpod
class UserOrders extends _$UserOrders {
  @override
  Future<List<OrderModel>> build() async {
    return ref.watch(orderRepositoryProvider).getOrders();
  }

  // Create new order
  Future<Map<String, dynamic>> createOrder(
    Map<String, dynamic> orderData,
  ) async {
    try {
      final result = await ref
          .read(orderRepositoryProvider)
          .createOrder(orderData);
      // Refresh orders list
      ref.invalidateSelf();
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOTP(String orderId, String otp) async {
    try {
      final result = await ref
          .read(orderRepositoryProvider)
          .verifyOTP(orderId, otp);
      // Refresh orders list
      ref.invalidateSelf();
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Cancel order (MongoDB + Firebase Sync)
  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      await ref.read(orderRepositoryProvider).cancelOrder(orderId, reason);
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }

  // Cancel order (Firebase ONLY)
  Future<void> cancelOrderFirebase(String orderId, String reason) async {
    try {
      await ref
          .read(orderRepositoryProvider)
          .cancelOrderFirebase(orderId, reason);
      // No need to invalidate since it's a stream
    } catch (e) {
      rethrow;
    }
  }
}

// Real-time order tracking from Firebase
@riverpod
class OrderTracking extends _$OrderTracking {
  @override
  Stream<OrderModel?> build(String orderId) {
    return ref.watch(orderRepositoryProvider).listenToOrder(orderId);
  }
}

// Real-time user orders from Firebase
@riverpod
class UserOrdersRealtime extends _$UserOrdersRealtime {
  @override
  Stream<List<OrderModel>> build() {
    // Watch user profile to get the correct ID (MongoDB ID or Firebase UID)
    final userAsync = ref.watch(userProfileProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) return Stream.value([]);
        // Priority 1: Firebase Auth UID (used for Firestore paths)
        // Priority 2: MongoDB ID (as a fallback)
        final userId = FirebaseAuth.instance.currentUser?.uid ?? user['_id'];

        if (userId == null) {
          print('🔍 UserOrdersRealtime: No User ID found');
          return Stream.value([]);
        }

        print('🔍 UserOrdersRealtime: Listening to orders for UID: $userId');

        return ref
            .watch(orderRepositoryProvider)
            .listenToUserOrders(userId: userId);
      },
      loading: () => Stream.value([]),
      error: (_, __) => Stream.value([]),
    );
  }

  // Cancel order (Firebase ONLY)
  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      await ref
          .read(orderRepositoryProvider)
          .cancelOrderFirebase(orderId, reason);
    } catch (e) {
      rethrow;
    }
  }
}

// Single order details
@riverpod
class OrderDetails extends _$OrderDetails {
  @override
  Future<OrderModel> build(String orderId) async {
    return ref.watch(orderRepositoryProvider).getOrderById(orderId);
  }

  Future<void> updateStatus(String status, {String? cancellationReason}) async {
    try {
      await ref
          .read(orderRepositoryProvider)
          .updateOrderStatus(
            orderId,
            status,
            cancellationReason: cancellationReason,
          );
      // Refresh order details
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }
}
