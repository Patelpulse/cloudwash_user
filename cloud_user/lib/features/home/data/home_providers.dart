import 'dart:async';
import 'dart:convert';

import 'package:cloud_user/core/models/banner_model.dart';
import 'package:cloud_user/core/models/category_model.dart';
import 'package:cloud_user/core/models/sub_category_model.dart';
import 'package:cloud_user/core/models/service_model.dart';
import 'package:cloud_user/core/utils/device_logo_utils.dart';
import 'package:cloud_user/features/home/data/firebase_home_repository.dart';
import 'package:cloud_user/features/home/data/hero_section_model.dart';
import 'package:cloud_user/features/home/data/home_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_providers.g.dart';

Future<HeroSectionModel?> _loadHeroSection({
  required HomeRepository apiRepository,
  required FirebaseHomeRepository firebaseRepository,
}) async {
  HeroSectionModel? apiHero;
  HeroSectionModel? firebaseHero;

  try {
    final apiHeroJson = await apiRepository.getHeroSection();
    if (apiHeroJson != null) {
      apiHero = HeroSectionModel.fromJson(apiHeroJson);
    }
  } catch (_) {}

  try {
    firebaseHero = await firebaseRepository.getHeroSection();
  } catch (_) {}

  final baseHero = _hasCoreHeroContent(apiHero)
      ? apiHero
      : (_hasCoreHeroContent(firebaseHero)
          ? firebaseHero
          : null);
  if (baseHero == null) return null;

  final mergedLogoByDevice = mergeLogoByDeviceMaps([
    firebaseHero?.logoByDevice,
    apiHero?.logoByDevice,
    {'website': firebaseHero?.logoUrl.trim() ?? ''},
    {'website': apiHero?.logoUrl.trim() ?? ''},
  ]);

  final resolvedLogoHeight =
      apiHero?.logoHeight ?? firebaseHero?.logoHeight ?? baseHero.logoHeight;

  final resolvedWebsiteLogo =
      (mergedLogoByDevice['website'] ?? '').trim().isNotEmpty
          ? mergedLogoByDevice['website']!.trim()
          : baseHero.logoUrl.trim();

  final resolvedTitleFontFamily = _resolvePreferredString(
    apiHero?.titleFontFamily,
    firebaseHero?.titleFontFamily,
    fallback: 'Playfair Display',
  );
  final resolvedBodyFontFamily = _resolvePreferredString(
    apiHero?.bodyFontFamily,
    firebaseHero?.bodyFontFamily,
    fallback: 'Inter',
  );
  final resolvedTitleColor = _resolvePreferredString(
    apiHero?.titleColor,
    firebaseHero?.titleColor,
    fallback: '#1E293B',
  );
  final resolvedDescriptionColor = _resolvePreferredString(
    apiHero?.descriptionColor,
    firebaseHero?.descriptionColor,
    fallback: '#64748B',
  );
  final resolvedAccentColor = _resolvePreferredString(
    apiHero?.accentColor,
    firebaseHero?.accentColor,
    fallback: '#3B82F6',
  );
  final resolvedButtonTextColor = _resolvePreferredString(
    apiHero?.buttonTextColor,
    firebaseHero?.buttonTextColor,
    fallback: '#FFFFFF',
  );
  final resolvedTitleFontSize = _resolvePreferredFontSize(
    apiHero?.titleFontSize,
    firebaseHero?.titleFontSize,
    fallback: 64,
  );
  final resolvedDescriptionFontSize = _resolvePreferredFontSize(
    apiHero?.descriptionFontSize,
    firebaseHero?.descriptionFontSize,
    fallback: 18,
  );

  return HeroSectionModel(
    id: baseHero.id,
    tagline: baseHero.tagline,
    mainTitle: baseHero.mainTitle,
    description: baseHero.description,
    buttonText: baseHero.buttonText,
    titleFontFamily: resolvedTitleFontFamily,
    bodyFontFamily: resolvedBodyFontFamily,
    titleFontSize: resolvedTitleFontSize,
    descriptionFontSize: resolvedDescriptionFontSize,
    titleColor: resolvedTitleColor,
    descriptionColor: resolvedDescriptionColor,
    accentColor: resolvedAccentColor,
    buttonTextColor: resolvedButtonTextColor,
    imageUrl: baseHero.imageUrl,
    logoUrl: resolvedWebsiteLogo,
    logoByDevice: mergedLogoByDevice,
    logoHeight: resolvedLogoHeight,
    youtubeUrl: baseHero.youtubeUrl,
    isActive: baseHero.isActive,
  );
}

