import 'package:cloud_user/core/network/api_client.dart';
import 'package:cloud_user/features/location/data/address_model.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'address_repository.g.dart';

@Riverpod(keepAlive: true)
AddressRepository addressRepository(AddressRepositoryRef ref) {
  return AddressRepository(ref.watch(apiClientProvider));
}

class AddressRepository {
  final Dio _dio;

  AddressRepository(this._dio);

  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await _dio.get('addresses');
      final data = response.data as List;
      return data.map((e) => AddressModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<AddressModel> addAddress(Map<String, dynamic> addressData) async {
    try {
      final response = await _dio.post('addresses', data: addressData);
      return AddressModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<AddressModel> updateAddress(
    String id,
    Map<String, dynamic> addressData,
  ) async {
    try {
      final response = await _dio.put('addresses/$id', data: addressData);
      return AddressModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _dio.delete('addresses/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<AddressModel> setDefaultAddress(String id) async {
    try {
      final response = await _dio.patch('addresses/$id/default');
      return AddressModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
