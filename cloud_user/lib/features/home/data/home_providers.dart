import 'package:cloud_user/core/models/banner_model.dart';
import 'package:cloud_user/core/models/category_model.dart';
import 'package:cloud_user/core/models/sub_category_model.dart';
import 'package:cloud_user/core/models/service_model.dart';
import 'package:cloud_user/features/home/data/hero_provider.dart';
import 'package:cloud_user/features/home/data/home_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_providers.g.dart';

@riverpod
Future<List<CategoryModel>> categories(CategoriesRef ref) {
  return ref.watch(homeRepositoryProvider).getCategories();
}

@riverpod
Future<List<SubCategoryModel>> subCategories(SubCategoriesRef ref) async {
  final data = await ref.watch(homeRepositoryProvider).getSubCategories();
  if (data.isEmpty) {
    // Return mock data if API is empty
    return [
      SubCategoryModel(
        id: '1',
        name: 'Wash & Fold',
        price: 49,
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/3003/3003984.png',
      ),
      SubCategoryModel(
        id: '2',
        name: 'Dry Clean',
        price: 99,
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/2954/2954835.png',
      ),
      SubCategoryModel(
        id: '3',
        name: 'Ironing',
        price: 19,
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/2954/2954930.png',
      ),
      SubCategoryModel(
        id: '4',
        name: 'Shoe Laundry',
        price: 149,
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/5400/5400782.png',
      ),
    ];
  }
  return data.map((e) => SubCategoryModel.fromJson(e)).toList();
}

@riverpod
Future<List<BannerModel>> homeBanners(HomeBannersRef ref) {
  return ref.watch(homeRepositoryProvider).getBanners();
}

@riverpod
Future<List<ServiceModel>> spotlightServices(SpotlightServicesRef ref) async {
  final services = await ref.watch(homeRepositoryProvider).getAllServices();
  // For now, just take the first 5 or any with high rating
  return services.take(5).toList();
}

@riverpod
Future<List<ServiceModel>> topServices(TopServicesRef ref) async {
  final services = await ref.watch(homeRepositoryProvider).getAllServices();
  // Shuffle and take 6
  final list = List<ServiceModel>.from(services)..shuffle();
  return list.take(6).toList();
}

@riverpod
Future<Map<String, dynamic>?> heroSection(HeroSectionRef ref) {
  return ref.watch(homeRepositoryProvider).getHeroSection();
}
