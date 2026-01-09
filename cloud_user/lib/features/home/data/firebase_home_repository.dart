import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_user/core/models/banner_model.dart';
import 'package:cloud_user/core/models/category_model.dart';
import 'package:cloud_user/core/models/sub_category_model.dart';
import 'package:cloud_user/core/models/service_model.dart';
import 'package:cloud_user/features/home/data/about_us_model.dart';
import 'package:cloud_user/features/home/data/hero_section_model.dart';
import 'package:cloud_user/features/home/data/stats_model.dart';
import 'package:cloud_user/features/home/data/testimonial_model.dart';
import 'package:cloud_user/features/home/data/why_choose_us_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_home_repository.g.dart';

@Riverpod(keepAlive: true)
FirebaseHomeRepository firebaseHomeRepository(FirebaseHomeRepositoryRef ref) {
  return FirebaseHomeRepository(FirebaseFirestore.instance);
}

class FirebaseHomeRepository {
  final FirebaseFirestore _firestore;

  FirebaseHomeRepository(this._firestore);

  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return CategoryModel(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          imageUrl: data['imageUrl'] ?? '',
          isActive: data['isActive'] ?? true,
          mongoId: data['mongoId'],
        );
      }).toList();
    } catch (e) {
      print('Firebase Error (Categories): $e');
      rethrow;
    }
  }

  Future<List<ServiceModel>> getServices({
    String? categoryId,
    String? subCategoryId,
  }) async {
    try {
      Query query = _firestore.collection('services');
      if (categoryId != null)
        query = query.where('category', isEqualTo: categoryId);

      if (subCategoryId != null) {
        // Try to fetch by checking if 'subCategory' matches the ID
        // Note: We might need to handle cases where 'subCategory' is a reference or just a string ID.
        // Also, for legacy data, we might need to check if we need to query by 'subCategoryId' (if that field exists)
        // or if we need to look up the sub-category first to get its mongoId.
        // For now, let's assume direct match.
        query = query.where('subCategory', isEqualTo: subCategoryId);
      }

      final snapshot = await query.get();

      // If no services found with direct ID match, and we have a subCategoryId,
      // try to see if there are services linked via a "mongoId" (if the subCategoryId passed was a mongoId,
      // but we switched to passing Firestore ID).
      // actually, if we are passing Firestore ID now, and services are linked by Mongo ID, we have a mismatch.

      // But let's look at the result first.
      var docs = snapshot.docs;

      // FALLBACK: If docs are empty and we have a subCategoryId (which is likely a Firestore ID),
      // we need to check if we should be querying by the SubCategory's 'mongoId' instead.
      if (docs.isEmpty && subCategoryId != null) {
        // 1. Fetch the SubCategory document to get its mongoId
        final subCatDoc = await _firestore
            .collection('subCategories')
            .doc(subCategoryId)
            .get();
        if (subCatDoc.exists) {
          final data = subCatDoc.data();
          final mongoId = data?['mongoId'];

          if (mongoId != null) {
            // 2. Query services using the MongoID in the 'subCategoryId' field (used by migration)
            final query2 = _firestore
                .collection('services')
                .where('subCategoryId', isEqualTo: mongoId);
            final snapshot2 = await query2.get();
            if (snapshot2.docs.isNotEmpty) {
              docs = snapshot2.docs;
            }
          }
        }

        // As a last LAST resort, check if 'subCategoryId' field matches the Firestore ID directy
        if (docs.isEmpty) {
          final query3 = _firestore
              .collection('services')
              .where('subCategoryId', isEqualTo: subCategoryId);
          final snapshot3 = await query3.get();
          if (snapshot3.docs.isNotEmpty) {
            docs = snapshot3.docs;
          }
        }
      }

      return docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ServiceModel.fromJson({'_id': doc.id, ...data});
      }).toList();
    } catch (e) {
      print('Firebase Error (Services): $e');
      return [];
    }
  }

  Future<List<BannerModel>> getBanners() async {
    try {
      final snapshot = await _firestore.collection('banners').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BannerModel(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          position: data['position'] ?? 'home',
          isActive: data['isActive'] ?? true,
          imageUrl: data['imageUrl'] ?? '',
          displayOrder: data['displayOrder'] ?? 0,
        );
      }).toList();
    } catch (e) {
      print('Firebase Error (Banners): $e');
      return [];
    }
  }

  Future<List<SubCategoryModel>> getSubCategories({String? categoryId}) async {
    try {
      Query query = _firestore.collection('subCategories');
      if (categoryId != null)
        query = query.where('categoryId', isEqualTo: categoryId);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return SubCategoryModel(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'],
          price: (data['price'] ?? 0).toDouble(),
          imageUrl: data['imageUrl'] ?? '',
          isActive: data['isActive'] ?? true,
          category: data['categoryId'],
          mongoId: data['mongoId'],
        );
      }).toList();
    } catch (e) {
      print('Firebase Error (SubCategories): $e');
      return [];
    }
  }

  Future<HeroSectionModel?> getHeroSection() async {
    try {
      final snapshot = await _firestore
          .collection('web_landing')
          .doc('hero')
          .get();
      if (snapshot.exists) {
        final data = snapshot.data()!;
        return HeroSectionModel.fromJson({'_id': snapshot.id, ...data});
      }
      return null;
    } catch (e) {
      print('Firebase Error (Hero): $e');
      return null;
    }
  }

  Future<AboutUsModel?> getAboutUs() async {
    try {
      final snapshot = await _firestore
          .collection('web_landing')
          .doc('about')
          .get();
      if (snapshot.exists) {
        return AboutUsModel.fromJson({'_id': snapshot.id, ...snapshot.data()!});
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<StatsModel?> getStats() async {
    try {
      final snapshot = await _firestore
          .collection('web_landing')
          .doc('stats')
          .get();
      if (snapshot.exists) {
        return StatsModel.fromJson({'_id': snapshot.id, ...snapshot.data()!});
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<TestimonialModel>> getTestimonials() async {
    try {
      final snapshot = await _firestore.collection('testimonials').get();
      return snapshot.docs
          .map(
            (doc) => TestimonialModel.fromJson({'_id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<WhyChooseUsModel>> getWhyChooseUs() async {
    try {
      final snapshot = await _firestore.collection('whyChooseUs').get();
      return snapshot.docs
          .map(
            (doc) => WhyChooseUsModel.fromJson({'_id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }
}
