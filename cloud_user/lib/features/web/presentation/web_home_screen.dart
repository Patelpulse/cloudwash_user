import 'package:cloud_user/core/models/category_model.dart';
import 'package:cloud_user/core/theme/app_theme.dart';
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
import 'package:visibility_detector/visibility_detector.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WebHomeScreen extends ConsumerStatefulWidget {
  const WebHomeScreen({super.key});

  @override
  ConsumerState<WebHomeScreen> createState() => _WebHomeScreenState();
}

class _WebHomeScreenState extends ConsumerState<WebHomeScreen> {
  // Category icon mapping
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

  Color _getCategoryColor(int index) {
    final colors = [
      const Color(0xFFE3F2FD),
      const Color(0xFFFFF3E0),
      const Color(0xFFE8F5E9),
      const Color(0xFFFCE4EC),
      const Color(0xFFE0F7FA),
      const Color(0xFFF3E5F5),
      const Color(0xFFFFF8E1),
      const Color(0xFFE0F2F1),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final heroAsync = ref.watch(heroSectionProvider);
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
              _buildAboutUsSection(context, aboutUsAsync),
              _buildSpotlightSection(context),
              _buildOffersSection(context),
              _buildMostBookedSection(context),
              _buildBlogPreviewSection(context),
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

  // --- Sections ---

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
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1000;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: isMobile ? 20 : 0,
        bottom: isMobile ? 30 : 0,
        left: isMobile ? 20 : 40,
        right: isMobile ? 20 : 40,
      ),
      decoration: const BoxDecoration(color: Colors.white),
      child: Stack(
        children: [
          // Animated Bubble Gradients
          Positioned(
            top: -50,
            left: -50,
            child: _AnimatedBubble(
              size: isMobile ? 120 : 200,
              color: const Color(
                0xFF89CFF0,
              ).withValues(alpha: 0.3), // Soft Blue
              delay: 0,
            ),
          ),
          Positioned(
            top: 100,
            right: 100,
            child: _AnimatedBubble(
              size: isMobile ? 80 : 120,
              color: const Color(
                0xFFB5EAD7,
              ).withValues(alpha: 0.4), // Mint Green
              delay: 1,
            ),
          ),
          // Main Content
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
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
                            const SizedBox(height: 60),
                            _buildHeroImage(context, isMobile, imageUrl),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
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
        // Tagline
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Text(
            tagline,
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Main Title
        Text(
          isMobile
              ? title.replaceAll('\\n', '\n')
              : title.replaceAll('\\n', '\n'),
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.playfairDisplay(
            fontSize: isMobile ? 38 : 52,
            fontWeight: FontWeight.bold,
            height: 1.15,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 20),
        // Description
        Text(
          desc,
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: isMobile ? 15 : 16,
            color: Colors.grey.shade600,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        // Action Buttons
        Row(
          mainAxisAlignment: isMobile
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () => context.push('/services'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A5F),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 28,
                  vertical: isMobile ? 14 : 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    btnText,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 14 : 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => _showVideoPopup(context, hero?.youtubeUrl),
                icon: Icon(Icons.play_arrow, color: Colors.blue.shade700),
                iconSize: 28,
                padding: const EdgeInsets.all(14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        // VIP Clients
        Row(
          mainAxisAlignment: isMobile
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              height: 40,
              child: Stack(
                children: List.generate(
                  4,
                  (i) => Positioned(
                    left: i * 22.0,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: [
                          Colors.blue,
                          Colors.purple,
                          Colors.teal,
                          Colors.orange,
                        ][i],
                        child: Text(
                          ['👤', '👨', '👩', '🧑'][i],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Our VIP Clients',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroImage(BuildContext context, bool isMobile, String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: isMobile ? 350 : 500,
        fit: BoxFit.contain,
        placeholder: (_, __) => Container(
          height: isMobile ? 350 : 500,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (_, __, ___) => Container(
          height: isMobile ? 350 : 500,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Icon(Icons.cleaning_services, size: 100, color: Colors.blue),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(
    BuildContext context,
    AsyncValue<List<CategoryModel>> categoriesAsync,
  ) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1000;

    return Container(
      padding: EdgeInsets.only(
        top: 10,
        bottom: isMobile ? 20 : 30,
        left: isMobile ? 20 : 40,
        right: isMobile ? 20 : 40,
      ),
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'Shop By Category',
                style: TextStyle(
                  fontSize: isMobile ? 26 : 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: isMobile ? 20 : 30),

              // Dynamic categories from database
              categoriesAsync.when(
                data: (categories) {
                  if (categories.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text('No categories available'),
                    );
                  }

                  if (isMobile) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return _CategoryItem(
                          name: category.name,
                          count: '${index * 50 + 100}+ Items',
                          icon: _getCategoryIcon(category.name),
                          iconColor: _getCardColor(index),
                          imagePath: category.imageUrl,
                          onTap: () => context.push(
                            '/category/${category.id}',
                            extra: category.name,
                          ),
                        );
                      },
                    );
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: categories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final category = entry.value;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: _CategoryItem(
                              name: category.name,
                              count: '${index * 50 + 100}+ Items',
                              icon: _getCategoryIcon(category.name),
                              iconColor: _getCardColor(index),
                              imagePath: category.imageUrl,
                              onTap: () => context.push(
                                '/category/${category.id}',
                                extra: category.name,
                              ),
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

  Widget _buildAboutUsSection(
    BuildContext context,
    AsyncValue<AboutUsModel?> aboutUsAsync,
  ) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1000;

    return aboutUsAsync.when(
      data: (aboutUs) => Container(
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 20 : 40,
          horizontal: isMobile ? 20 : 40,
        ),
        color: Colors.white,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
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
                      // Left Side: Image Collage
                      Expanded(flex: 6, child: _buildAboutUsImages(isMobile)),
                      const SizedBox(width: 80),
                      // Right Side: Content
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
      height: isMobile ? 400 : 550,
      child: Stack(
        children: [
          // Background Circle Decoration
          Positioned(
            left: 20,
            top: 20,
            child: Container(
              width: isMobile ? 300 : 450,
              height: isMobile ? 300 : 450,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF1F5F9).withValues(alpha: 0.8),
              ),
            ),
          ),
          // Top Right Image
          Positioned(
            top: 0,
            right: isMobile ? 0 : 40,
            child: _RoundedImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1517677208171-0bc6725a3e60?q=80&w=500&auto=format&fit=crop',
              width: isMobile ? 180 : 320,
              height: isMobile ? 200 : 380,
            ),
          ),
          // Bottom Left Image
          Positioned(
            bottom: isMobile ? 20 : 20,
            left: isMobile ? 0 : 40,
            child: _RoundedImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1582735689369-4fe89db7114c?q=80&w=500&auto=format&fit=crop',
              width: isMobile ? 180 : 300,
              height: isMobile ? 200 : 350,
            ),
          ),
          // Play Video Card
          if (!isMobile)
            Positioned(
              bottom: 0,
              left: 280,
              child: Container(
                padding: const EdgeInsets.all(24),
                width: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFF4AC3F5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4AC3F5).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFB100),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Play Video',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'How we care for your clothes',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFB100),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'ABOUT US',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          aboutUs?.title ?? 'Your Trusted Partner in\nLaundry Care.',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.playfairDisplay(
            fontSize: isMobile ? 32 : 48,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
            height: 1.1,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          aboutUs?.description ??
              'We provide professional laundry and dry cleaning services with a focus on quality, convenience, and care. Our mission is to make your life easier by taking the burden of laundry off your shoulders.',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 40),
        if (aboutUs != null && aboutUs.points.isNotEmpty)
          ...aboutUs.points.map((point) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: _AboutFeatureItem(
                title: point,
                desc:
                    '', // Default description if not provided in simple string list
              ),
            );
          }).toList()
        else ...[
          const _AboutFeatureItem(
            title: 'Passionate Expertise',
            desc:
                'Our team consists of fabric care experts who treat every garment with the respect it deserves.',
          ),
          const SizedBox(height: 24),
          const _AboutFeatureItem(
            title: 'Cutting-Edge Technology',
            desc:
                'We use the latest eco-friendly cleaning technology to ensure the best results for your clothes and the environment.',
          ),
          const SizedBox(height: 24),
          const _AboutFeatureItem(
            title: 'Customer-Centric Approach',
            desc:
                'Everything we do is designed around your convenience, from easy scheduling to friendly service.',
          ),
        ],
      ],
    );
  }

  Widget _buildBlogPreviewSection(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1000;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 30 : 50,
        horizontal: isMobile ? 20 : 40,
      ),
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OUR BLOG',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6366F1),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Latest from Cloud Wash',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: isMobile ? 32 : 48,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  if (!isMobile)
                    TextButton.icon(
                      onPressed: () => context.go('/blog'),
                      icon: const Text(
                        'Visit Blog',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      label: const Icon(Icons.arrow_forward),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 48),
              isMobile
                  ? Column(
                      children: [
                        _blogPreviewCard(
                          'How to Keep Your White Clothes Bright',
                          'Expert tips on maintaining the brightness of your white garments...',
                          'https://images.unsplash.com/photo-1582735689369-4fe89db7114c?w=600',
                        ),
                        const SizedBox(height: 24),
                        _blogPreviewCard(
                          'The Ultimate Guide to Dry Cleaning',
                          'When should you dry clean vs wash?',
                          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600',
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _blogPreviewCard(
                            'How to Keep Your White Clothes Bright',
                            'Expert tips on maintaining the brightness of your white garments...',
                            'https://images.unsplash.com/photo-1582735689369-4fe89db7114c?w=600',
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _blogPreviewCard(
                            'The Ultimate Guide to Dry Cleaning',
                            'When should you dry clean vs wash?',
                            'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600',
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _blogPreviewCard(
                            'Caring for Leather Goods',
                            'Professional tips for maintaining leather...',
                            'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600',
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blogPreviewCard(String title, String snippet, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 200,
                color: Colors.grey.shade100,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (_, __, ___) => const Icon(Icons.image),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text(
                  snippet,
                  style: TextStyle(color: Colors.grey.shade600, height: 1.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                Text(
                  'Read More →',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactFormPreview(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Send us a Message',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 24),
          _fakeTextField('Your Name'),
          const SizedBox(height: 16),
          _fakeTextField('Email Address'),
          const SizedBox(height: 16),
          _fakeTextField('Message', maxLines: 3),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Send Message',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fakeTextField(String hint, {int maxLines = 1}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: maxLines > 1 ? 16 : 0,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildSpotlightSection(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1000;

    final spotlightItems = [
      {
        'title': 'Express Laundry',
        'subtitle': '24 Hour Delivery',
        'color': const Color(0xFFE3F2FD),
        'icon': Icons.local_laundry_service,
        'textColor': const Color(0xFF1565C0),
      },
      {
        'title': 'Premium Dry Clean',
        'subtitle': 'Designer Wear Care',
        'color': const Color(0xFFFCE4EC),
        'icon': Icons.dry_cleaning,
        'textColor': const Color(0xFFC2185B),
      },
      {
        'title': 'Shoe Spa',
        'subtitle': 'Restore & Protect',
        'color': const Color(0xFFFFF3E0),
        'icon': Icons.sports_handball,
        'textColor': const Color(0xFFE65100),
      },
      {
        'title': 'Carpet Care',
        'subtitle': 'Deep Clean',
        'color': const Color(0xFFE8F5E9),
        'icon': Icons.texture,
        'textColor': const Color(0xFF2E7D32),
      },
      {
        'title': 'Curtain Fresh',
        'subtitle': 'Free Pickup',
        'color': const Color(0xFFE0F7FA),
        'icon': Icons.curtains,
        'textColor': const Color(0xFF00838F),
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 20 : 30,
        horizontal: isMobile ? 20 : 40,
      ),
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1250),
          child: Column(
            crossAxisAlignment: isMobile
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Text(
                'In the Spotlight',
                textAlign: isMobile ? TextAlign.center : TextAlign.start,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF475569),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 30),
              if (isMobile)
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: spotlightItems.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 15),
                    itemBuilder: (context, index) {
                      final item = spotlightItems[index];
                      return SizedBox(
                        width: 200,
                        child: _SpotlightCard(
                          title: item['title'] as String,
                          subtitle: item['subtitle'] as String,
                          icon: item['icon'] as IconData,
                          baseColor: item['color'] as Color,
                          textColor: item['textColor'] as Color,
                          onTap: () => context.push('/category/${index + 1}'),
                        ),
                      );
                    },
                  ),
                )
              else
                Row(
                  children: spotlightItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index == spotlightItems.length - 1 ? 0 : 20,
                        ),
                        child: _SpotlightCard(
                          title: item['title'] as String,
                          subtitle: item['subtitle'] as String,
                          icon: item['icon'] as IconData,
                          baseColor: item['color'] as Color,
                          textColor: item['textColor'] as Color,
                          onTap: () => context.push('/category/${index + 1}'),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOffersSection(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1000;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 20 : 30,
        horizontal: isMobile ? 20 : 40,
      ),
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1300),
          child: isMobile
              ? Column(
                  children: [
                    _OfferHeroBanner(
                      tagline: 'PREMIUM CARE.',
                      title: 'Clino Luxuries:\nThe Silk Edit.',
                      priceText: 'Starting at ₹299.00',
                      imageUrl:
                          'https://images.unsplash.com/photo-1517677208171-0bc6725a3e60?q=80&w=800&auto=format&fit=crop',
                      btnText: 'EXPLORE NOW',
                      onTap: () {},
                    ),
                    const SizedBox(height: 15),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.75, // More vertical room for text
                      children: [
                        _SmallOfferCard(
                          discount: '25% off',
                          desc: 'Bring back the\nshine',
                          imageUrl:
                              'https://images.unsplash.com/photo-1515562141207-7a18b5ce7142?q=80&w=400&auto=format&fit=crop',
                          color: const Color(0xFFC084FC).withValues(alpha: 0.2),
                        ),
                        _SmallOfferCard(
                          imageUrl:
                              'https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=400&auto=format&fit=crop',
                          color: const Color(0xFF0F172A),
                          isDark: true,
                        ),
                        _SmallOfferCard(
                          imageUrl:
                              'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=400&auto=format&fit=crop',
                          color: const Color(0xFF365314),
                          isDark: true,
                        ),
                        _SmallOfferCard(
                          title: 'SINGULARITY',
                          subtitle: 'Well-Defined',
                          imageUrl:
                              'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?q=80&w=400&auto=format&fit=crop',
                          color: const Color(0xFFFDE68A).withValues(alpha: 0.3),
                        ),
                      ],
                    ),
                  ],
                )
              : IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left: Large Hero Banner
                      Expanded(
                        flex: 3,
                        child: _OfferHeroBanner(
                          tagline: 'PREMIUM CARE.',
                          title: 'Clino Luxuries:\nThe Silk Edit.',
                          priceText:
                              'Starting at ₹299.00 or ₹49/mo.\nfor 6 mo. Footnote*',
                          imageUrl:
                              'https://images.unsplash.com/photo-1517677208171-0bc6725a3e60?q=80&w=800&auto=format&fit=crop',
                          btnText: 'EXPLORE NOW',
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Right: 2x2 Grid of Small Banners
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _SmallOfferCard(
                                      discount: '25% off',
                                      desc:
                                          'Bring back the\nshine of your jewelry set',
                                      imageUrl:
                                          'https://images.unsplash.com/photo-1515562141207-7a18b5ce7142?q=80&w=400&auto=format&fit=crop',
                                      color: const Color(
                                        0xFFC084FC,
                                      ).withValues(alpha: 0.2),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: _SmallOfferCard(
                                      imageUrl:
                                          'https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=400&auto=format&fit=crop',
                                      color: const Color(0xFF0F172A),
                                      isDark: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _SmallOfferCard(
                                      imageUrl:
                                          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=400&auto=format&fit=crop',
                                      color: const Color(0xFF365314),
                                      isDark: true,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: _SmallOfferCard(
                                      title: 'SINGULARITY',
                                      subtitle: 'Well-Defined',
                                      imageUrl:
                                          'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?q=80&w=400&auto=format&fit=crop',
                                      color: const Color(
                                        0xFFFDE68A,
                                      ).withValues(alpha: 0.3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildMostBookedSection(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1000;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 30 : 40,
        horizontal: isMobile ? 20 : 40,
      ),
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1300),
          child: Column(
            children: [
              // Header
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
              const SizedBox(height: 30),
              // Services Grid
              if (isMobile)
                SizedBox(
                  height: 480, // Increased height to prevent overflow
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildMostBookedCard(
                        'Premium Wash & Fold',
                        '49',
                        4.8,
                        '2.4k',
                        'https://images.unsplash.com/photo-1521335629791-ce4aec67dd15?q=80&w=800&auto=format&fit=crop',
                      ),
                      _buildMostBookedCard(
                        'Express Dry Cleaning',
                        '149',
                        4.9,
                        '1.8k',
                        'https://images.unsplash.com/photo-1517677208171-0bc6725a3e60?q=80&w=500&auto=format&fit=crop',
                      ),
                      _buildMostBookedCard(
                        'Professional Shoe Spa',
                        '299',
                        4.7,
                        '950',
                        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=500&auto=format&fit=crop',
                      ),
                      _buildMostBookedCard(
                        'Leather Jacket Gala',
                        '999',
                        5.0,
                        '420',
                        'https://images.unsplash.com/photo-1521223890158-f9f7c3d5d504?q=80&w=800&auto=format&fit=crop',
                      ),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _buildMostBookedCard(
                        'Premium Wash & Fold',
                        '49',
                        4.8,
                        '2.4k',
                        'https://images.unsplash.com/photo-1521335629791-ce4aec67dd15?q=80&w=800&auto=format&fit=crop',
                      ),
                    ),
                    const SizedBox(width: 25),
                    Expanded(
                      child: _buildMostBookedCard(
                        'Express Dry Cleaning',
                        '149',
                        4.9,
                        '1.8k',
                        'https://images.unsplash.com/photo-1517677208171-0bc6725a3e60?q=80&w=500&auto=format&fit=crop',
                      ),
                    ),
                    const SizedBox(width: 25),
                    Expanded(
                      child: _buildMostBookedCard(
                        'Professional Shoe Spa',
                        '299',
                        4.7,
                        '950',
                        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=500&auto=format&fit=crop',
                      ),
                    ),
                    const SizedBox(width: 25),
                    Expanded(
                      child: _buildMostBookedCard(
                        'Leather Jacket Gala',
                        '999',
                        5.0,
                        '420',
                        'https://images.unsplash.com/photo-1521223890158-f9f7c3d5d504?q=80&w=800&auto=format&fit=crop',
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
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
            color: const Color(0xFF6366F1),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Most Booked Services',
          style: GoogleFonts.playfairDisplay(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildMostBookedViewAll(BuildContext context) {
    return TextButton.icon(
      onPressed: () => context.push('/services'),
      icon: const Text(
        'Explore All Services',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      label: const Icon(Icons.arrow_forward, size: 18),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF1E293B),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  Widget _buildMostBookedCard(
    String name,
    String price,
    double rating,
    String reviews,
    String imageUrl,
  ) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 20),
      child: _MostBookedServiceCard(
        name: name,
        price: price,
        rating: rating,
        reviews: reviews,
        imageUrl: imageUrl,
        onTap: () {},
      ),
    );
  }

  Widget _buildWhyChooseUsSection(
    BuildContext context,
    AsyncValue<List<WhyChooseUsModel>> whyChooseUsAsync,
  ) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1000;

    return whyChooseUsAsync.when(
      data: (items) {
        return Container(
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 30 : 40,
            horizontal: isMobile ? 20 : 40,
          ),
          color: const Color(0xFFFDFCFB),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1300),
              child: Column(
                children: [
                  Column(
                    children: [
                      Text(
                        'OUR COMMITMENT',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6366F1),
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Why Choose Us',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: isMobile ? 32 : 48,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'We provide the highest standards of care for your beloved garments.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  if (isMobile)
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.65,
                      children: items.map((item) {
                        return _WhyChooseCard(
                          icon: _getIconData(item.iconUrl),
                          title: item.title,
                          subtitle: item.description,
                          color: _getWhyChooseColor(item.title),
                        );
                      }).toList(),
                    )
                  else
                    Row(
                      children: items.map((item) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: _WhyChooseCard(
                              icon: _getIconData(item.iconUrl),
                              title: item.title,
                              subtitle: item.description,
                              color: _getWhyChooseColor(item.title),
                            ),
                          ),
                        );
                      }).toList(),
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
    if (t.contains('quality')) return const Color(0xFF6366F1);
    if (t.contains('time') || t.contains('delivery')) {
      return const Color(0xFFEC4899);
    }
    if (t.contains('eco') || t.contains('friendly')) {
      return const Color(0xFF14B8A6);
    }
    if (t.contains('price') || t.contains('fair')) {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFF6366F1);
  }

  Widget _buildTestimonialsSection(
    BuildContext context,
    AsyncValue<List<TestimonialModel>> testimonialsAsync,
  ) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1000;

    return testimonialsAsync.when(
      data: (items) {
        return Container(
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 30 : 50,
            horizontal: isMobile ? 20 : 40,
          ),
          color: const Color(0xFFF8FAFC),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1300),
              child: Column(
                children: [
                  Column(
                    children: [
                      Text(
                        'REVIEWS',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6366F1),
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'What Our Customers Say',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: isMobile ? 32 : 48,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  if (isMobile)
                    SizedBox(
                      height: 300,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: items.map((t) {
                          return _buildTestimonialCard(
                            t.name,
                            t.role,
                            t.rating.toInt(),
                            t.message,
                            t.imageUrl,
                          );
                        }).toList(),
                      ),
                    )
                  else
                    Row(
                      children: items.take(3).map((t) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: _buildTestimonialCard(
                              t.name,
                              t.role,
                              t.rating.toInt(),
                              t.message,
                              t.imageUrl,
                            ),
                          ),
                        );
                      }).toList(),
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
      width: 350,
      margin: const EdgeInsets.only(right: 20),
      child: _PremiumTestimonialCard(
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1000;

    return statsAsync.when(
      data: (statsData) {
        final statsItems = [
          {
            'value': statsData?.happyClients ?? '50K+',
            'label': 'Happy Customers',
            'icon': Icons.people_alt_rounded,
          },
          {
            'value': statsData?.totalBranches ?? '1000+',
            'label': 'Verified Pros',
            'icon': Icons.verified_user_rounded,
          },
          {
            'value': statsData?.totalCities ?? '20+',
            'label': 'Cities Presence',
            'icon': Icons.location_on_rounded,
          },
          {
            'value': statsData?.totalOrders ?? '100K+',
            'label': 'Total Orders',
            'icon': Icons.shopping_basket_rounded,
          },
        ];

        return Container(
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 30 : 50,
            horizontal: isMobile ? 20 : 40,
          ),
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              // Stats Row
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1300),
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
              SizedBox(height: isMobile ? 80 : 100),
              // App Download UI
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
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
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            s['icon'] as IconData,
            color: const Color(0xFF6366F1),
            size: isMobile ? 24 : 32,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 24),
        _AnimatedCounter(
          value: s['value'] as String,
          style: GoogleFonts.inter(
            fontSize: isMobile ? 28 : 52,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          s['label'] as String,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: isMobile ? 14 : 16,
            color: const Color(0xFF475569),
            fontWeight: FontWeight.w500,
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
        Text(
          'EXPERIENCE CLOUD WASH ON THE GO',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6366F1),
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your Personal Laundry\nManager in Your Pocket',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.playfairDisplay(
            fontSize: isMobile ? 32 : 48,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
            height: 1.1,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Book, track, and manage your laundry needs with a single tap. Join 50,000+ happy users today.',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            color: const Color(0xFF475569),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 48),
        Wrap(
          spacing: 15,
          runSpacing: 15,
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          children: [
            _AppStoreBadge(
              icon: Icons.apple,
              text: 'App Store',
              subtext: 'Download',
              color: Colors.white,
              onTap: () {},
            ),
            _AppStoreBadge(
              icon: Icons.play_arrow_rounded,
              text: 'Google Play',
              subtext: 'Get it on',
              color: Colors.white,
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
          width: isMobile ? 280 : 400,
          height: isMobile ? 280 : 400,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: isMobile ? 240 : 320,
          height: isMobile ? 450 : 600,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(isMobile ? 36 : 48),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
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
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.image, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingWhatsAppButton() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF25D366),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Icon(Icons.chat, color: Colors.white, size: 28),
    );
  }
}

// Helper Widgets

class _TrendingTag extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final IconData? icon;
  const _TrendingTag(this.text, this.onTap, {this.icon});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primary, AppTheme.primaryDark],
          ), // Dark Gradient
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: AppTheme.accent), // Gold Icon
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ), // White Text
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final String name;
  final IconData icon;
  final Color cardColor;
  final String itemCount;
  final String? imagePath;
  final VoidCallback onTap;
  const _CategoryCard({
    required this.name,
    required this.icon,
    required this.cardColor,
    required this.itemCount,
    this.imagePath,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          width: 180,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovered ? Colors.purple.shade300 : Colors.transparent,
              width: 2,
            ),
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular Icon Container
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.cardColor,
                ),
                child: Center(
                  child: widget.imagePath != null
                      ? ClipOval(
                          child: Image.asset(
                            widget.imagePath!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Icon(
                          widget.icon,
                          size: 36,
                          color: const Color(0xFF2D3748),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // Category Name
              Text(
                widget.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: isHovered ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14,
                  color: isHovered
                      ? Colors.purple.shade700
                      : const Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 4),
              // Item Count
              Text(
                widget.itemCount,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple Category Item for grid layout (no card, just icon + text)
class _CategoryItem extends StatefulWidget {
  final String name;
  final String count;
  final IconData icon;
  final Color iconColor;
  final String? imagePath;
  final VoidCallback onTap;
  const _CategoryItem({
    required this.name,
    required this.count,
    required this.icon,
    required this.iconColor,
    this.imagePath,
    required this.onTap,
  });

  @override
  State<_CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<_CategoryItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.translationValues(0, isHovered ? -10 : 0, 0),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isHovered
                    ? widget.iconColor.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: isHovered ? 25 : 15,
                offset: Offset(0, isHovered ? 12 : 6),
              ),
            ],
            border: Border.all(
              color: isHovered
                  ? widget.iconColor.withValues(alpha: 0.2)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular Icon Background
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isHovered
                      ? widget.iconColor.withValues(alpha: 0.3)
                      : widget.iconColor.withValues(alpha: 0.15),
                ),
                child: Center(
                  child: widget.imagePath != null
                      ? CachedNetworkImage(
                          imageUrl: widget.imagePath!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                          placeholder: (_, __) =>
                              const CircularProgressIndicator(strokeWidth: 2),
                          errorWidget: (context, error, stackTrace) {
                            return Icon(
                              widget.icon,
                              size: 34,
                              color: widget.iconColor,
                            );
                          },
                        )
                      : Icon(widget.icon, size: 34, color: widget.iconColor),
                ),
              ),
              const SizedBox(height: 18),
              // Name
              Text(
                widget.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              // Count
              Text(
                widget.count,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpotlightCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color baseColor;
  final Color textColor;
  final VoidCallback onTap;

  const _SpotlightCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.baseColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<_SpotlightCard> createState() => _SpotlightCardState();
}

class _SpotlightCardState extends State<_SpotlightCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 180,
          transform: Matrix4.translationValues(0, _isHovered ? -10 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor.withValues(alpha: 0.95),
                widget.baseColor.withAlpha(200),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.baseColor.withValues(
                  alpha: _isHovered ? 0.4 : 0.1,
                ),
                blurRadius: _isHovered ? 30 : 15,
                offset: Offset(0, _isHovered ? 15 : 5),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.antiAlias,
            children: [
              // Animated Background Bubbles
              _MovingBubble(
                controller: _controller,
                size: 80,
                x: 0.1,
                y: 0.2,
                color: Colors.white24,
              ),
              _MovingBubble(
                controller: _controller,
                size: 60,
                x: 0.8,
                y: 0.7,
                color: Colors.white12,
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon with soft background
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.textColor,
                        size: 28,
                      ),
                    ),
                    const Spacer(),
                    // Title
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.textColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Subtitle
                    Text(
                      widget.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: widget.textColor.withValues(alpha: 0.7),
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

class _MovingBubble extends StatelessWidget {
  final AnimationController controller;
  final double size;
  final double x;
  final double y;
  final Color color;

  const _MovingBubble({
    required this.controller,
    required this.size,
    required this.x,
    required this.y,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final sinVal = (math.sin(controller.value * 2 * math.pi) + 1) / 2;
        return Positioned(
          left: (x * 200) + (math.sin(controller.value * 6.28) * 20),
          top: (y * 150) + (math.cos(controller.value * 6.28) * 15),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        );
      },
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Color color;
  final String title;
  final String offer;
  const _OfferCard(this.color, this.title, this.offer, {super.key});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              offer,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProcessStepCard extends StatefulWidget {
  final int number;
  final String title;
  final String desc;
  final IconData icon;
  final Color color;

  const _ProcessStepCard({
    required this.number,
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
  });

  @override
  State<_ProcessStepCard> createState() => _ProcessStepCardState();
}

class _ProcessStepCardState extends State<_ProcessStepCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1000;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isMobile ? screenWidth - 40 : 380,
        height: isMobile ? null : 180,
        constraints: const BoxConstraints(minHeight: 180),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered
                ? widget.color.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? widget.color.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: _isHovered ? 25 : 15,
              offset: Offset(0, _isHovered ? 12 : 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number and Icon
            Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _isHovered
                        ? widget.color
                        : widget.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      color: _isHovered ? Colors.white : widget.color,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${widget.number.toString().padLeft(2, '0')}',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: widget.color.withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    widget.title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.desc,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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

class _ProcessButton extends StatelessWidget {
  final String text;
  final Color color;
  const _ProcessButton({required this.text, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _ValueReasonCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final Color color;

  const _ValueReasonCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1E293B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _getPremiumCategoryColor(String name) {
  // Electric Lime (Cyber Neon)
  return const Color(0xFFCCFF00);
}

// Soft pastel colors matching reference design
Color _getCardColor(int index) {
  final colors = [
    const Color(0xFFE8F4FD), // Soft Blue
    const Color(0xFFFFF3E0), // Soft Cream
    const Color(0xFFE8F5E9), // Soft Mint
    const Color(0xFFFCE4EC), // Soft Pink
    const Color(0xFFE0F7FA), // Soft Cyan
    const Color(0xFFF3E5F5), // Soft Lavender
    const Color(0xFFFFF9C4), // Soft Yellow
    const Color(0xFFF1F8E9), // Soft Lime
    const Color(0xFFE1F5FE), // Soft Sky
    const Color(0xFFFBE9E7), // Soft Deep Orange
  ];
  return colors[index % colors.length];
}

// Get custom Flaticon image path for category (null = use default Material icon)
String? _getCategoryImagePath(String name) {
  switch (name.toLowerCase()) {
    case 'laundry':
      return 'assets/images/icons/laundry.png';
    case 'dry cleaning':
      return 'assets/images/icons/dry_cleaning.png';
    case 'shoe cleaning':
      return 'assets/images/icons/shoe_cleaning.png';
    case 'leather cleaning':
      return 'assets/images/icons/leather_cleaning.png';
    case 'curtain cleaning':
      return 'assets/images/icons/curtain_cleaning.png';
    case 'carpet cleaning':
      return 'assets/images/icons/carpet_cleaning.png';
    // Add more as you upload more icons:
    default:
      return null; // Use Material icon
  }
}

class _WhyChooseItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _WhyChooseItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 40, color: AppTheme.primary),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String name;
  final String location;
  final int rating;
  final String text;
  const _TestimonialCard({
    required this.name,
    required this.location,
    required this.rating,
    required this.text,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '"$text"',
            textAlign: TextAlign.center,
            style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            location,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _BigOfferBanner extends StatelessWidget {
  final Color color;
  final String title;
  final String subtitle;
  final String discount;
  final String imageUrl;

  const _BigOfferBanner({
    required this.color,
    required this.title,
    required this.subtitle,
    required this.discount,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias, // Clip image
      child: Row(
        children: [
          // Left Side: Content
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(24), // Reduced from 32
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withValues(alpha: 0.8)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // Minimize column height
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      discount,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: color,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Claim',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right Side: Image
          Expanded(
            flex: 2,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: Colors.white24,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (_, __, ___) => Container(
                color: Colors.white24,
                child: const Icon(Icons.image, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppStoreBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final String subtext;
  final Color color;
  final VoidCallback onTap;

  const _AppStoreBadge({
    required this.icon,
    required this.text,
    required this.subtext,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 1000;
    final bool isVerySmall = MediaQuery.of(context).size.width < 340;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isVerySmall ? 12 : (isMobile ? 16 : 20),
          vertical: isMobile ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: isMobile ? 24 : 28),
            SizedBox(width: isMobile ? 8 : 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  subtext,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: isMobile ? 9 : 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 13 : 16,
                    fontWeight: FontWeight.bold,
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

// Animated Bubble Widget with floating effect
class _AnimatedBubble extends StatefulWidget {
  final double size;
  final Color color;
  final double delay;
  const _AnimatedBubble({
    required this.size,
    required this.color,
    required this.delay,
  });

  @override
  State<_AnimatedBubble> createState() => _AnimatedBubbleState();
}

class _AnimatedBubbleState extends State<_AnimatedBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 20,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [widget.color, widget.color.withValues(alpha: 0)],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blue.shade600, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShiningStars extends StatelessWidget {
  const _ShiningStars();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.auto_awesome, color: Color(0xFFFFB100), size: 32),
        const SizedBox(width: 8),
        Icon(
          Icons.auto_awesome,
          color: const Color(0xFFFFB100).withValues(alpha: 0.6),
          size: 24,
        ),
      ],
    );
  }
}

class _RoundedImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  const _RoundedImage({
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            color: Colors.grey.shade100,
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (_, __, ___) => const Icon(Icons.image),
        ),
      ),
    );
  }
}

class _AboutFeatureItem extends StatelessWidget {
  final String title;
  final String desc;
  const _AboutFeatureItem({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFFB100),
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OfferHeroBanner extends StatelessWidget {
  final String tagline;
  final String title;
  final String priceText;
  final String imageUrl;
  final String btnText;
  final VoidCallback onTap;

  const _OfferHeroBanner({
    required this.tagline,
    required this.title,
    required this.priceText,
    required this.imageUrl,
    required this.btnText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 1000;

    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: Colors.grey.shade100,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(isMobile ? 20 : 50),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.white.withValues(alpha: 0.9),
                Colors.white.withValues(alpha: 0.4),
                Colors.transparent,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tagline,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 12 : 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E3A5F),
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: isMobile ? 12 : 24),
              Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: isMobile ? 28 : 52,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                  height: 1.1,
                ),
              ),
              SizedBox(height: isMobile ? 12 : 24),
              Text(
                priceText,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 13 : 16,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              SizedBox(height: isMobile ? 24 : 48),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF134E4A),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 40,
                    vertical: isMobile ? 12 : 22,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  btnText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SmallOfferCard extends StatelessWidget {
  final String? discount;
  final String? desc;
  final String? title;
  final String? subtitle;
  final String imageUrl;
  final Color color;
  final bool isDark;

  const _SmallOfferCard({
    this.discount,
    this.desc,
    this.title,
    this.subtitle,
    required this.imageUrl,
    required this.color,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: color,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (_, __, ___) => Container(color: color),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent, // Image is behind
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: isDark ? 0.3 : 0.0),
                  Colors.black.withValues(alpha: isDark ? 0.6 : 0.1),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (discount != null) ...[
                  Text(
                    'upto',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    discount!,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
                if (desc != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    desc!,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
                if (title != null) ...[
                  Text(
                    title!,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                      letterSpacing: 1,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MostBookedServiceCard extends StatefulWidget {
  final String name;
  final String price;
  final double rating;
  final String reviews;
  final String imageUrl;
  final VoidCallback onTap;

  const _MostBookedServiceCard({
    required this.name,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  State<_MostBookedServiceCard> createState() => _MostBookedServiceCardState();
}

class _MostBookedServiceCardState extends State<_MostBookedServiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 1000;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.12 : 0.05),
                blurRadius: _isHovered ? 30 : 20,
                offset: Offset(0, _isHovered ? 15 : 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image and Rating Overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        height: 220,
                        color: Colors.grey.shade100,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => const Icon(Icons.image),
                    ),
                  ),
                  Positioned(
                    top: 15,
                    left: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 5),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            widget.rating.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            ' (${widget.reviews})',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Starting from',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '₹${widget.price}',
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF6366F1),
                              ),
                            ),
                          ],
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _isHovered
                                ? const Color(0xFF6366F1)
                                : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            color: _isHovered
                                ? Colors.white
                                : const Color(0xFF6366F1),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // "Book Now" that appears or changes style
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: widget.onTap,
                        style: TextButton.styleFrom(
                          backgroundColor: _isHovered
                              ? const Color(0xFF1E293B)
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: _isHovered
                                  ? Colors.transparent
                                  : Colors.grey.shade200,
                            ),
                          ),
                        ),
                        child: Text(
                          'Book Now',
                          style: TextStyle(
                            color: _isHovered
                                ? Colors.white
                                : const Color(0xFF1E293B),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
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

class _WhyChooseCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _WhyChooseCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  State<_WhyChooseCard> createState() => _WhyChooseCardState();
}

class _WhyChooseCardState extends State<_WhyChooseCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 1000;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(isMobile ? 12 : 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? widget.color.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: _isHovered ? 30 : 15,
              offset: Offset(0, _isHovered ? 12 : 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isHovered
                    ? widget.color
                    : widget.color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                color: _isHovered ? Colors.white : widget.color,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.title,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumTestimonialCard extends StatelessWidget {
  final String name;
  final String location;
  final int rating;
  final String text;
  final String avatarUrl;

  const _PremiumTestimonialCard({
    required this.name,
    required this.location,
    required this.rating,
    required this.text,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: CachedNetworkImageProvider(avatarUrl),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    location,
                    style: TextStyle(
                      color: const Color(0xFF475569),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < rating
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: Colors.amber,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '"$text"',
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 15,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(
                Icons.verified_rounded,
                color: Colors.blue.shade400,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Verified Customer',
                style: TextStyle(
                  color: Colors.blue.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
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
    return VisibilityDetector(
      key: Key('counter_${widget.value}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5 && !_hasAnimated) {
          _controller.forward();
          _hasAnimated = true;
        }
      },
      child: AnimatedBuilder(
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
      ),
    );
  }
}
