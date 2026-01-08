// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userAddressesHash() => r'c3cca9290569a5fed2df9f2e5bd3f99fba216e75';

/// See also [UserAddresses].
@ProviderFor(UserAddresses)
final userAddressesProvider =
    AutoDisposeAsyncNotifierProvider<
      UserAddresses,
      List<AddressModel>
    >.internal(
      UserAddresses.new,
      name: r'userAddressesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userAddressesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UserAddresses = AutoDisposeAsyncNotifier<List<AddressModel>>;
String _$selectedAddressHash() => r'00aceeb3f1170e9a0d26a223c5ed12a717cf5d8b';

/// See also [SelectedAddress].
@ProviderFor(SelectedAddress)
final selectedAddressProvider =
    NotifierProvider<SelectedAddress, AddressModel?>.internal(
      SelectedAddress.new,
      name: r'selectedAddressProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedAddressHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedAddress = Notifier<AddressModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
