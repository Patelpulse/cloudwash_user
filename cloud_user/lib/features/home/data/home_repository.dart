import 'package:cloud_user/core/models/banner_model.dart';
import 'package:cloud_user/core/models/category_model.dart';
import 'package:cloud_user/core/models/service_model.dart';
import 'package:cloud_user/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
      return data.map((e) => CategoryModel.fromJson(e)).toList();
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
      final response = await _dio.get('hero-section');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return {
        'youtubeUrl':
            'https://player.cloudinary.com/embed/?cloud_name=dssmutzly&public_id=795v3npt7drmt0cvkhmsjtwxs4_result__zj0nsr&fluid=true&controls=false&autoplay=true&loop=true&muted=1&show_logo=false&bigPlayButton=false',
        'isActive': true,
      };
    }
  }
}
