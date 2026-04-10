import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_user/core/models/banner_model.dart';
import 'package:cloud_user/core/models/category_model.dart';
import 'package:cloud_user/core/models/sub_category_model.dart';
import 'package:cloud_user/core/models/service_model.dart';
import 'package:cloud_user/features/home/data/about_us_model.dart';
import 'package:cloud_user/features/home/data/footer_model.dart';
import 'package:cloud_user/features/home/data/hero_section_model.dart';
import 'package:cloud_user/features/home/data/static_page_model.dart';
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

  int _readInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? fallback;
    return fallback;
  }

  double _readDouble(dynamic value, {double fallback = 0}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim()) ?? fallback;
    return fallback;
  }

  bool _readBool(dynamic value, {bool fallback = true}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return fallback;
  }

  DateTime? _readDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is Map && value['seconds'] != null) {
      final seconds = value['seconds'];
      final nanoseconds = value['nanoseconds'] ?? 0;
      if (seconds is num && nanoseconds is num) {
        return DateTime.fromMillisecondsSinceEpoch(
          (seconds.toInt() * 1000) + (nanoseconds.toInt() ~/ 1000000),
        );
      }
    }
    return null;
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      final categories = snapshot.docs.map((doc) {
        final data = doc.data();
        return CategoryModel(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          price: _readDouble(data['price']),
          imageUrl: data['imageUrl'] ?? '',
          isActive: _readBool(data['isActive'], fallback: true),
          displayOrder: _readInt(data['displayOrder'], fallback: 100000),
          mongoId: data['mongoId'],
        );
      }).toList();

      categories.sort((a, b) {
        if (a.displayOrder != b.displayOrder) {
          return a.displayOrder.compareTo(b.displayOrder);
        }
        return a.name.compareTo(b.name);
      });
      return categories;
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

      final services = docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ServiceModel.fromJson({'_id': doc.id, ...data});
      }).toList();

      services.sort((a, b) {
        final aOrder = a.displayOrder;
        final bOrder = b.displayOrder;
        if (aOrder != bOrder) return aOrder.compareTo(bOrder);
        return a.title.compareTo(b.title);
      });
      return services;
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
          isActive: _readBool(data['isActive'], fallback: true),
          imageUrl: data['imageUrl'] ?? '',
          displayOrder: _readInt(data['displayOrder']),
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
      final subs = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return SubCategoryModel(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'],
          price: _readDouble(data['price']),
          imageUrl: data['imageUrl'] ?? '',
          isActive: _readBool(data['isActive'], fallback: true),
          category: data['categoryId'],
          displayOrder: _readInt(data['displayOrder'], fallback: 100000),
          mongoId: data['mongoId'],
        );
      }).toList();

      subs.sort((a, b) {
        if (a.displayOrder != b.displayOrder) {
          return a.displayOrder.compareTo(b.displayOrder);
        }
        return a.name.compareTo(b.name);
      });
      return subs;
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

  Future<StaticPageModel?> getStaticPage(String slug) async {
    try {
      final snapshot = await _firestore
          .collection('web_landing')
          .doc('page_$slug')
          .get();
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      if (data == null || data.isEmpty) return null;
      return StaticPageModel.fromJson({'_id': snapshot.id, 'slug': slug, ...data});
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

  Future<FooterModel?> getFooter() async {
    try {
      final snapshot = await _firestore
          .collection('web_landing')
          .doc('footer')
          .get();
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      if (data == null) return null;
      return FooterModel.fromJson({'_id': snapshot.id, ...data});
    } catch (e) {
      return null;
    }
  }

  Stream<FooterModel?> watchFooter() {
    return _firestore
        .collection('web_landing')
        .doc('footer')
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      if (data == null) return null;
      return FooterModel.fromJson({'_id': snapshot.id, ...data});
    });
  }

  Future<List<TestimonialModel>> getTestimonials() async {
    try {
      final snapshot = await _firestore.collection('testimonials').get();
      return _mapTestimonials(snapshot.docs);
    } catch (e) {
      return [];
    }
  }

  Stream<List<TestimonialModel>> watchTestimonials() {
    return _firestore.collection('testimonials').snapshots().map(
          (snapshot) => _mapTestimonials(snapshot.docs),
        );
  }

  List<TestimonialModel> _mapTestimonials(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final items = docs
        .map((doc) => {'_id': doc.id, ...doc.data()})
        .where((item) => _readBool(item['isActive'], fallback: true))
        .toList();

    items.sort((a, b) {
      final aTime =
          _readDateTime(a['createdAt'])?.millisecondsSinceEpoch ?? 0;
      final bTime =
          _readDateTime(b['createdAt'])?.millisecondsSinceEpoch ?? 0;
      if (aTime != bTime) return bTime.compareTo(aTime);
      return (a['name'] ?? '')
          .toString()
          .compareTo((b['name'] ?? '').toString());
    });

    return items
        .map((item) => TestimonialModel.fromJson(item))
        .toList(growable: false);
  }

  Future<List<WhyChooseUsModel>> getWhyChooseUs() async {
    try {
      final snapshot = await _firestore.collection('whyChooseUs').get();
      return _mapWhyChooseUs(snapshot.docs);
    } catch (e) {
      return [];
    }
  }

  Stream<List<WhyChooseUsModel>> watchWhyChooseUs() {
    return _firestore.collection('whyChooseUs').snapshots().map((snapshot) {
      final items = _mapWhyChooseUs(snapshot.docs);
      return items;
    });
  }

  List<WhyChooseUsModel> _mapWhyChooseUs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final items = docs
        .map((doc) => {'_id': doc.id, ...doc.data()})
        .where((item) => _readBool(item['isActive'], fallback: true))
        .toList();

    items.sort((a, b) {
      final aTime = _readDateTime(a['createdAt'])?.millisecondsSinceEpoch ?? 0;
      final bTime = _readDateTime(b['createdAt'])?.millisecondsSinceEpoch ?? 0;
      if (aTime != bTime) return aTime.compareTo(bTime);
      return (a['title'] ?? '').toString().compareTo((b['title'] ?? '').toString());
    });

    return items
        .map((item) => WhyChooseUsModel.fromJson(item))
        .toList(growable: false);
  }
}
