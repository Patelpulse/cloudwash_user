// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userOrdersHash() => r'0247ed80698b7946dde926fe9febf7fe283dbefb';

/// See also [UserOrders].
@ProviderFor(UserOrders)
final userOrdersProvider =
    AutoDisposeAsyncNotifierProvider<UserOrders, List<OrderModel>>.internal(
      UserOrders.new,
      name: r'userOrdersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userOrdersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UserOrders = AutoDisposeAsyncNotifier<List<OrderModel>>;
String _$orderTrackingHash() => r'0c026aba47922b1877b1f63884ab7992f6feb2c1';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$OrderTracking
    extends BuildlessAutoDisposeStreamNotifier<OrderModel?> {
  late final String orderId;

  Stream<OrderModel?> build(String orderId);
}

/// See also [OrderTracking].
@ProviderFor(OrderTracking)
const orderTrackingProvider = OrderTrackingFamily();

/// See also [OrderTracking].
class OrderTrackingFamily extends Family<AsyncValue<OrderModel?>> {
  /// See also [OrderTracking].
  const OrderTrackingFamily();

  /// See also [OrderTracking].
  OrderTrackingProvider call(String orderId) {
    return OrderTrackingProvider(orderId);
  }

  @override
  OrderTrackingProvider getProviderOverride(
    covariant OrderTrackingProvider provider,
  ) {
    return call(provider.orderId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'orderTrackingProvider';
}

/// See also [OrderTracking].
class OrderTrackingProvider
    extends AutoDisposeStreamNotifierProviderImpl<OrderTracking, OrderModel?> {
  /// See also [OrderTracking].
  OrderTrackingProvider(String orderId)
    : this._internal(
        () => OrderTracking()..orderId = orderId,
        from: orderTrackingProvider,
        name: r'orderTrackingProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$orderTrackingHash,
        dependencies: OrderTrackingFamily._dependencies,
        allTransitiveDependencies:
            OrderTrackingFamily._allTransitiveDependencies,
        orderId: orderId,
      );

  OrderTrackingProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orderId,
  }) : super.internal();

  final String orderId;

  @override
  Stream<OrderModel?> runNotifierBuild(covariant OrderTracking notifier) {
    return notifier.build(orderId);
  }

  @override
  Override overrideWith(OrderTracking Function() create) {
    return ProviderOverride(
      origin: this,
      override: OrderTrackingProvider._internal(
        () => create()..orderId = orderId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orderId: orderId,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<OrderTracking, OrderModel?>
  createElement() {
    return _OrderTrackingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderTrackingProvider && other.orderId == orderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrderTrackingRef on AutoDisposeStreamNotifierProviderRef<OrderModel?> {
  /// The parameter `orderId` of this provider.
  String get orderId;
}

class _OrderTrackingProviderElement
    extends AutoDisposeStreamNotifierProviderElement<OrderTracking, OrderModel?>
    with OrderTrackingRef {
  _OrderTrackingProviderElement(super.provider);

  @override
  String get orderId => (origin as OrderTrackingProvider).orderId;
}

String _$userOrdersRealtimeHash() =>
    r'10f8c364c5ac87212b96e46c90bb2b3d7311183d';

/// See also [UserOrdersRealtime].
@ProviderFor(UserOrdersRealtime)
final userOrdersRealtimeProvider =
    AutoDisposeStreamNotifierProvider<
      UserOrdersRealtime,
      List<OrderModel>
    >.internal(
      UserOrdersRealtime.new,
      name: r'userOrdersRealtimeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userOrdersRealtimeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UserOrdersRealtime = AutoDisposeStreamNotifier<List<OrderModel>>;
String _$orderDetailsHash() => r'db0b6eea5692d4b6da02f2c0447af90738a43a3f';

abstract class _$OrderDetails
    extends BuildlessAutoDisposeAsyncNotifier<OrderModel> {
  late final String orderId;

  FutureOr<OrderModel> build(String orderId);
}

/// See also [OrderDetails].
@ProviderFor(OrderDetails)
const orderDetailsProvider = OrderDetailsFamily();

/// See also [OrderDetails].
class OrderDetailsFamily extends Family<AsyncValue<OrderModel>> {
  /// See also [OrderDetails].
  const OrderDetailsFamily();

  /// See also [OrderDetails].
  OrderDetailsProvider call(String orderId) {
    return OrderDetailsProvider(orderId);
  }

  @override
  OrderDetailsProvider getProviderOverride(
    covariant OrderDetailsProvider provider,
  ) {
    return call(provider.orderId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'orderDetailsProvider';
}

/// See also [OrderDetails].
class OrderDetailsProvider
    extends AutoDisposeAsyncNotifierProviderImpl<OrderDetails, OrderModel> {
  /// See also [OrderDetails].
  OrderDetailsProvider(String orderId)
    : this._internal(
        () => OrderDetails()..orderId = orderId,
        from: orderDetailsProvider,
        name: r'orderDetailsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$orderDetailsHash,
        dependencies: OrderDetailsFamily._dependencies,
        allTransitiveDependencies:
            OrderDetailsFamily._allTransitiveDependencies,
        orderId: orderId,
      );

  OrderDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orderId,
  }) : super.internal();

  final String orderId;

  @override
  FutureOr<OrderModel> runNotifierBuild(covariant OrderDetails notifier) {
    return notifier.build(orderId);
  }

  @override
  Override overrideWith(OrderDetails Function() create) {
    return ProviderOverride(
      origin: this,
      override: OrderDetailsProvider._internal(
        () => create()..orderId = orderId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orderId: orderId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<OrderDetails, OrderModel>
  createElement() {
    return _OrderDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderDetailsProvider && other.orderId == orderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrderDetailsRef on AutoDisposeAsyncNotifierProviderRef<OrderModel> {
  /// The parameter `orderId` of this provider.
  String get orderId;
}

class _OrderDetailsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<OrderDetails, OrderModel>
    with OrderDetailsRef {
  _OrderDetailsProviderElement(super.provider);

  @override
  String get orderId => (origin as OrderDetailsProvider).orderId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
