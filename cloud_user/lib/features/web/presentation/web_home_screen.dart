// ============================================================================
// ENHANCED WEB HOME SCREEN - Beautiful Modern UI with Original Data Handling
// ============================================================================

import 'package:cloud_user/core/models/banner_model.dart';
import 'package:cloud_user/core/models/category_model.dart';
import 'package:cloud_user/core/models/service_model.dart';

import 'package:cloud_user/features/home/data/home_providers.dart';
import 'package:cloud_user/features/home/data/hero_section_model.dart';
import 'package:cloud_user/features/home/data/about_us_model.dart';
import 'package:cloud_user/features/home/data/stats_model.dart';
import 'package:cloud_user/features/home/data/testimonial_model.dart';
import 'package:cloud_user/features/home/data/why_choose_us_model.dart';
import 'package:cloud_user/features/home/data/web_content_providers.dart';
import 'package:cloud_user/features/web/presentation/web_layout.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

class WebHomeScreen extends ConsumerStatefulWidget {
  const WebHomeScreen({super.key});

  @override
  ConsumerState<WebHomeScreen> createState() => _WebHomeScreenState();
}

class _WebHomeScreenState extends ConsumerState<WebHomeScreen> {
  IconData _getCategoryIcon(String name) {
    switch (name.toLowerCase()) {
      case 'laundry':
        return Icons.local_laundry_service;
      case 'dry cleaning':
        return Icons.dry_cleaning;
      case 'shoe cleaning':
        return Icons.sports_handball;
      case 'leather cleaning':
        return Icons.work_outline;
      case 'curtain cleaning':
        return Icons.curtains;
      case 'carpet cleaning':
        return Icons.texture;
      case 'bag cleaning':
        return Icons.shopping_bag_outlined;
      case 'sofa cleaning':
        return Icons.weekend_outlined;
      case 'blanket cleaning':
        return Icons.bed_outlined;
      case 'iron only':
        return Icons.iron_outlined;
      default:
        return Icons.local_laundry_service;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final heroAsync = ref.watch(heroSectionProvider);
    final bannersAsync = ref.watch(homeBannersProvider);
    final spotlightAsync = ref.watch(spotlightServicesProvider);
    final topServicesAsync = ref.watch(topServicesProvider);
    final aboutUsAsync = ref.watch(aboutUsProvider);
    final statsAsync = ref.watch(statsProvider);
    final testimonialsAsync = ref.watch(testimonialsProvider);
    final whyChooseUsAsync = ref.watch(whyChooseUsProvider);

    return Stack(
      children: [
        WebLayout(
          child: Column(
            children: [
              _buildHeroSection(context, heroAsync),
              _buildCategoriesSection(context, categoriesAsync),
              _buildOffersSection(context, bannersAsync),
              _buildSpotlightSection(context, spotlightAsync),
              _buildMostBookedSection(context, topServicesAsync),
              _buildAboutUsSection(context, aboutUsAsync),
              _buildWhyChooseUsSection(context, whyChooseUsAsync),
              _buildTestimonialsSection(context, testimonialsAsync),
              _buildStatsAndDownloadSection(context, statsAsync),
            ],
          ),
        ),
        Positioned(
          bottom: 30,
          right: 30,
          child: _buildFloatingWhatsAppButton(),
        ),
      ],
    );
  }

  void _showVideoPopup(BuildContext context, String? url) {
    if (url == null || url.isEmpty) return;
    final videoId = YoutubePlayerController.convertUrlToId(url);
    if (videoId == null) return;

    final controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: YoutubePlayer(controller: controller, aspectRatio: 16 / 9),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(
    BuildContext context,
    AsyncValue<HeroSectionModel?> heroAsync,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 1000;

    return Container(
      constraints: BoxConstraints(minHeight: isMobile ? 700 : 800),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8FAFF), Colors.white, Color(0xFFF0F9FF)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: _AnimatedOrb(
              size: isMobile ? 200 : 350,
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: _AnimatedOrb(
              size: isMobile ? 150 : 280,
              colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
              delay: 2,
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 60,
                  vertical: isMobile ? 40 : 80,
                ),
                child: heroAsync.when(
                  data: (hero) {
                    final tagline = hero?.tagline ?? '✨ We Are Clino';
                    final title =
                        hero?.mainTitle ?? 'Feel Your Way For\nFreshness';
                    final desc =
                        hero?.description ??
                        'Experience the epitome of cleanliness with Clino...';
                    final btnText = hero?.buttonText ?? 'Our Services';
                    final imageUrl =
                        hero?.imageUrl ??
                        'https://res.cloudinary.com/dssmutzly/image/upload/v1766830730/4d01db37af62132b8e554cfabce7767a_z7ioie.png';

                    return isMobile
                        ? Column(
                            children: [
                              _buildHeroContent(
                                context,
                                isMobile,
                                tagline,
                                title,
                                desc,
                                btnText,
                                hero,
                              ),
                              const SizedBox(height: 50),
                              _buildHeroImage(context, isMobile, imageUrl),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 5,
                                child: _buildHeroContent(
                                  context,
                                  isMobile,
                                  tagline,
                                  title,
                                  desc,
                                  btnText,
                                  hero,
                                ),
                              ),
                              const SizedBox(width: 80),
                              Expanded(
                                flex: 4,
                                child: _buildHeroImage(
                                  context,
                                  isMobile,
                                  imageUrl,
                                ),
                              ),
                            ],
                          );
                  },
                  loading: () => const SizedBox(
                    height: 600,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => const SizedBox(
                    height: 600,
                    child: Center(child: Text('Failed to load hero section')),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroContent(
    BuildContext context,
    bool isMobile,
    String tagline,
    String title,
    String desc,
    String btnText,
    HeroSectionModel? hero,
  ) {
    return Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6366F1).withOpacity(0.1),
                Color(0xFF8B5CF6).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Color(0xFF6366F1).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Color(0xFF6366F1),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                tagline,
                style: GoogleFonts.inter(
                  color: Color(0xFF6366F1),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 24 : 32),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Color(0xFF1E293B), Color(0xFF475569)],
          ).createShader(bounds),
          child: Text(
            title.replaceAll('\\n', '\n'),
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: GoogleFonts.playfairDisplay(
              fontSize: isMobile ? 42 : 64,
              fontWeight: FontWeight.w900,
              height: 1.1,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ),
        SizedBox(height: isMobile ? 20 : 28),
        Text(
          desc,
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.inter(
            fontSize: isMobile ? 16 : 18,
            color: Color(0xFF64748B),
            height: 1.7,
          ),
        ),
        SizedBox(height: isMobile ? 32 : 40),
        Row(
          mainAxisAlignment: isMobile
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF6366F1).withOpacity(0.4),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => context.push('/services'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 28 : 36,
                    vertical: isMobile ? 18 : 22,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      btnText,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: isMobile ? 15 : 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            _PulseButton(
              onTap: () => _showVideoPopup(context, hero?.youtubeUrl),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 40 : 50),
        Row(
          mainAxisAlignment: isMobile
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              height: 45,
              child: Stack(
                children: List.generate(
                  4,
                  (i) => Positioned(
                    left: i * 25.0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: [
                          Color(0xFF6366F1),
                          Color(0xFF8B5CF6),
                          Color(0xFF14B8A6),
                          Color(0xFFF59E0B),
                        ][i],
                        child: Text(
                          ['👤', '👨', '👩', '🧑'][i],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '50,000+ Happy Customers',
                  style: GoogleFonts.inter(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (i) => Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Color(0xFFFBBF24),
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '4.9/5 Rating',
                      style: GoogleFonts.inter(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroImage(BuildContext context, bool isMobile, String imageUrl) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Color(0xFF6366F1).withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF6366F1).withOpacity(0.2),
                blurRadius: 60,
                offset: Offset(0, 30),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: isMobile ? 400 : 550,
              fit: BoxFit.contain,
              placeholder: (_, __) => Container(
                height: isMobile ? 400 : 550,
                decoration: BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                height: isMobile ? 400 : 550,
                decoration: BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Center(
                  child: Icon(
                    Icons.cleaning_services,
                    size: 100,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(
    BuildContext context,
    AsyncValue<List<CategoryModel>> categoriesAsync,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 1000;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 30 : 50,
        horizontal: isMobile ? 24 : 60,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFFAFAFA)],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            children: [
              _SectionHeader(
                subtitle: 'EXPLORE OUR SERVICES',
                title: 'Shop By Category',
                description:
                    'Choose from our comprehensive range of professional cleaning services',
                isMobile: isMobile,
              ),
              SizedBox(height: isMobile ? 40 : 60),
              categoriesAsync.when(
                data: (categories) {
                  if (categories.isEmpty)
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text('No categories available'),
                    );

                  final List<Color> gradients = [
                    [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    [Color(0xFFF59E0B), Color(0xFFEF4444)],
                    [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                    [Color(0xFFEC4899), Color(0xFFF43F5E)],
                    [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    [Color(0xFF06B6D4), Color(0xFF6366F1)],
                  ].expand((x) => x).toList();

                  if (isMobile) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return _EnhancedCategoryCard(
                          name: category.name,
                          count: '${index * 50 + 100}+ Items',
                          icon: _getCategoryIcon(category.name),
                          color1: gradients[(index * 2) % gradients.length],
                          color2: gradients[(index * 2 + 1) % gradients.length],
                          imagePath: category.imageUrl,
                          onTap: () => context.push(
                            '/category/${category.id}',
                            extra: category.name,
                          ),
                        );
                      },
                    );
                  } else {
                    return Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      alignment: WrapAlignment.center,
                      children: categories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final category = entry.value;
                        return SizedBox(
                          width: 200,
                          child: _EnhancedCategoryCard(
                            name: category.name,
                            count: '${index * 50 + 100}+ Items',
                            icon: _getCategoryIcon(category.name),
                            color1: gradients[(index * 2) % gradients.length],
                            color2:
                                gradients[(index * 2 + 1) % gradients.length],
                            imagePath: category.imageUrl,
                            onTap: () => context.push(
                              '/category/${category.id}',
                              extra: category.name,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Text('Error loading categories: $error'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOffersSection(
    BuildContext context,
    AsyncValue<List<BannerModel>> bannersAsync,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 1000;

    return bannersAsync.when(
      data: (banners) {
        if (banners.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 30 : 50,
            horizontal: isMobile ? 24 : 60,
          ),
          color: Colors.white,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                children: [
                  _SectionHeader(
                    subtitle: 'EXCLUSIVE DEALS',
                    title: 'Special Offers',
                    description: 'Save big with our limited-time promotions',
                    isMobile: isMobile,
                  ),
                  SizedBox(height: isMobile ? 40 : 60),
                  _OffersCarousel(banners: banners, isMobile: isMobile),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildSpotlightSection(
    BuildContext context,
    AsyncValue<List<ServiceModel>> spotlightAsync,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 1000;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 30 : 50,
        horizontal: isMobile ? 24 : 60,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFAFAFA), Colors.white],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            children: [
              _SectionHeader(
                subtitle: 'FEATURED SERVICES',
                title: 'In the Spotlight',
                description: 'Discover our most popular and trending services',
                isMobile: isMobile,
              ),
              const SizedBox(height: 50),
              spotlightAsync.when(
                data: (services) {
                  if (services.isEmpty)
                    return const Center(
                      child: Text('No spotlight services available'),
                    );

                  final List<List<Color>> gradients = [
                    [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    [Color(0xFFF59E0B), Color(0xFFEF4444)],
                    [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                    [Color(0xFFEC4899), Color(0xFFF43F5E)],
                  ];

                  if (isMobile) {
                    return SizedBox(
                      height: 280,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: services.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 20),
                        itemBuilder: (context, index) {
                          final service = services[index];
                          return SizedBox(
                            width: 240,
                            child: _EnhancedSpotlightCard(
                              title: service.title,
                              subtitle: service.description ?? '',
                              color1: gradients[index % gradients.length][0],
                              color2: gradients[index % gradients.length][1],
                              imageUrl: service.image ?? '',
                              onTap: () => context.push(
                                '/service-details',
                                extra: service,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        return _EnhancedSpotlightCard(
                          title: service.title,
                          subtitle: service.description ?? '',
                          color1: gradients[index % gradients.length][0],
                          color2: gradients[index % gradients.length][1],
                          imageUrl: service.image ?? '',
                          onTap: () =>
                              context.push('/service-details', extra: service),
                        );
                      },
                    );
                  }
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMostBookedSection(
    BuildContext context,
    AsyncValue<List<ServiceModel>> topServicesAsync,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 1000;

    return topServicesAsync.when(
      data: (services) {
        if (services.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 30 : 50,
            horizontal: isMobile ? 24 : 60,
          ),
          color: Colors.white,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                children: [
                  isMobile
                      ? Column(
                          children: [
                            _buildMostBookedHeader(),
                            const SizedBox(height: 20),
                            _buildMostBookedViewAll(context),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildMostBookedHeader(),
                            _buildMostBookedViewAll(context),
                          ],
                        ),
                  SizedBox(height: isMobile ? 40 : 60),
                  if (isMobile)
                    SizedBox(
                      height: 360,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          final service = services[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: SizedBox(
                              width: 280,
                              child: _EnhancedServiceCard(
                                name: service.title,
                                price: service.price.toString(),
                                rating: 4.8,
                                reviews: '2k+',
                                imageUrl: service.image ?? '',
                                service: service,
                                onTap: () => context.push(
                                  '/service-details',
                                  extra: service,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: math.min(services.length, 8),
                      itemBuilder: (context, index) {
                        final service = services[index];
                        return _EnhancedServiceCard(
                          name: service.title,
                          price: service.price.toString(),
                          rating: 4.8,
                          reviews: '2k+',
                          imageUrl: service.image ?? '',
                          service: service,
                          onTap: () =>
                              context.push('/service-details', extra: service),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildMostBookedHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CUSTOMER FAVORITES',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6366F1),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Most Booked Services',
          style: GoogleFonts.playfairDisplay(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildMostBookedViewAll(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: TextButton.icon(
        onPressed: () => context.push('/services'),
        icon: Text(
          'Explore All Services',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        label: Icon(Icons.arrow_forward, size: 18, color: Colors.white),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildAboutUsSection(
    BuildContext context,
    AsyncValue<AboutUsModel?> aboutUsAsync,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 1000;

    return aboutUsAsync.when(
      data: (aboutUs) => Container(
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 30 : 50,
          horizontal: isMobile ? 24 : 60,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFAFAFA), Colors.white],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: isMobile
                ? Column(
                    children: [
                      _buildAboutUsContent(context, isMobile, aboutUs: aboutUs),
                      const SizedBox(height: 60),
                      _buildAboutUsImages(isMobile),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 5, child: _buildAboutUsImages(isMobile)),
                      const SizedBox(width: 100),
                      Expanded(
                        flex: 5,
                        child: _buildAboutUsContent(
                          context,
                          isMobile,
                          aboutUs: aboutUs,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  Widget _buildAboutUsImages(bool isMobile) {
    return SizedBox(
      height: isMobile ? 450 : 600,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: isMobile ? 320 : 480,
              height: isMobile ? 320 : 480,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFF6366F1).withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: isMobile ? 0 : 40,
            child: _StyledImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1517677208171-0bc6725a3e60?q=80&w=500&auto=format&fit=crop',
              width: isMobile ? 200 : 340,
              height: isMobile ? 240 : 400,
            ),
          ),
          Positioned(
            bottom: isMobile ? 20 : 40,
            left: isMobile ? 0 : 40,
            child: _StyledImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1582735689369-4fe89db7114c?q=80&w=500&auto=format&fit=crop',
              width: isMobile ? 200 : 320,
              height: isMobile ? 240 : 380,
            ),
          ),
          if (!isMobile)
            Positioned(bottom: 0, left: 300, child: _FloatingStatsCard()),
        ],
      ),
    );
  }

  Widget _buildAboutUsContent(
    BuildContext context,
    bool isMobile, {
    AboutUsModel? aboutUs,
  }) {
    return Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFF59E0B).withOpacity(0.3),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            'ABOUT US',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          aboutUs?.title ?? 'Your Trusted Partner in\nLaundry Care.',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.playfairDisplay(
            fontSize: isMobile ? 36 : 54,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          aboutUs?.description ??
              'We provide professional laundry and dry cleaning services with a focus on quality, convenience, and care.',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.inter(
            fontSize: 17,
            color: Color(0xFF64748B),
            height: 1.7,
          ),
        ),
        const SizedBox(height: 40),
        if (aboutUs != null && aboutUs.points.isNotEmpty)
          ...aboutUs.points
              .map(
                (point) => Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: _EnhancedFeatureItem(title: point),
                ),
              )
              .toList()
        else ...[
          const _EnhancedFeatureItem(title: 'Passionate Expertise'),
          const SizedBox(height: 24),
          const _EnhancedFeatureItem(title: 'Cutting-Edge Technology'),
          const SizedBox(height: 24),
          const _EnhancedFeatureItem(title: 'Customer-Centric Approach'),
        ],
      ],
    );
  }

  Widget _buildWhyChooseUsSection(
    BuildContext context,
    AsyncValue<List<WhyChooseUsModel>> whyChooseUsAsync,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 1000;

    return whyChooseUsAsync.when(
      data: (items) {
        return Container(
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 30 : 50,
            horizontal: isMobile ? 24 : 60,
          ),
          color: Colors.white,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                children: [
                  _SectionHeader(
                    subtitle: 'OUR COMMITMENT',
                    title: 'Why Choose Us',
                    description:
                        'We provide the highest standards of care for your beloved garments',
                    isMobile: isMobile,
                  ),
                  SizedBox(height: isMobile ? 40 : 60),
                  if (isMobile)
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                      children: items
                          .map(
                            (item) => _EnhancedWhyChooseCard(
                              icon: _getIconData(item.iconUrl),
                              title: item.title,
                              subtitle: item.description,
                              color: _getWhyChooseColor(item.title),
                            ),
                          )
                          .toList(),
                    )
                  else
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 0.9,
                      children: items
                          .map(
                            (item) => _EnhancedWhyChooseCard(
                              icon: _getIconData(item.iconUrl),
                              title: item.title,
                              subtitle: item.description,
                              color: _getWhyChooseColor(item.title),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'verified_user_rounded':
        return Icons.verified_user_rounded;
      case 'timer_rounded':
        return Icons.timer_rounded;
      case 'eco_rounded':
        return Icons.eco_rounded;
      case 'payments_rounded':
        return Icons.payments_rounded;
      case 'local_shipping_rounded':
        return Icons.local_shipping_rounded;
      case 'support_agent_rounded':
        return Icons.support_agent_rounded;
      case 'shopping_basket_rounded':
        return Icons.shopping_basket_rounded;
      case 'star_rounded':
        return Icons.star_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  Color _getWhyChooseColor(String title) {
    final t = title.toLowerCase();
    if (t.contains('quality')) return Color(0xFF6366F1);
    if (t.contains('time') || t.contains('delivery')) return Color(0xFFEC4899);
    if (t.contains('eco') || t.contains('friendly')) return Color(0xFF14B8A6);
    if (t.contains('price') || t.contains('fair')) return Color(0xFFF59E0B);
    return Color(0xFF6366F1);
  }

  Widget _buildTestimonialsSection(
    BuildContext context,
    AsyncValue<List<TestimonialModel>> testimonialsAsync,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 1000;

    return testimonialsAsync.when(
      data: (items) {
        return Container(
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 30 : 50,
            horizontal: isMobile ? 24 : 60,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFAFAFA), Colors.white],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                children: [
                  _SectionHeader(
                    subtitle: 'REVIEWS',
                    title: 'What Our Customers Say',
                    description: 'Real feedback from our satisfied clients',
                    isMobile: isMobile,
                  ),
                  SizedBox(height: isMobile ? 40 : 60),
                  if (isMobile)
                    SizedBox(
                      height: 160,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: items
                            .map(
                              (t) => _buildTestimonialCard(
                                t.name,
                                t.role,
                                t.rating.toInt(),
                                t.message,
                                t.imageUrl,
                              ),
                            )
                            .toList(),
                      ),
                    )
                  else
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 1.2,
                      children: items
                          .take(3)
                          .map(
                            (t) => _buildTestimonialCard(
                              t.name,
                              t.role,
                              t.rating.toInt(),
                              t.message,
                              t.imageUrl,
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  Widget _buildTestimonialCard(
    String name,
    String location,
    int rating,
    String text,
    String avatarUrl,
  ) {
    return Container(
      width: 380,
      margin: const EdgeInsets.only(right: 20),
      child: _EnhancedTestimonialCard(
        name: name,
        location: location,
        rating: rating,
        text: text,
        avatarUrl: avatarUrl,
      ),
    );
  }

  Widget _buildStatsAndDownloadSection(
    BuildContext context,
    AsyncValue<StatsModel?> statsAsync,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 1000;

    return statsAsync.when(
      data: (statsData) {
        final statsItems = [
          {
            'value': statsData?.happyClients ?? '50K+',
            'label': 'Happy Customers',
            'icon': Icons.people_alt_rounded,
            'color': Color(0xFF6366F1),
          },
          {
            'value': statsData?.totalBranches ?? '1000+',
            'label': 'Verified Pros',
            'icon': Icons.verified_user_rounded,
            'color': Color(0xFF14B8A6),
          },
          {
            'value': statsData?.totalCities ?? '20+',
            'label': 'Cities Presence',
            'icon': Icons.location_on_rounded,
            'color': Color(0xFFF59E0B),
          },
          {
            'value': statsData?.totalOrders ?? '100K+',
            'label': 'Total Orders',
            'icon': Icons.shopping_basket_rounded,
            'color': Color(0xFFEC4899),
          },
        ];

        return Container(
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 30 : 50,
            horizontal: isMobile ? 24 : 60,
          ),
          color: Colors.white,
          child: Column(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: isMobile
                      ? GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 30,
                          crossAxisSpacing: 20,
                          children: statsItems
                              .map((s) => _buildStatItem(s, isMobile))
                              .toList(),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: statsItems
                              .map((s) => _buildStatItem(s, isMobile))
                              .toList(),
                        ),
                ),
              ),
              SizedBox(height: isMobile ? 80 : 120),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: isMobile
                      ? Column(
                          children: [
                            _buildDownloadContent(isMobile),
                            const SizedBox(height: 60),
                            _buildDownloadAppMockup(isMobile),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: _buildDownloadContent(isMobile)),
                            const SizedBox(width: 100),
                            _buildDownloadAppMockup(isMobile),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatItem(Map<String, dynamic> s, bool isMobile) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                s['color'] as Color,
                (s['color'] as Color).withOpacity(0.7),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (s['color'] as Color).withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            s['icon'] as IconData,
            color: Colors.white,
            size: isMobile ? 28 : 36,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 24),
        _AnimatedCounter(
          value: s['value'] as String,
          style: GoogleFonts.inter(
            fontSize: isMobile ? 32 : 56,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          s['label'] as String,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: isMobile ? 14 : 16,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadContent(bool isMobile) {
    return Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            'DOWNLOAD THE APP',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Your Personal Laundry\nManager in Your Pocket',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.playfairDisplay(
            fontSize: isMobile ? 36 : 52,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Book, track, and manage your laundry needs with a single tap. Join 50,000+ happy users today.',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.inter(
            fontSize: isMobile ? 16 : 18,
            color: Color(0xFF64748B),
            height: 1.7,
          ),
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 15,
          runSpacing: 15,
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          children: [
            _AppStoreBadge(
              icon: Icons.apple,
              text: 'App Store',
              subtext: 'Download on the',
              onTap: () {},
            ),
            _AppStoreBadge(
              icon: Icons.play_arrow_rounded,
              text: 'Google Play',
              subtext: 'Get it on',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDownloadAppMockup(bool isMobile) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: isMobile ? 300 : 420,
          height: isMobile ? 300 : 420,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Color(0xFF6366F1).withOpacity(0.1), Colors.transparent],
            ),
          ),
        ),
        Container(
          width: isMobile ? 240 : 320,
          height: isMobile ? 480 : 640,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(isMobile ? 36 : 48),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 40,
                offset: Offset(0, 20),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isMobile ? 24 : 36),
            child: CachedNetworkImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?q=80&w=800&auto=format&fit=crop',
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Center(child: CircularProgressIndicator()),
              errorWidget: (_, __, ___) =>
                  Icon(Icons.image, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingWhatsAppButton() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF25D366), Color(0xFF128C7E)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0xFF25D366).withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Icon(Icons.chat, color: Colors.white, size: 28),
    );
  }
}

// ============================================================================
// ENHANCED HELPER WIDGETS
// ============================================================================

class _SectionHeader extends StatelessWidget {
  final String subtitle;
  final String title;
  final String description;
  final bool isMobile;

  const _SectionHeader({
    required this.subtitle,
    required this.title,
    required this.description,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6366F1).withOpacity(0.1),
                Color(0xFF8B5CF6).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Color(0xFF6366F1).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Text(
            subtitle,
            style: GoogleFonts.inter(
              color: Color(0xFF6366F1),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: isMobile ? 36 : 52,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: isMobile ? 15 : 17,
            color: Color(0xFF64748B),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _AnimatedOrb extends StatefulWidget {
  final double size;
  final List<Color> colors;
  final double delay;

  const _AnimatedOrb({
    required this.size,
    required this.colors,
    this.delay = 0,
  });

  @override
  State<_AnimatedOrb> createState() => _AnimatedOrbState();
}

class _AnimatedOrbState extends State<_AnimatedOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              ...widget.colors.map(
                (c) => c.withOpacity(0.15 + _controller.value * 0.05),
              ),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseButton extends StatefulWidget {
  final VoidCallback onTap;

  const _PulseButton({required this.onTap});

  @override
  State<_PulseButton> createState() => _PulseButtonState();
}

class _PulseButtonState extends State<_PulseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Container(
              width: 64 + (_controller.value * 20),
              height: 64 + (_controller.value * 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(
                  0xFF6366F1,
                ).withOpacity(0.3 - _controller.value * 0.3),
              ),
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: Color(0xFF6366F1),
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class _EnhancedCategoryCard extends StatefulWidget {
  final String name;
  final String count;
  final IconData icon;
  final Color color1;
  final Color color2;
  final String? imagePath;
  final VoidCallback onTap;

  const _EnhancedCategoryCard({
    required this.name,
    required this.count,
    required this.icon,
    required this.color1,
    required this.color2,
    this.imagePath,
    required this.onTap,
  });

  @override
  State<_EnhancedCategoryCard> createState() => _EnhancedCategoryCardState();
}

class _EnhancedCategoryCardState extends State<_EnhancedCategoryCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (mounted) setState(() => isHovered = true);
      },
      onExit: (_) {
        if (mounted) setState(() => isHovered = false);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.translationValues(0, isHovered ? -8 : 0, 0),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isHovered
                  ? [widget.color1, widget.color2]
                  : [Colors.white, Colors.white],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isHovered
                    ? widget.color1.withOpacity(0.4)
                    : Colors.black.withOpacity(0.05),
                blurRadius: isHovered ? 30 : 15,
                offset: Offset(0, isHovered ? 15 : 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.imagePath != null)
                CachedNetworkImage(
                  imageUrl: widget.imagePath!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isHovered ? Colors.white : widget.color1,
                  ),
                  errorWidget: (_, __, ___) => Icon(
                    widget.icon,
                    size: 48,
                    color: isHovered ? Colors.white : widget.color1,
                  ),
                )
              else
                Icon(
                  widget.icon,
                  size: 48,
                  color: isHovered ? Colors.white : widget.color1,
                ),
              const SizedBox(height: 20),
              Text(
                widget.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: isHovered ? Colors.white : Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.count,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isHovered
                      ? Colors.white.withOpacity(0.9)
                      : Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnhancedSpotlightCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color color1;
  final Color color2;
  final String imageUrl;
  final VoidCallback onTap;

  const _EnhancedSpotlightCard({
    required this.title,
    required this.subtitle,
    required this.color1,
    required this.color2,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  State<_EnhancedSpotlightCard> createState() => _EnhancedSpotlightCardState();
}

class _EnhancedSpotlightCardState extends State<_EnhancedSpotlightCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (mounted) setState(() => isHovered = true);
      },
      onExit: (_) {
        if (mounted) setState(() => isHovered = false);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.translationValues(0, isHovered ? -10 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            image: DecorationImage(
              image: CachedNetworkImageProvider(widget.imageUrl),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isHovered ? 0.3 : 0.1),
                blurRadius: isHovered ? 25 : 15,
                offset: Offset(0, isHovered ? 12 : 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                right: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnhancedOfferBanner extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;

  const _EnhancedOfferBanner({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 1000;
    return Container(
      height: isMobile ? 300 : 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isMobile ? 30 : 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'LIMITED TIME OFFER',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: isMobile ? 32 : 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Claim Offer',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnhancedServiceCard extends StatefulWidget {
  final String name;
  final String price;
  final double rating;
  final String reviews;
  final String imageUrl;
  final ServiceModel service;
  final VoidCallback onTap;

  const _EnhancedServiceCard({
    required this.name,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.imageUrl,
    required this.service,
    required this.onTap,
  });

  @override
  State<_EnhancedServiceCard> createState() => _EnhancedServiceCardState();
}

class _EnhancedServiceCardState extends State<_EnhancedServiceCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (mounted) setState(() => isHovered = true);
      },
      onExit: (_) {
        if (mounted) setState(() => isHovered = false);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.translationValues(0, isHovered ? -8 : 0, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isHovered ? 0.1 : 0.05),
                blurRadius: isHovered ? 30 : 15,
                offset: Offset(0, isHovered ? 15 : 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 5),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFBBF24),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.rating}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${widget.price}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: const Color(0xFF6366F1),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isHovered
                                ? const Color(0xFF6366F1)
                                : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            size: 16,
                            color: isHovered
                                ? Colors.white
                                : const Color(0xFF6366F1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnhancedWhyChooseCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _EnhancedWhyChooseCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B), height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _EnhancedTestimonialCard extends StatelessWidget {
  final String name;
  final String location;
  final int rating;
  final String text;
  final String avatarUrl;

  const _EnhancedTestimonialCard({
    required this.name,
    required this.location,
    required this.rating,
    required this.text,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: CachedNetworkImageProvider(avatarUrl),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    location,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < rating
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: const Color(0xFFFBBF24),
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF475569),
                height: 1.6,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnhancedFeatureItem extends StatelessWidget {
  final String title;
  const _EnhancedFeatureItem({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Color(0xFF10B981),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 14, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
      ],
    );
  }
}

class _StyledImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;

  const _StyledImage({
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: Colors.grey.shade100),
          errorWidget: (_, __, ___) => const Icon(Icons.image),
        ),
      ),
    );
  }
}

class _FloatingStatsCard extends StatelessWidget {
  const _FloatingStatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Color(0xFFF59E0B),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '4.9 Rating',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const Text(
                'from 2k+ reviews',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedCounter extends StatefulWidget {
  final String value;
  final TextStyle style;
  const _AnimatedCounter({required this.value, required this.style});

  @override
  State<_AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<_AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _targetValue;
  late String _suffix;
  late String _prefix;
  bool _isDecimal = false;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _parseValue();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0, end: _targetValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );
  }

  void _parseValue() {
    _suffix = '';
    _prefix = '';
    String cleanValue = widget.value;

    // Extract suffix (K, +, etc)
    final suffixRegExp = RegExp(r'[Kk\+]+$');
    final suffixMatch = suffixRegExp.firstMatch(cleanValue);
    if (suffixMatch != null) {
      _suffix = suffixMatch.group(0)!;
      cleanValue = cleanValue.substring(0, cleanValue.length - _suffix.length);
    }

    _isDecimal = cleanValue.contains('.');
    _targetValue = double.tryParse(cleanValue) ?? 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasAnimated) {
      _controller.forward();
      _hasAnimated = true;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        String displayValue;
        if (_isDecimal) {
          displayValue = _animation.value.toStringAsFixed(1);
        } else {
          displayValue = _animation.value.toInt().toString();
        }
        return Text('$_prefix$displayValue$_suffix', style: widget.style);
      },
    );
  }
}

class _AppStoreBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final String subtext;
  final VoidCallback onTap;

  const _AppStoreBadge({
    required this.icon,
    required this.text,
    required this.subtext,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtext,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OffersCarousel extends StatefulWidget {
  final List<BannerModel> banners;
  final bool isMobile;

  const _OffersCarousel({required this.banners, required this.isMobile});

  @override
  State<_OffersCarousel> createState() => _OffersCarouselState();
}

class _OffersCarouselState extends State<_OffersCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      if (_currentPage < widget.banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.isMobile ? 300 : 400,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              final banner =
                  widget.banners[index]; // Note: logic for showing one banner
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _EnhancedOfferBanner(
                  title: banner.title,
                  description: banner.description,
                  imageUrl: banner.imageUrl,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 32 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? const Color(0xFF6366F1)
                    : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
