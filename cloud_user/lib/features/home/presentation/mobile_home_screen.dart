import 'package:cloud_user/core/models/category_model.dart';
import 'package:cloud_user/core/models/service_model.dart';
import 'package:cloud_user/core/models/sub_category_model.dart';
import 'package:cloud_user/core/theme/app_theme.dart';
import 'package:cloud_user/features/home/data/home_providers.dart';
import 'package:cloud_user/features/home/data/web_content_providers.dart';
import 'package:cloud_user/features/profile/presentation/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_user/core/widgets/home_shimmer_loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class MobileHomeScreen extends ConsumerStatefulWidget {
  const MobileHomeScreen({super.key});

  @override
  ConsumerState<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends ConsumerState<MobileHomeScreen> {
  late final WebViewController _videoController;
  bool _isMuted = false;

  get import => null;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() async {
    final heroAsync = ref.read(heroSectionProvider);
    // Updated video URL with unmuted settings
    String videoUrl =
        'https://player.cloudinary.com/embed/?cloud_name=dssmutzly&public_id=795v3npt7drmt0cvkhmsjtwxs4_result__zj0nsr&fluid=true&controls=false&autoplay=true&loop=true&muted=0&show_logo=false&bigPlayButton=false';

    heroAsync.whenData((data) {
      if (data != null && data.youtubeUrl != null) {
        String url = data.youtubeUrl!;

        // Remove existing muted params to avoid conflicts
        url = url.replaceAll('&muted=1', '').replaceAll('?muted=1', '');

        // Force unmuted and other settings
        if (!url.contains('?')) {
          url += '?muted=0&autoplay=true&controls=false&loop=true';
        } else {
          url += '&muted=0&autoplay=true&controls=false&loop=true';
        }
        videoUrl = url;
      }
    });

    _videoController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) => NavigationDecision.prevent,
        ),
      )
      ..enableZoom(false);

    // Platform-specific configuration for auto-play (Android)
    if (WebViewPlatform.instance != null) {
      // Logic for Android specific media settings if accessible
      // Note: Full autoplay with sound usually requires user interaction
      // on mobile browsers, but we try via Javascript permissions.
    }

    _videoController.loadRequest(Uri.parse(videoUrl));
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      // In a real app, we should use JS to toggle mute instead of re-initializing
      // but for simplicity and reliability with this iframe based player:
      _initializeController();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final bannersAsync = ref.watch(homeBannersProvider);
    final spotlightAsync = ref.watch(spotlightServicesProvider);
    final topServicesAsync = ref.watch(topServicesProvider);
    final subCategoriesAsync = ref.watch(subCategoriesProvider);
    final whyChooseUsAsync = ref.watch(whyChooseUsProvider);

    // Show Skeleton Loader only on initial load (no data yet)
    if (categoriesAsync.isLoading && !categoriesAsync.hasValue) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: HomeShimmerLoading(),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: CustomScrollView(
        slivers: [
          // 1. VIDEO HEADER WITH OVERLAY CONTENT
          SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Video Background (Full Coverage)
                  Positioned.fill(
                    child: Container(
                      color: Colors.transparent,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: 800,
                          height: 300,
                          child: WebViewWidget(controller: _videoController),
                        ),
                      ),
                    ),
                  ),

                  // White Gradient Overlay (Bottom to Top)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.white,
                            Colors.white.withValues(alpha: 0.7),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.3, 0.6],
                        ),
                      ),
                    ),
                  ),

                  // Header Overlay (Profile + Notification)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Profile Section (Avatar + Name)
                            userAsync.when(
                              data: (user) => GestureDetector(
                                onTap: () => context.push('/profile'),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(
                                        user?['profileImage'] ??
                                            'https://i.pravatar.cc/150?u=user',
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        user?['name'] ?? 'User',
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF1A1A1A),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              loading: () => Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey,
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Loading...',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF1A1A1A),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              error: (_, __) => const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey,
                              ),
                            ),
                            // Notification Icon
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                              ),
                              child: InkWell(
                                onTap: () => context.push('/notifications'),
                                child: const Icon(
                                  Icons.notifications_outlined,
                                  color: Color(0xFF1A1A1A),
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content Overlay (Bottom)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Greeting
                          userAsync.when(
                            data: (user) => Text(
                              'GOOD MORNING, ${user?['name']?.toString().toUpperCase() ?? 'USER'}',
                              style: GoogleFonts.inter(
                                color: Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 8),

                          // Title
                          const SizedBox(height: 16),

                          // Badges
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.flash_on,
                                      color: Colors.black87,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'PREMIUM',
                                      style: GoogleFonts.inter(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.auto_awesome,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'EXPERT CARE',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Mute Button
                  Positioned(
                    top: 100,
                    right: 16,
                    child: GestureDetector(
                      onTap: _toggleMute,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isMuted ? Icons.volume_off : Icons.volume_up,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. ACTIVE SERVICES CAROUSEL
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                categoriesAsync.when(
                  data: (categories) {
                    if (categories.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(2),
                          child: Text(
                            'No categories available',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }
                    final firstRowItems = categories.take(4).toList();
                    final secondRowItems = categories.length > 4
                        ? categories.skip(4).take(4).toList()
                        : <dynamic>[];

                    Widget buildItem(CategoryModel cat) {
                      String displayName = cat.name.toString().toUpperCase();
                      final words = cat.name.toString().trim().split(' ');
                      if (words.length > 1) {
                        displayName = '${words[0]} ${words[1][0]}...'
                            .toUpperCase();
                      }

                      return GestureDetector(
                        onTap: () => context.push(
                          '/category/${cat.id}',
                          extra: cat.name,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 65,
                              height: 65,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Image.network(
                                cat.imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.category,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              displayName,
                              style: GoogleFonts.inter(
                                color: const Color(0xFF1A1A1A),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 15,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // First Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var item in firstRowItems)
                                Expanded(child: buildItem(item)),
                              for (var i = 0; i < 4 - firstRowItems.length; i++)
                                const Spacer(),
                            ],
                          ),

                          const SizedBox(height: 5),

                          // Second Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var item in secondRowItems)
                                Expanded(child: buildItem(item)),

                              for (
                                var i = 0;
                                i < 4 - secondRowItems.length;
                                i++
                              )
                                const Spacer(),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox(
                    height: 160, // Increased height
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, stack) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 40,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Error loading categories',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              e.toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          // 4. BANNERS
          SliverToBoxAdapter(
            child: bannersAsync.when(
              data: (banners) {
                if (banners.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: CarouselSlider.builder(
                    itemCount: banners.length,
                    options: CarouselOptions(
                      height: 180,
                      autoPlay: true,
                      viewportFraction: 0.9,
                      enlargeCenterPage: true,
                      autoPlayInterval: const Duration(seconds: 4),
                      enableInfiniteScroll: true,
                    ),
                    itemBuilder: (context, index, realIndex) {
                      final banner = banners[index];
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.grey[200],
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: CachedNetworkImage(
                                imageUrl: banner.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(color: Colors.white),
                                    ),
                                errorWidget: (_, __, ___) => const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            // Gradient Overlay
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.7),
                                  ],
                                  stops: const [0.6, 1.0],
                                ),
                              ),
                            ),
                            // Text Overlay
                            Positioned(
                              bottom: 15,
                              left: 15,
                              right: 15,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (banner.title.isNotEmpty)
                                    Text(
                                      banner.title,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  if (banner.description.isNotEmpty)
                                    Text(
                                      banner.description,
                                      style: GoogleFonts.inter(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const SizedBox(height: 180),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          // 5. SPOTLIGHT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Spotlight'),
                  const SizedBox(height: 15),
                  spotlightAsync.when(
                    data: (services) => CarouselSlider.builder(
                      itemCount: services.length,
                      options: CarouselOptions(
                        height: 280,
                        viewportFraction: 0.65,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: true,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 5),
                        scrollPhysics: const BouncingScrollPhysics(),
                      ),
                      itemBuilder: (context, index, realIndex) {
                        return _buildSpotlightCard(services[index]);
                      },
                    ),
                    loading: () => const SizedBox(height: 200),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          // 6. TOP SERVICES SECTION
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Top Services'),
                  const SizedBox(height: 20),
                  topServicesAsync.when(
                    data: (services) => GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.85,
                            mainAxisSpacing: 15,
                            crossAxisSpacing: 15,
                          ),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        return _buildServiceGridCard(services[index]);
                      },
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          // 7. EXTRA SECTIONS FROM DB
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  subCategoriesAsync.when(
                    data: (subCats) {
                      if (subCats.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('SUB CATEGORIES'),
                          const SizedBox(height: 15),
                          CarouselSlider.builder(
                            itemCount: subCats.length,
                            options: CarouselOptions(
                              height: 160,
                              viewportFraction: 0.4,
                              enableInfiniteScroll: subCats.length > 2,
                              enlargeCenterPage: false,
                              padEnds: false,
                              scrollPhysics: const BouncingScrollPhysics(),
                            ),
                            itemBuilder: (context, index, realIndex) {
                              final cat = subCats[index];
                              return _buildSubCategoryCard(cat);
                            },
                          ),
                        ],
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 30),
                  whyChooseUsAsync.when(
                    data: (items) {
                      if (items.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Our Commitment'),
                          const SizedBox(height: 15),
                          ...items
                              .take(3)
                              .map(
                                (item) =>
                                    _buildWhyItem(item.title, item.description),
                              ),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: const Color(0xFF1A1A1A),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSpotlightCard(ServiceModel service) {
    return GestureDetector(
      onTap: () => context.push('/service-details', extra: service),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              service.image != null && service.image!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: service.image!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.blueGrey[100],
                      child: Icon(
                        Icons.local_laundry_service,
                        size: 40,
                        color: Colors.blueGrey,
                      ),
                    ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(
                        0.8,
                      ), // Using withOpacity instead of withValues for broader compatibility
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),

              // Rating Badge
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        service.rating.toString(),
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      service.category,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.title,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${service.price}',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Colors.black,
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

  Widget _buildSubCategoryCard(SubCategoryModel cat) {
    return GestureDetector(
      onTap: () => context.push('/services-list/${cat.id}', extra: cat.name),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: cat.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (_, __, ___) =>
                          const Center(child: Icon(Icons.category)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Text(
                cat.name,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceGridCard(ServiceModel service) {
    return GestureDetector(
      onTap: () => context.push('/service-details', extra: service),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: CachedNetworkImage(
                  imageUrl: service.image ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(color: Colors.white),
                  ),
                  errorWidget: (_, __, ___) =>
                      const Center(child: Icon(Icons.image)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${service.price}',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Icon(
                        Icons.add_circle,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhyItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
