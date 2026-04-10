import 'dart:convert';

import 'package:cloud_user/features/home/data/about_us_model.dart';
import 'package:cloud_user/features/home/data/static_page_model.dart';
import 'package:cloud_user/features/home/data/home_repository.dart';
import 'package:cloud_user/features/home/data/firebase_home_repository.dart';
import 'package:cloud_user/features/home/data/stats_model.dart';
import 'package:cloud_user/features/home/data/testimonial_model.dart';
import 'package:cloud_user/features/home/data/why_choose_us_model.dart';
import 'package:cloud_user/features/home/data/footer_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'web_content_providers.g.dart';

String _stableJsonSignature(dynamic value) {
  Object? normalize(dynamic input) {
    if (input is Map) {
      final keys = input.keys.map((key) => key.toString()).toList()..sort();
      return {
        for (final key in keys) key: normalize(input[key]),
      };
    }
    if (input is Iterable) {
      return input.map(normalize).toList();
    }
    return input;
  }

  return jsonEncode(normalize(value));
}

List<WhyChooseUsModel> _defaultWhyChooseUsItems() {
  return [
    WhyChooseUsModel(
      id: '1',
      title: 'Premium Quality',
      description: 'We use the finest detergents and specialized care.',
      iconUrl: '',
      isActive: true,
    ),
    WhyChooseUsModel(
      id: '2',
      title: 'Express Delivery',
      description: 'Get your clothes back clean within 24 hours.',
      iconUrl: '',
      isActive: true,
    ),
    WhyChooseUsModel(
      id: '3',
      title: 'Expert Handling',
      description:
          'Our staff is trained to handle delicate fabrics with care.',
      iconUrl: '',
      isActive: true,
    ),
  ];
}

FooterModel _defaultFooter() {
  return FooterModel(
    description:
        'Redefining premium garment care with technology and craftsmanship. Your wardrobe deserves nothing but the best.',
    phone: '+91 98765 43210',
    email: 'hello@cloudwash.com',
    address: 'Suite 402, Laundry Lane, Bangalore, KA 560001',
    copyright: '© ${DateTime.now().year} Cloud Wash. Crafted with precision.',
    exploreLinks: const [],
    serviceLinks: const [],
    policyLinks: [
      FooterLinkModel(label: 'Privacy Policy', route: '/privacy'),
      FooterLinkModel(label: 'Terms of Service', route: '/terms'),
      FooterLinkModel(label: 'Child Protection', route: '/child-protection'),
      FooterLinkModel(label: 'Sitemap', route: '/'),
    ],
    socialLinks: const {'facebook': '', 'instagram': '', 'email': '', 'mail': ''},
  );
}

bool _hasCoreFooterContent(FooterModel? footer) {
  if (footer == null) return false;

  bool hasLinks(List<FooterLinkModel> links) {
    return links.any(
      (link) =>
          link.label.trim().isNotEmpty || link.route.trim().isNotEmpty,
    );
  }

  final hasSocial = footer.socialLinks.values.any(
    (value) => value.trim().isNotEmpty,
  );

  return footer.description.trim().isNotEmpty ||
      footer.phone.trim().isNotEmpty ||
      footer.email.trim().isNotEmpty ||
      footer.address.trim().isNotEmpty ||
      footer.copyright.trim().isNotEmpty ||
      hasLinks(footer.exploreLinks) ||
      hasLinks(footer.serviceLinks) ||
      hasLinks(footer.policyLinks) ||
      hasSocial;
}

FooterModel _resolveFooterModel({
  FooterModel? apiFooter,
  FooterModel? firestoreFooter,
}) {
  if (_hasCoreFooterContent(apiFooter)) return apiFooter!;
  if (_hasCoreFooterContent(firestoreFooter)) return firestoreFooter!;
  return _defaultFooter();
}

