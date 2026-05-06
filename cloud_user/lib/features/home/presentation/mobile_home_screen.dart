import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_user/core/models/category_model.dart';
import 'package:cloud_user/core/models/service_model.dart';
import 'package:cloud_user/core/models/sub_category_model.dart';
import 'package:cloud_user/core/theme/app_theme.dart';
import 'package:cloud_user/core/utils/device_logo_utils.dart';
import 'package:cloud_user/core/utils/image_data_utils.dart';
import 'package:cloud_user/core/utils/logo_cache_utils.dart';
import 'package:cloud_user/features/home/data/hero_section_model.dart';
import 'package:cloud_user/features/home/data/home_providers.dart';
import 'package:cloud_user/features/home/data/web_content_providers.dart';
import 'package:cloud_user/features/profile/presentation/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_user/core/widgets/home_shimmer_loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_user/core/widgets/profile_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:cloud_user/core/router/route_observer.dart';

class MobileHomeScreen extends ConsumerStatefulWidget {
  const MobileHomeScreen({super.key});

  @override
  ConsumerState<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends ConsumerState<MobileHomeScreen>
    with RouteAware {
  late WebViewController _videoController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOpacity = 0;
  bool _isMuted = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final newOpacity = (offset / 50).clamp(0.0, 1.0);
    if (newOpacity != _scrollOpacity) {
      setState(() {
        _scrollOpacity = newOpacity;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    // Called when the top route has been popped off, and this route shows up.
    _initializeController(force: true);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _scrollController.dispose();
    super.dispose();
  }

  bool _isControllerInitialized = false;
  String? _lastLoadedUrl;
  bool _isVisible = false;

  Future<void> _onRefresh() async {
    // Invalidate all relevant providers to force a fresh fetch
    ref.invalidate(userProfileProvider);
    ref.invalidate(heroSectionProvider);
    ref.invalidate(categoriesProvider);
    ref.invalidate(homeBannersProvider);
    ref.invalidate(spotlightServicesProvider);
    ref.invalidate(topServicesProvider);
    ref.invalidate(subCategoriesProvider);

    // Re-initialize video on refresh
    _initializeController(force: true);

    // Wait for critical data to reload
    try {
      await Future.wait([
        ref.read(heroSectionProvider.future),
        ref.read(categoriesProvider.future),
      ]);
    } catch (e) {
      debugPrint('Refresh error: $e');
    }
  }

  void _initializeController({bool force = false}) async {
    final heroAsync = ref.read(heroSectionProvider);
    String videoUrl =
        'https://player.cloudinary.com/embed/?cloud_name=dssmutzly&public_id=795v3npt7drmt0cvkhmsjtwxs4_result__zj0nsr&fluid=true&controls=false&autoplay=true&loop=true&muted=${_isMuted ? 1 : 0}&show_logo=false&bigPlayButton=false';

    heroAsync.whenData((data) {
      if (data != null &&
          data.youtubeUrl != null &&
          data.youtubeUrl!.isNotEmpty) {
        String url = data.youtubeUrl!;
        url = url.replaceAll('&muted=1', '').replaceAll('?muted=1', '');
        if (!url.contains('?')) {
          url +=
              '?muted=${_isMuted ? 1 : 0}&autoplay=true&controls=false&loop=true';
        } else {
          url +=
              '&muted=${_isMuted ? 1 : 0}&autoplay=true&controls=false&loop=true';
        }
        videoUrl = url;
      }
    });

    if (_lastLoadedUrl == videoUrl && !force) return;
    _lastLoadedUrl = videoUrl;

    if (!_isControllerInitialized) {
      late final PlatformWebViewControllerCreationParams params;
      if (WebViewPlatform.instance is WebKitWebViewPlatform) {
        params = WebKitWebViewControllerCreationParams(
          allowsInlineMediaPlayback: true,
          mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
        );
      } else {
        params = const PlatformWebViewControllerCreationParams();
      }

      _videoController = WebViewController.fromPlatformCreationParams(params)
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (request) => NavigationDecision.prevent,
          ),
        )
        ..enableZoom(false);

      if (_videoController.platform is AndroidWebViewController) {
        (_videoController.platform as AndroidWebViewController)
            .setMediaPlaybackRequiresUserGesture(false);
      }

      setState(() {
        _isControllerInitialized = true;
      });
    }

    _videoController.loadRequest(Uri.parse(videoUrl));
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _initializeController();
    });
  }

  double _heroTitleFontSize(HeroSectionModel? hero) {
    final base = hero?.titleFontSize ?? 28.0;
    // Cap at 36 for mobile to ensure it fits well
    return base.clamp(14.0, 20.0).toDouble();
  }

  double _heroDescriptionFontSize(HeroSectionModel? hero) {
    final base = hero?.descriptionFontSize ?? 13.0;
    // Cap at 16 for mobile
    return base.clamp(12.0, 14.0).toDouble();
  }

  String _heroTitleFontFamily(HeroSectionModel? hero) {
    final value = (hero?.titleFontFamily ?? '').trim();
    return value.isNotEmpty ? value : 'Playfair Display';
  }

  String _heroBodyFontFamily(HeroSectionModel? hero) {
    final value = (hero?.bodyFontFamily ?? '').trim();
    return value.isNotEmpty ? value : 'Inter';
  }

  Color _heroColor(String? value, Color fallback) {
    final color = (value ?? '').trim();
    if (color.isEmpty) return fallback;
    final normalized = color.startsWith('#') ? color.substring(1) : color;
    if (!RegExp(r'^[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$').hasMatch(normalized)) {
      return fallback;
    }
    final buffer = StringBuffer();
    if (normalized.length == 6) {
      buffer.write('ff');
    }
    buffer.write(normalized);
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Uint8List? _decodeDataImage(String imageUrl) {
    if (!imageUrl.startsWith('data:image')) return null;
    final commaIndex = imageUrl.indexOf(',');
    if (commaIndex == -1 || commaIndex >= imageUrl.length - 1) return null;
    try {
      return base64Decode(imageUrl.substring(commaIndex + 1));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);
    final heroAsync = ref.watch(heroSectionProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final bannersAsync = ref.watch(homeBannersProvider);
    final spotlightAsync = ref.watch(spotlightServicesProvider);
    final topServicesAsync = ref.watch(topServicesProvider);
    final subCategoriesAsync = ref.watch(subCategoriesProvider);

    // Listen for hero section updates to re-initialize video
    ref.listen(heroSectionProvider, (previous, next) {
      if (next.hasValue &&
          next.value?.youtubeUrl != previous?.value?.youtubeUrl) {
        _initializeController();
      }
    });

    final padding = MediaQuery.of(context).padding;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppTheme.primary,
            backgroundColor: Colors.white,
            edgeOffset: padding.top + 50,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // 1. VIDEO HEADER WITH PREMIUM OVERLAY
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 380, // Slightly taller for more presence
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background (Image + Video)
                        Positioned.fill(
                          child: heroAsync.maybeWhen(
                            data: (hero) => hero != null && hero.imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: hero.imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(color: Colors.white),
                                    errorWidget: (context, url, error) => Container(color: Colors.white),
                                  )
                                : Container(color: Colors.white),
                            orElse: () => Container(color: Colors.white),
                          ),
                        ),
                        // Video Layer
                        Positioned.fill(
                          child: VisibilityDetector(
                            key: const Key('home_video_visibility'),
                            onVisibilityChanged: (visibilityInfo) {
                              final isNowVisible = visibilityInfo.visibleFraction > 0.1;
                              if (isNowVisible && !_isVisible) {
                                _isVisible = true;
                                _initializeController(force: true);
                              } else if (!isNowVisible) {
                                _isVisible = false;
                              }
                            },
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: 800,
                                height: 380,
                                child: _isControllerInitialized
                                    ? WebViewWidget(controller: _videoController)
                                    : const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ),

                        // Multi-Layer Gradients for Premium Look
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.9),
                                  Colors.white.withOpacity(0.4),
                                  Colors.white.withOpacity(0.8),
                                  Colors.white,
                                ],
                                stops: const [0.0, 0.4, 0.7, 1.0],
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
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Profile Section
                                  userAsync.when(
                                    data: (user) => user == null
                                        ? _buildLoginButton()
                                        : _buildUserProfileBadge(user),
                                    loading: () => _buildProfileShimmer(),
                                    error: (_, __) => _buildLoginButton(),
                                  ),
                                  // Notification Icon
                                  _buildNotificationBadge(),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Hero Content (Bottom Positioned)
                        Positioned(
                          bottom: 24,
                          left: 20,
                          right: 20,
                          child: heroAsync.when(
                            data: (hero) => _buildHeroContentOverlay(hero),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. MODERN CATEGORY GRID
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                    child: categoriesAsync.when(
                      data: (categories) {
                        if (categories.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Services Categories',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${categories.length} Categories',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                childAspectRatio: 0.8,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 12,
                              ),
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final cat = categories[index];
                                return _buildModernCategoryItem(cat);
                              },
                            ),
                          ],
                        );
                      },
                      loading: () => _buildCategoryGridShimmer(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
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
                                            child: Container(
                                              color: Colors.white,
                                            ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
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
                                    scrollPhysics:
                                        const BouncingScrollPhysics(),
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
                        Consumer(
                          builder: (context, ref, _) {
                            final whyChooseUsAsync = ref.watch(
                              liveWhyChooseUsProvider,
                            );
                            return whyChooseUsAsync.when(
                              data: (items) {
                                if (items.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle('Our Commitment'),
                                    const SizedBox(height: 15),
                                    ...items
                                        .take(3)
                                        .map(
                                          (item) => _buildWhyItem(
                                            item.title,
                                            item.description,
                                          ),
                                        ),
                                  ],
                                );
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 50)),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).padding.top,
              color: const Color(0xFFF8F9FA).withOpacity(_scrollOpacity),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: () => context.push('/login'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline, color: AppTheme.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              'LOGIN',
              style: GoogleFonts.inter(
                color: AppTheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileBadge(dynamic user) {
    return GestureDetector(
      onTap: () => context.push('/profile'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProfileImage(
              imageSource: user['profileImage'],
              size: 36,
              fallbackUrl: 'https://i.pravatar.cc/150?u=user',
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                user['name'] ?? 'User',
                style: GoogleFonts.inter(
                  color: const Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.5),
      highlightColor: Colors.white,
      child: Container(
        width: 120,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildNotificationBadge() {
    return Consumer(
      builder: (context, ref, _) {
        // Since unreadNotificationsCountProvider is in WebNavBar, we check if it's accessible here
        // If not, we use a simple icon for now or check notification_provider
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF1E293B), size: 24),
            onPressed: () => context.push('/notifications'),
          ),
        );
      },
    );
  }

  Widget _buildHeroContentOverlay(HeroSectionModel? hero) {
    final title = hero?.mainTitle.replaceAll('\\n', '\n') ?? 'Feel Fresh Every Day';
    final desc = hero?.description ?? 'Book premium laundry pickup in seconds.';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tagline Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: AppTheme.glassGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, color: AppTheme.primary, size: 14),
              const SizedBox(width: 8),
              Text(
                '#1 RATED SERVICE',
                style: GoogleFonts.inter(
                  color: AppTheme.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0F172A),
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          desc,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: const Color(0xFF475569),
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        // Modern Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.softShadow,
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Search for services...',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: const Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'View All',
              style: GoogleFonts.inter(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotlightCard(ServiceModel service) {
    return GestureDetector(
      onTap: () => context.push('/service-details', extra: service),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.softShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              service.image != null && service.image!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: service.image!,
                      fit: BoxFit.cover,
                    )
                  : Container(color: Colors.grey[200]),
              
              // Gradient Overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // Rating
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        service.rating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              // Details
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      service.title,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${service.price}',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.black, size: 20),
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
        margin: const EdgeInsets.only(right: 16),
        width: 120,
        child: Column(
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(cat.imageUrl),
                  fit: BoxFit.cover,
                ),
                boxShadow: AppTheme.softShadow,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              cat.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: CachedNetworkImage(
                  imageUrl: service.image ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
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
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${service.price}',
                        style: GoogleFonts.inter(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primary, size: 24),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildModernCategoryItem(CategoryModel cat) {
    final embeddedBytes = decodeDataImage(cat.imageUrl);
    return GestureDetector(
      onTap: () => context.push('/category/${cat.id}', extra: cat.name),
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: embeddedBytes != null
                ? Image.memory(embeddedBytes, fit: BoxFit.contain)
                : CachedNetworkImage(
                    imageUrl: cat.imageUrl,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => const Icon(Icons.category_outlined, color: Color(0xFF94A3B8)),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            cat.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGridShimmer() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
      ),
      itemCount: 8,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: [
            Container(height: 60, width: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 8),
            Container(height: 12, width: 40, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
