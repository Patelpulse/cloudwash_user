// import 'package:cloud_user/core/network/api_client.dart';
// import 'package:cloud_user/features/location/data/address_model.dart';
// import 'package:dio/dio.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';

// part 'address_repository.g.dart';

// @Riverpod(keepAlive: true)
// AddressRepository addressRepository(AddressRepositoryRef ref) {
//   return AddressRepository(ref.watch(apiClientProvider));
// }

// class AddressRepository {
//   final Dio _dio;

//   AddressRepository(this._dio);

//   Future<List<AddressModel>> getAddresses() async {
//     try {
//       final response = await _dio.get('addresses');
//       final data = response.data as List;
//       return data.map((e) => AddressModel.fromJson(e)).toList();
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<AddressModel> addAddress(Map<String, dynamic> addressData) async {
//     try {
//       final response = await _dio.post('addresses', data: addressData);
//       return AddressModel.fromJson(response.data);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<AddressModel> updateAddress(
//     String id,
//     Map<String, dynamic> addressData,
//   ) async {
//     try {
//       final response = await _dio.put('addresses/$id', data: addressData);
//       return AddressModel.fromJson(response.data);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> deleteAddress(String id) async {
//     try {
//       await _dio.delete('addresses/$id');
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<AddressModel> setDefaultAddress(String id) async {
//     try {
//       final response = await _dio.patch('addresses/$id/default');
//       return AddressModel.fromJson(response.data);
//     } catch (e) {
//       rethrow;
//     }
//   }
// }









import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_user/features/location/data/address_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'address_repository.g.dart';

@Riverpod(keepAlive: true)
AddressRepository addressRepository(AddressRepositoryRef ref) {
  return AddressRepository();
}

class AddressRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _addressCollection {
    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(uid).collection('addresses');
  }

  Future<List<AddressModel>> getAddresses() async {
    try {
      final snapshot = await _addressCollection.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Map document ID to _id for the model
        data['_id'] = doc.id;
        return AddressModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('❌ Error fetching addresses from Firestore: $e');
      rethrow;
    }
  }

  Future<AddressModel> addAddress(Map<String, dynamic> addressData) async {
    try {
      // If this is the first address or set as default, handle others
      if (addressData['isDefault'] == true) {
        await _clearDefaults();
      } else {
        // If it's the very first address, make it default anyway
        final existing = await getAddresses();
        if (existing.isEmpty) {
          addressData['isDefault'] = true;
        }
      }

      final docRef = await _addressCollection.add(addressData);
      final snapshot = await docRef.get();
      final data = snapshot.data()!;
      data['_id'] = snapshot.id;
      return AddressModel.fromJson(data);
    } catch (e) {
      print('❌ Error adding address to Firestore: $e');
      rethrow;
    }
  }

  Future<AddressModel> updateAddress(
    String id,
    Map<String, dynamic> addressData,
  ) async {
    try {
      if (addressData['isDefault'] == true) {
        await _clearDefaults();
      }
      
      await _addressCollection.doc(id).update(addressData);
      final snapshot = await _addressCollection.doc(id).get();
      final data = snapshot.data()!;
      data['_id'] = snapshot.id;
      return AddressModel.fromJson(data);
    } catch (e) {
      print('❌ Error updating address in Firestore: $e');
      rethrow;
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _addressCollection.doc(id).delete();
    } catch (e) {
      print('❌ Error deleting address from Firestore: $e');
      rethrow;
    }
  }

  Future<AddressModel> setDefaultAddress(String id) async {
    try {
      await _clearDefaults();
      await _addressCollection.doc(id).update({'isDefault': true});
      
      final snapshot = await _addressCollection.doc(id).get();
      final data = snapshot.data()!;
      data['_id'] = snapshot.id;
      return AddressModel.fromJson(data);
    } catch (e) {
      print('❌ Error setting default address in Firestore: $e');
      rethrow;
    }
  }

  Future<void> _clearDefaults() async {
    final snapshot = await _addressCollection.where('isDefault', isEqualTo: true).get();
    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }
    await batch.commit();
  }
}