AboutUsModel? _mergeAboutUsModels({
  Map<String, dynamic>? apiAbout,
  AboutUsModel? firestoreAbout,
}) {
  final apiModel = apiAbout == null ? null : AboutUsModel.fromJson(apiAbout);

  bool hasCoreAboutUsContent(AboutUsModel? aboutUs) {
    if (aboutUs == null) return false;
    return aboutUs.title.trim().isNotEmpty ||
        aboutUs.subtitle.trim().isNotEmpty ||
        aboutUs.description.trim().isNotEmpty ||
        aboutUs.experienceYears > 0 ||
        aboutUs.imageUrl.trim().isNotEmpty ||
        aboutUs.points.isNotEmpty;
  }

  final base = hasCoreAboutUsContent(apiModel)
      ? apiModel
      : (hasCoreAboutUsContent(firestoreAbout) ? firestoreAbout : null);
  if (base == null) return null;

  String resolveString(List<String?> values, String fallback) {
    for (final value in values) {
      final normalized = (value ?? '').trim();
      if (normalized.isNotEmpty) return normalized;
    }
    return fallback;
  }

  final resolvedPoints = <String>[
    ...(apiModel?.points ?? const <String>[]),
    ...(firestoreAbout?.points ?? const <String>[]),
    ...base.points,
  ].map((point) => point.trim()).where((point) => point.isNotEmpty).toSet().toList();

  final resolvedExperienceYears =
      apiModel?.experienceYears ?? firestoreAbout?.experienceYears ?? base.experienceYears;

  return AboutUsModel(
    id: (apiAbout?['_id'] ?? firestoreAbout?.id ?? base.id).toString(),
    title: resolveString(
      [apiAbout?['title']?.toString(), firestoreAbout?.title, base.title],
      'About Cloud Wash',
    ),
    subtitle: resolveString(
      [apiAbout?['subtitle']?.toString(), firestoreAbout?.subtitle, base.subtitle],
      '',
    ),
    description: resolveString(
      [
        apiAbout?['description']?.toString(),
        firestoreAbout?.description,
        base.description,
      ],
      '',
    ),
    experienceYears: resolvedExperienceYears,
    imageUrl: resolveString(
      [apiAbout?['imageUrl']?.toString(), firestoreAbout?.imageUrl, base.imageUrl],
      '',
    ),
    points: resolvedPoints,
    isActive: apiModel?.isActive ?? firestoreAbout?.isActive ?? base.isActive,
  );
}

StaticPageModel? _mergeStaticPageModels({
  Map<String, dynamic>? apiPage,
  StaticPageModel? firestorePage,
}) {
  final apiModel = apiPage == null ? null : StaticPageModel.fromJson(apiPage);

  bool hasCorePageContent(StaticPageModel? page) {
    if (page == null) return false;
    return page.title.trim().isNotEmpty ||
        page.subtitle.trim().isNotEmpty ||
        page.body.trim().isNotEmpty ||
        page.imageUrl.trim().isNotEmpty;
  }

  final apiUpdated = apiModel?.updatedAt?.millisecondsSinceEpoch ?? 0;
  final firestoreUpdated = firestorePage?.updatedAt?.millisecondsSinceEpoch ?? 0;
  final base = (hasCorePageContent(apiModel) && apiUpdated >= firestoreUpdated)
      ? apiModel
      : (hasCorePageContent(firestorePage) ? firestorePage : apiModel);
  if (base == null) return null;

  final secondary = identical(base, apiModel) ? firestorePage : apiModel;

  String resolveString(List<String?> values, String fallback) {
    for (final value in values) {
      final normalized = (value ?? '').trim();
      if (normalized.isNotEmpty) return normalized;
    }
    return fallback;
  }

  return StaticPageModel(
    id: (apiPage?['_id'] ?? firestorePage?.id ?? base.id).toString(),
    slug: resolveString(
      [base.slug, secondary?.slug, apiPage?['slug']?.toString(), firestorePage?.slug],
      base.slug,
    ),
    title: resolveString(
      [base.title, secondary?.title, apiPage?['title']?.toString(), firestorePage?.title],
      base.title,
    ),
    subtitle: resolveString(
      [base.subtitle, secondary?.subtitle, apiPage?['subtitle']?.toString(), firestorePage?.subtitle],
      base.subtitle,
    ),
    body: resolveString(
      [base.body, secondary?.body, apiPage?['body']?.toString(), firestorePage?.body],
      base.body,
    ),
    imageUrl: resolveString(
      [base.imageUrl, secondary?.imageUrl, apiPage?['imageUrl']?.toString(), firestorePage?.imageUrl],
      base.imageUrl,
    ),
    isActive: base.isActive,
    updatedAt: base.updatedAt ?? secondary?.updatedAt ?? apiModel?.updatedAt ?? firestorePage?.updatedAt,
  );
}