Object? _canonicalJsonValue(dynamic value) {
  if (value is Map) {
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    return {
      for (final key in keys) key: _canonicalJsonValue(value[key]),
    };
  }
  if (value is Iterable) {
    return value.map(_canonicalJsonValue).toList();
  }
  return value;
}

String _stableJsonSignature(dynamic value) {
  return jsonEncode(_canonicalJsonValue(value));
}

String _resolvePreferredString(
  String? primary,
  String? secondary, {
  required String fallback,
}) {
  String? normalize(String? value) {
    final text = (value ?? '').trim();
    return text.isEmpty ? null : text;
  }

  final normalizedPrimary = normalize(primary);
  final normalizedSecondary = normalize(secondary);

  bool isMeaningful(String? value) {
    return value != null && value.toLowerCase() != fallback.toLowerCase();
  }

  if (isMeaningful(normalizedPrimary)) return normalizedPrimary!;
  if (isMeaningful(normalizedSecondary)) return normalizedSecondary!;
  if (normalizedPrimary != null) return normalizedPrimary;
  if (normalizedSecondary != null) return normalizedSecondary;
  return fallback;
}

double _resolvePreferredFontSize(
  double? primary,
  double? secondary, {
  required double fallback,
}) {
  bool isMeaningful(double? value) {
    return value != null && value > 0 && (value - fallback).abs() > 0.0001;
  }

  if (isMeaningful(primary)) return primary!;
  if (isMeaningful(secondary)) return secondary!;
  if (primary != null && primary > 0) return primary;
  if (secondary != null && secondary > 0) return secondary;
  return fallback;
}

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
  return _loadHeroSection(
    apiRepository: ref.watch(homeRepositoryProvider),
    firebaseRepository: ref.watch(firebaseHomeRepositoryProvider),
  );
}

final liveHeroSectionProvider =
    StreamProvider.autoDispose<HeroSectionModel?>((ref) async* {
  final apiRepository = ref.watch(homeRepositoryProvider);
  final firebaseRepository = ref.watch(firebaseHomeRepositoryProvider);
  String? lastSignature;

  while (true) {
    HeroSectionModel? data;
    try {
      data = await _loadHeroSection(
        apiRepository: apiRepository,
        firebaseRepository: firebaseRepository,
      ).timeout(const Duration(seconds: 30));
    } on TimeoutException {
      data = null;
    }
    final signature = _stableJsonSignature(data?.toJson());
    if (signature != lastSignature) {
      lastSignature = signature;
      yield data;
    }
    await Future<void>.delayed(const Duration(seconds: 60));
  }
});

bool _hasCoreHeroContent(HeroSectionModel? hero) {
  if (hero == null) return false;
  return hero.tagline.trim().isNotEmpty ||
      hero.mainTitle.trim().isNotEmpty ||
      hero.description.trim().isNotEmpty ||
      hero.buttonText.trim().isNotEmpty ||
      hero.imageUrl.trim().isNotEmpty ||
      hero.logoUrl.trim().isNotEmpty ||
      hero.youtubeUrl?.trim().isNotEmpty == true ||
      hero.logoByDevice.values.any((logo) => logo.trim().isNotEmpty);
}
