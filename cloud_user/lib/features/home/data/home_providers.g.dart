// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoriesHash() => r'a1fa03f3a92ceddf20a4a5d2c49dae1f089876b5';

/// See also [categories].
@ProviderFor(categories)
final categoriesProvider =
    AutoDisposeFutureProvider<List<CategoryModel>>.internal(
      categories,
      name: r'categoriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$categoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoriesRef = AutoDisposeFutureProviderRef<List<CategoryModel>>;
String _$subCategoriesHash() => r'67355492d7b1b3a974fafac11b2e91f2ff1a6284';

/// See also [subCategories].
@ProviderFor(subCategories)
final subCategoriesProvider =
    AutoDisposeFutureProvider<List<SubCategoryModel>>.internal(
      subCategories,
      name: r'subCategoriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$subCategoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SubCategoriesRef = AutoDisposeFutureProviderRef<List<SubCategoryModel>>;
String _$subCategoriesByCategoryHash() =>
    r'197638fc80b80445970e9b3ae7847117dfaa6f8d';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [subCategoriesByCategory].
@ProviderFor(subCategoriesByCategory)
const subCategoriesByCategoryProvider = SubCategoriesByCategoryFamily();

/// See also [subCategoriesByCategory].
class SubCategoriesByCategoryFamily
    extends Family<AsyncValue<List<SubCategoryModel>>> {
  /// See also [subCategoriesByCategory].
  const SubCategoriesByCategoryFamily();

  /// See also [subCategoriesByCategory].
  SubCategoriesByCategoryProvider call(String categoryId) {
    return SubCategoriesByCategoryProvider(categoryId);
  }

  @override
  SubCategoriesByCategoryProvider getProviderOverride(
    covariant SubCategoriesByCategoryProvider provider,
  ) {
    return call(provider.categoryId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'subCategoriesByCategoryProvider';
}

/// See also [subCategoriesByCategory].
class SubCategoriesByCategoryProvider
    extends AutoDisposeFutureProvider<List<SubCategoryModel>> {
  /// See also [subCategoriesByCategory].
  SubCategoriesByCategoryProvider(String categoryId)
    : this._internal(
        (ref) => subCategoriesByCategory(
          ref as SubCategoriesByCategoryRef,
          categoryId,
        ),
        from: subCategoriesByCategoryProvider,
        name: r'subCategoriesByCategoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$subCategoriesByCategoryHash,
        dependencies: SubCategoriesByCategoryFamily._dependencies,
        allTransitiveDependencies:
            SubCategoriesByCategoryFamily._allTransitiveDependencies,
        categoryId: categoryId,
      );

  SubCategoriesByCategoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final String categoryId;

  @override
  Override overrideWith(
    FutureOr<List<SubCategoryModel>> Function(
      SubCategoriesByCategoryRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SubCategoriesByCategoryProvider._internal(
        (ref) => create(ref as SubCategoriesByCategoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SubCategoryModel>> createElement() {
    return _SubCategoriesByCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SubCategoriesByCategoryProvider &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SubCategoriesByCategoryRef
    on AutoDisposeFutureProviderRef<List<SubCategoryModel>> {
  /// The parameter `categoryId` of this provider.
  String get categoryId;
}

class _SubCategoriesByCategoryProviderElement
    extends AutoDisposeFutureProviderElement<List<SubCategoryModel>>
    with SubCategoriesByCategoryRef {
  _SubCategoriesByCategoryProviderElement(super.provider);

  @override
  String get categoryId =>
      (origin as SubCategoriesByCategoryProvider).categoryId;
}

String _$homeBannersHash() => r'06a991a92e3012a587b095d544c1a43365dab995';

/// See also [homeBanners].
@ProviderFor(homeBanners)
final homeBannersProvider =
    AutoDisposeFutureProvider<List<BannerModel>>.internal(
      homeBanners,
      name: r'homeBannersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$homeBannersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HomeBannersRef = AutoDisposeFutureProviderRef<List<BannerModel>>;
String _$spotlightServicesHash() => r'024e2cd13f9652c5656f351ee231570550223962';

/// See also [spotlightServices].
@ProviderFor(spotlightServices)
final spotlightServicesProvider =
    AutoDisposeFutureProvider<List<ServiceModel>>.internal(
      spotlightServices,
      name: r'spotlightServicesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$spotlightServicesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SpotlightServicesRef = AutoDisposeFutureProviderRef<List<ServiceModel>>;
String _$topServicesHash() => r'b5606559eb75a01a1ad4651b0dbe91de25f7b5ec';

/// See also [topServices].
@ProviderFor(topServices)
final topServicesProvider =
    AutoDisposeFutureProvider<List<ServiceModel>>.internal(
      topServices,
      name: r'topServicesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$topServicesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TopServicesRef = AutoDisposeFutureProviderRef<List<ServiceModel>>;
String _$servicesHash() => r'ec60d94e1bcda57439ef8b67fb8cfdb764893db0';

/// See also [services].
@ProviderFor(services)
const servicesProvider = ServicesFamily();

/// See also [services].
class ServicesFamily extends Family<AsyncValue<List<ServiceModel>>> {
  /// See also [services].
  const ServicesFamily();

  /// See also [services].
  ServicesProvider call({String? categoryId, String? subCategoryId}) {
    return ServicesProvider(
      categoryId: categoryId,
      subCategoryId: subCategoryId,
    );
  }

  @override
  ServicesProvider getProviderOverride(covariant ServicesProvider provider) {
    return call(
      categoryId: provider.categoryId,
      subCategoryId: provider.subCategoryId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'servicesProvider';
}

/// See also [services].
class ServicesProvider extends AutoDisposeFutureProvider<List<ServiceModel>> {
  /// See also [services].
  ServicesProvider({String? categoryId, String? subCategoryId})
    : this._internal(
        (ref) => services(
          ref as ServicesRef,
          categoryId: categoryId,
          subCategoryId: subCategoryId,
        ),
        from: servicesProvider,
        name: r'servicesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$servicesHash,
        dependencies: ServicesFamily._dependencies,
        allTransitiveDependencies: ServicesFamily._allTransitiveDependencies,
        categoryId: categoryId,
        subCategoryId: subCategoryId,
      );

  ServicesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
    required this.subCategoryId,
  }) : super.internal();

  final String? categoryId;
  final String? subCategoryId;

  @override
  Override overrideWith(
    FutureOr<List<ServiceModel>> Function(ServicesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ServicesProvider._internal(
        (ref) => create(ref as ServicesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
        subCategoryId: subCategoryId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ServiceModel>> createElement() {
    return _ServicesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ServicesProvider &&
        other.categoryId == categoryId &&
        other.subCategoryId == subCategoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);
    hash = _SystemHash.combine(hash, subCategoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ServicesRef on AutoDisposeFutureProviderRef<List<ServiceModel>> {
  /// The parameter `categoryId` of this provider.
  String? get categoryId;

  /// The parameter `subCategoryId` of this provider.
  String? get subCategoryId;
}

class _ServicesProviderElement
    extends AutoDisposeFutureProviderElement<List<ServiceModel>>
    with ServicesRef {
  _ServicesProviderElement(super.provider);

  @override
  String? get categoryId => (origin as ServicesProvider).categoryId;
  @override
  String? get subCategoryId => (origin as ServicesProvider).subCategoryId;
}

String _$heroSectionHash() => r'458c558cba2a759de74c0d5aa0a6830af33baf6f';

/// See also [heroSection].
@ProviderFor(heroSection)
final heroSectionProvider =
    AutoDisposeFutureProvider<HeroSectionModel?>.internal(
      heroSection,
      name: r'heroSectionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$heroSectionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HeroSectionRef = AutoDisposeFutureProviderRef<HeroSectionModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