String _footerSignature(FooterModel footer) {
  return _stableJsonSignature({
    'description': footer.description,
    'phone': footer.phone,
    'email': footer.email,
    'address': footer.address,
    'copyright': footer.copyright,
    'exploreLinks': footer.exploreLinks
        .map((link) => link.toJson())
        .toList(growable: false),
    'serviceLinks': footer.serviceLinks
        .map((link) => link.toJson())
        .toList(growable: false),
    'policyLinks': footer.policyLinks
        .map((link) => link.toJson())
        .toList(growable: false),
    'socialLinks': footer.socialLinks,
  });
}

String _staticPageSignature(StaticPageModel? page) {
  return _stableJsonSignature(page?.toJson());
}

Future<FooterModel> _loadFooterModel({
  required HomeRepository apiRepository,
  required FirebaseHomeRepository firebaseRepository,
}) async {
  FooterModel? apiFooter;
  FooterModel? firestoreFooter;

  try {
    apiFooter = await apiRepository.getFooter();
  } catch (_) {}

  try {
    firestoreFooter = await firebaseRepository.getFooter();
  } catch (_) {}

  return _resolveFooterModel(
    apiFooter: apiFooter,
    firestoreFooter: firestoreFooter,
  );
}

String _whyChooseUsSignature(List<WhyChooseUsModel> items) {
  return _stableJsonSignature(
    items
        .map(
          (item) => {
            'id': item.id,
            'title': item.title,
            'description': item.description,
            'iconUrl': item.iconUrl,
            'isActive': item.isActive,
          },
        )
        .toList(growable: false),
  );
}

Future<List<WhyChooseUsModel>> _loadWhyChooseUsItems({
  required HomeRepository apiRepository,
  required FirebaseHomeRepository firebaseRepository,
}) async {
  try {
    final apiItems = await apiRepository.getWhyChooseUs();
    if (apiItems.isNotEmpty) {
      final activeApiItems =
          apiItems.where((item) => item.isActive).toList(growable: false);
      return activeApiItems;
    }
  } catch (_) {}

  try {
    final firestoreItems = await firebaseRepository.getWhyChooseUs();
    if (firestoreItems.isNotEmpty) {
      final activeFirestoreItems = firestoreItems
          .where((item) => item.isActive)
          .toList(growable: false);
      return activeFirestoreItems;
    }
  } catch (_) {}

  return _defaultWhyChooseUsItems();
}

final staticPageProvider = StreamProvider.autoDispose.family<StaticPageModel?, String>(
  (ref, slug) async* {
    final apiRepository = ref.watch(homeRepositoryProvider);
    final firebaseRepository = ref.watch(firebaseHomeRepositoryProvider);
    String? lastSignature;
    var isFirstEmission = true;

    while (true) {
      final apiPage = await apiRepository.getStaticPage(slug);
      StaticPageModel? firestorePage;

      try {
        firestorePage = await firebaseRepository.getStaticPage(slug);
      } catch (_) {}

      final data = _mergeStaticPageModels(
        apiPage: apiPage,
        firestorePage: firestorePage,
      );
      final resolvedData = data != null && data.isActive ? data : null;
      final signature = _staticPageSignature(resolvedData);
      if (isFirstEmission || signature != lastSignature) {
        lastSignature = signature;
        isFirstEmission = false;
        yield resolvedData;
      }

      await Future<void>.delayed(const Duration(seconds: 5));
    }
  },
);

@riverpod
Future<AboutUsModel?> aboutUs(AboutUsRef ref) {
  return _loadAboutUsModel(
    apiRepository: ref.watch(homeRepositoryProvider),
    firebaseRepository: ref.watch(firebaseHomeRepositoryProvider),
  );
}

Future<AboutUsModel?> _loadAboutUsModel({
  required HomeRepository apiRepository,
  required FirebaseHomeRepository firebaseRepository,
}) async {
  Map<String, dynamic>? apiAbout;
  AboutUsModel? firestoreAbout;

  try {
    apiAbout = await apiRepository.getAboutUs();
  } catch (_) {}

  try {
    firestoreAbout = await firebaseRepository.getAboutUs();
  } catch (_) {}

  return _mergeAboutUsModels(
    apiAbout: apiAbout,
    firestoreAbout: firestoreAbout,
  );
}

String _statsSignature(StatsModel? stats) {
  return _stableJsonSignature(stats?.toJson());
}

