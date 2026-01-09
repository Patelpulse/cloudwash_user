import 'package:cloud_user/core/models/addon_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'addons_provider.g.dart';

@riverpod
Future<List<AddonModel>> addons(AddonsRef ref) async {
  try {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('addons').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return AddonModel.fromJson({'_id': doc.id, ...data});
    }).toList();
  } catch (e) {
    print('🔥 Firebase Addons Error: $e');
    return [];
  }
}
