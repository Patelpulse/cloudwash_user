import 'package:cloud_user/core/config/app_config.dart';
import 'package:cloud_user/core/models/banner_model.dart';
import 'package:cloud_user/core/models/category_model.dart';
import 'package:cloud_user/core/models/service_model.dart';
import 'package:cloud_user/features/home/data/footer_model.dart';
import 'package:cloud_user/features/home/data/why_choose_us_model.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';

part 'home_repository.g.dart';

@Riverpod(keepAlive: true)
HomeRepository homeRepository(HomeRepositoryRef ref) {
  return HomeRepository(ref.watch(apiClientProvider));
}

class HomeRepository {
  final Dio _dio;

  HomeRepository(this._dio);

  Future<List<CategoryModel>> getCategories() async {
    try {
      // Logic from APIService: apiClient.get('/categories')
      final response = await _dio.get('categories');

      // Backend returns a direct list, not { data: [] }
      final data = response.data as List;
      final categories = data.map((e) => CategoryModel.fromJson(e)).toList();
      categories.sort((a, b) {
        if (a.displayOrder != b.displayOrder) {
          return a.displayOrder.compareTo(b.displayOrder);
        }
        return a.name.compareTo(b.name);
      });
      return categories;
    } catch (e) {
      if (e is DioException) {
        print('API Error (Categories): ${e.message} - ${e.response?.data}');
      }
      rethrow; // Rethrow to see the actual error in UI instead of mock data
    }
  }

  Future<List<ServiceModel>> getPopularServices() async {
    try {
      final response = await _dio.get('services?popular=true');
      final data = response.data as List;
      return data.map((e) => ServiceModel.fromJson(e)).toList();
    } catch (e) {
      return [
        ServiceModel(
          id: '1',
          title: 'Wash & Fold',
          price: 49,
          category: 'Laundry',
          rating: 4.8,
          reviewCount: 120,
          image: 'https://cdn-icons-png.flaticon.com/512/3003/3003984.png',
        ),
        ServiceModel(
          id: '2',
          title: 'Premium Dry Clean',
          price: 149,
          category: 'Dry Cleaning',
          rating: 4.9,
          reviewCount: 215,
          image: 'https://cdn-icons-png.flaticon.com/512/2954/2954835.png',
        ),
      ];
    }
  }

  Future<List<BannerModel>> getBanners() async {
    try {
      final response = await _dio.get('banners');
      final data = response.data as List;
      return data.map((e) => BannerModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ServiceModel>> getAllServices() async {
    try {
      final response = await _dio.get('services');
      final data = response.data as List;
      return data.map((e) => ServiceModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<WhyChooseUsModel>> getWhyChooseUs() async {
    try {
      final response = await _dio.get(
        'why-choose-us',
        queryParameters: {
          '_ts': DateTime.now().millisecondsSinceEpoch,
        },
      );

      final data = response.data;
      if (data is! List) return [];

      return data
          .whereType<Map>()
          .map((e) => WhyChooseUsModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      if (e is DioException) {
        print('API Error (Why Choose Us): ${e.message} - ${e.response?.data}');
      }
      return [];
    }
  }

  Future<FooterModel?> getFooter() async {
    try {
      final response = await _dio.get(
        'web-content/footer',
        queryParameters: {
          '_ts': DateTime.now().millisecondsSinceEpoch,
        },
      );

      final data = response.data;
      if (data is! Map) return null;
      return FooterModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      if (e is DioException) {
        print('API Error (Footer): ${e.message} - ${e.response?.data}');
      }
      return null;
    }
  }

  Future<List<dynamic>> getSubCategories() async {
    try {
      final response = await _dio.get('sub-categories');
      return response.data as List;
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getHeroSection() async {
    try {
      final response = await _dio.get('hero');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getAboutUs() async {
    try {
      final response = await _dio.get(
        'web-content/about',
        queryParameters: {
          '_ts': DateTime.now().millisecondsSinceEpoch,
        },
      );
      final data = response.data;
      if (data is! Map) return null;
      return Map<String, dynamic>.from(data);
    } catch (e) {
      if (e is DioException) {
        print('API Error (About Us): ${e.message} - ${e.response?.data}');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> getStats() async {
    try {
      final response = await _dio.get(
        'web-content/stats',
        queryParameters: {
          '_ts': DateTime.now().millisecondsSinceEpoch,
        },
      );
      final data = response.data;
      if (data is! Map) return null;
      return Map<String, dynamic>.from(data);
    } catch (e) {
      if (e is DioException) {
        print('API Error (Stats): ${e.message} - ${e.response?.data}');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> getStaticPage(String slug) async {
    try {
      final response = await _dio.get(
        'web-content/pages/$slug',
        queryParameters: {
          '_ts': DateTime.now().millisecondsSinceEpoch,
        },
      );
      final data = response.data;
      if (data is! Map) return null;
      return Map<String, dynamic>.from(data);
    } catch (e) {
      if (e is DioException) {
        print('API Error (Static Page: $slug): ${e.message} - ${e.response?.data}');
      }
      return null;
    }
  }
}