Future<StatsModel?> _loadStatsModel({
  required HomeRepository apiRepository,
  required FirebaseHomeRepository firebaseRepository,
}) async {
  StatsModel? apiStats;
  StatsModel? firestoreStats;

  try {
    final apiStatsJson = await apiRepository.getStats();
    if (apiStatsJson != null) {
      apiStats = StatsModel.fromJson(apiStatsJson);
    }
  } catch (_) {}

  try {
    firestoreStats = await firebaseRepository.getStats();
  } catch (_) {}

  if (apiStats != null && apiStats.happyClients.trim().isNotEmpty) {
    return apiStats;
  }
  if (firestoreStats != null &&
      firestoreStats.happyClients.trim().isNotEmpty) {
    return firestoreStats;
  }
  return apiStats ?? firestoreStats;
}

@riverpod
Future<StatsModel?> stats(StatsRef ref) async {
  return _loadStatsModel(
    apiRepository: ref.watch(homeRepositoryProvider),
    firebaseRepository: ref.watch(firebaseHomeRepositoryProvider),
  );
}

@riverpod
Future<List<TestimonialModel>> testimonials(TestimonialsRef ref) {
  return ref.watch(firebaseHomeRepositoryProvider).getTestimonials();
}

@riverpod
Future<List<WhyChooseUsModel>> whyChooseUs(WhyChooseUsRef ref) async {
  return _loadWhyChooseUsItems(
    apiRepository: ref.watch(homeRepositoryProvider),
    firebaseRepository: ref.watch(firebaseHomeRepositoryProvider),
  );
}

final liveStatsProvider = StreamProvider.autoDispose<StatsModel?>((ref) async* {
  final apiRepository = ref.watch(homeRepositoryProvider);
  final firebaseRepository = ref.watch(firebaseHomeRepositoryProvider);
  String? lastSignature;

  while (true) {
    final data = await _loadStatsModel(
      apiRepository: apiRepository,
      firebaseRepository: firebaseRepository,
    );
    final signature = _statsSignature(data);
    if (signature != lastSignature) {
      lastSignature = signature;
      yield data;
    }
    await Future<void>.delayed(const Duration(seconds: 5));
  }
});

final liveWhyChooseUsProvider =
    StreamProvider.autoDispose<List<WhyChooseUsModel>>(
  (ref) async* {
    final apiRepository = ref.watch(homeRepositoryProvider);
    final firebaseRepository = ref.watch(firebaseHomeRepositoryProvider);
    String? lastSignature;

    while (true) {
      final data = await _loadWhyChooseUsItems(
        apiRepository: apiRepository,
        firebaseRepository: firebaseRepository,
      );
      final signature = _whyChooseUsSignature(data);
      if (signature != lastSignature) {
        lastSignature = signature;
        yield data;
      }
      await Future<void>.delayed(const Duration(seconds: 5));
    }
  },
);

final liveFooterProvider = StreamProvider.autoDispose<FooterModel>(
  (ref) async* {
    final apiRepository = ref.watch(homeRepositoryProvider);
    final firebaseRepository = ref.watch(firebaseHomeRepositoryProvider);
    final resolvedInitialFooter = await _loadFooterModel(
      apiRepository: apiRepository,
      firebaseRepository: firebaseRepository,
    );
    yield resolvedInitialFooter;

    String? lastSignature = _footerSignature(resolvedInitialFooter);

    while (true) {
      final footer = await _loadFooterModel(
        apiRepository: apiRepository,
        firebaseRepository: firebaseRepository,
      );
      final signature = _footerSignature(footer);
      if (signature != lastSignature) {
        lastSignature = signature;
        yield footer;
      }
      await Future<void>.delayed(const Duration(seconds: 5));
    }
  },
);

final footerProvider = FutureProvider<FooterModel?>(
  (ref) async {
    final firebaseRepository = ref.watch(firebaseHomeRepositoryProvider);
    final apiRepository = ref.watch(homeRepositoryProvider);
    return _loadFooterModel(
      apiRepository: apiRepository,
      firebaseRepository: firebaseRepository,
    );
  },
);

final liveTestimonialsProvider =
    StreamProvider.autoDispose<List<TestimonialModel>>(
  (ref) => ref.watch(firebaseHomeRepositoryProvider).watchTestimonials(),
);
