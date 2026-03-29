import 'package:cloud_user/core/models/banner_model.dart';
import 'package:cloud_user/core/models/category_model.dart';
import 'package:cloud_user/core/models/sub_category_model.dart';
import 'package:cloud_user/core/models/service_model.dart';
import 'package:cloud_user/features/home/data/firebase_home_repository.dart';
import 'package:cloud_user/features/home/data/hero_section_model.dart';
import 'package:cloud_user/features/home/data/home_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_providers.g.dart';

@Riverpod(keepAlive: true)
Future<List<CategoryModel>> categories(CategoriesRef ref) {
  return ref.watch(firebaseHomeRepositoryProvider).getCategories();
}

@Riverpod(keepAlive: true)
Future<List<SubCategoryModel>> subCategories(SubCategoriesRef ref) async {
  final data =
      await ref.watch(firebaseHomeRepositoryProvider).getSubCategories();
  if (data.isEmpty) {
    // Return mock data ONLY if Firestore is completely empty
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
    ];
  }
  return data;
}

@Riverpod(keepAlive: true)
Future<List<SubCategoryModel>> subCategoriesByCategory(
  SubCategoriesByCategoryRef ref,
  String categoryId,
) async {
  return ref
      .watch(firebaseHomeRepositoryProvider)
      .getSubCategories(categoryId: categoryId);
}

@Riverpod(keepAlive: true)
Future<List<BannerModel>> homeBanners(HomeBannersRef ref) {
  return ref.watch(firebaseHomeRepositoryProvider).getBanners();
}

@Riverpod(keepAlive: true)
Future<List<ServiceModel>> spotlightServices(SpotlightServicesRef ref) async {
  final services =
      await ref.watch(firebaseHomeRepositoryProvider).getServices();
  return services.take(8).toList();
}

@Riverpod(keepAlive: true)
Future<List<ServiceModel>> topServices(TopServicesRef ref) async {
  final services =
      await ref.watch(firebaseHomeRepositoryProvider).getServices();
  return services.take(10).toList();
}

@Riverpod(keepAlive: true)
Future<List<ServiceModel>> services(
  ServicesRef ref, {
  String? categoryId,
  String? subCategoryId,
}) async {
  return ref
      .watch(firebaseHomeRepositoryProvider)
      .getServices(categoryId: categoryId, subCategoryId: subCategoryId);
}

@Riverpod(keepAlive: true)
Future<HeroSectionModel?> heroSection(HeroSectionRef ref) async {
  HeroSectionModel? apiHero;
  HeroSectionModel? firebaseHero;

  try {
    final apiHeroJson =
        await ref.watch(homeRepositoryProvider).getHeroSection();
    if (apiHeroJson != null) {
      apiHero = HeroSectionModel.fromJson(apiHeroJson);
    }
  } catch (_) {}

  try {
    firebaseHero =
        await ref.watch(firebaseHomeRepositoryProvider).getHeroSection();
  } catch (_) {}

  final baseHero =
      _hasCoreHeroContent(apiHero) ? apiHero : (firebaseHero ?? apiHero);
  if (baseHero == null) return null;

  // Firestore `web_landing/hero.logoUrl` is treated as source of truth for logo,
  // so website shows the same logo uploaded from admin even if API lags behind.
  final firebaseLogo = (firebaseHero?.logoUrl ?? '').trim();
  if (firebaseLogo.isEmpty) return baseHero;

  return HeroSectionModel(
    id: baseHero.id,
    tagline: baseHero.tagline,
    mainTitle: baseHero.mainTitle,
    description: baseHero.description,
    buttonText: baseHero.buttonText,
    imageUrl: baseHero.imageUrl,
    logoUrl: firebaseLogo,
    youtubeUrl: baseHero.youtubeUrl,
    isActive: baseHero.isActive,
  );
}

bool _hasCoreHeroContent(HeroSectionModel? hero) {
  if (hero == null) return false;
  return hero.mainTitle.trim().isNotEmpty ||
      hero.description.trim().isNotEmpty ||
      hero.tagline.trim().isNotEmpty ||
      hero.imageUrl.trim().isNotEmpty;
}
