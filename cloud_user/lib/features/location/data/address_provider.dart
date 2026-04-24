import 'package:cloud_user/features/location/data/address_model.dart';
import 'package:cloud_user/features/location/data/address_repository.dart';
import 'package:cloud_user/features/orders/data/order_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'address_provider.g.dart';

@riverpod
class UserAddresses extends _$UserAddresses {
  Future<List<AddressModel>> build() async {
    return ref.watch(addressRepositoryProvider).getAddresses();
  }

  Future<void> addAddress(Map<String, dynamic> addressData) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(addressRepositoryProvider).addAddress(addressData);
      return ref.read(addressRepositoryProvider).getAddresses();
    });
  }

  Future<void> updateAddress(
    String id,
    Map<String, dynamic> addressData,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(addressRepositoryProvider).updateAddress(id, addressData);
      return ref.read(addressRepositoryProvider).getAddresses();
    });
  }

  Future<void> deleteAddress(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(addressRepositoryProvider).deleteAddress(id);
      return ref.read(addressRepositoryProvider).getAddresses();
    });
  }

  Future<void> setDefaultAddress(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(addressRepositoryProvider).setDefaultAddress(id);
      return ref.read(addressRepositoryProvider).getAddresses();
    });
  }
}

// Simple state provider for selected address (manual selection only)
@Riverpod(keepAlive: true)
class SelectedAddress extends _$SelectedAddress {
  @override
  AddressModel? build() {
    // Don't auto-watch addresses - only manually selected or default
    return null;
  }

  void select(AddressModel address) {
    print('🔵 Selecting address: ${address.label} - ${address.fullAddress}');
    state = address;
    print('🔵 Address state updated. Current state: ${state?.label}');
  }

  void clear() {
    print('🔴 Clearing selected address');
    state = null;
  }

  // Initialize with last order address or default address if available
  Future<void> initializeDefault() async {
    final addressesAsync = await ref.read(userAddressesProvider.future);
    if (addressesAsync.isEmpty) {
      state = null;
      return;
    }

    try {
      // 1. Try to find last used address from orders
      final ordersAsync = await ref.read(userOrdersRealtimeProvider.future);
      if (ordersAsync.isNotEmpty) {
        final lastAddress = ordersAsync.first.address;
        // Try to match by full address string
        final matched = addressesAsync.firstWhere(
          (a) =>
              a.fullAddress.trim().toLowerCase() ==
              lastAddress.fullAddress?.trim().toLowerCase(),
        );
        print('✅ Auto-selected last used address: ${matched.label}');
        state = matched;
        return;
      }
    } catch (e) {
      print('⚠️ Failed to match last order address: $e');
    }

    // 2. Fallback to default address
    try {
      state = addressesAsync.firstWhere((a) => a.isDefault);
    } catch (_) {
      // 3. Last fallback: first address
      state = addressesAsync.first;
    }
  }
}
