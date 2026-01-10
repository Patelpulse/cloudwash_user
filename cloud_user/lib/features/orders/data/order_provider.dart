import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_user/features/orders/data/order_model.dart';
import 'package:cloud_user/features/orders/data/order_repository.dart';
import 'package:cloud_user/features/profile/presentation/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'order_provider.g.dart';

// ... (keep existing classes)

// Booked slots for date
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

  // Cancel order (Firebase)
  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      // Retrieve the current user's ID from the profile provider
      final userAsync = ref.read(userProfileProvider);

      // We need to resolve the async value to get the data
      // For a simple synchronous read if already loaded:
      String? userId;
      if (userAsync is AsyncData<Map<String, dynamic>?>) {
        userId =
            userAsync.value?['_id'] ?? FirebaseAuth.instance.currentUser?.uid;
      } else {
        // Fallback if not loaded in state (less likely in this flow)
        userId = FirebaseAuth.instance.currentUser?.uid;
      }

      // Use Firebase-only cancellation with the specific User ID
      await ref
          .read(orderRepositoryProvider)
          .cancelOrderFirebase(orderId, reason, userId: userId);
      // Refresh orders list
      ref.invalidateSelf();
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
        // Prefer the MongoDB ID '_id' as that is what we used as fallback in createOrder
        // If not available, use the Firebase Auth UID if present
        final userId = user['_id'] ?? FirebaseAuth.instance.currentUser?.uid;

        if (userId == null) return Stream.value([]);

        return ref
            .watch(orderRepositoryProvider)
            .listenToUserOrders(userId: userId);
      },
      loading: () => Stream.value([]),
      error: (_, __) => Stream.value([]),
    );
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
