import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_user/features/orders/data/order_model.dart';
import 'package:cloud_user/features/orders/data/order_repository.dart';
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

  // Cancel order
  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      await ref.read(orderRepositoryProvider).cancelOrder(orderId, reason);
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
    return ref.watch(orderRepositoryProvider).listenToUserOrders();
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
