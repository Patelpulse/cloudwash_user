import 'package:cloud_user/core/theme/app_theme.dart';
import 'package:cloud_user/core/widgets/animated_background.dart';
import 'package:cloud_user/features/home/data/home_providers.dart';
import 'package:cloud_user/features/home/data/web_content_providers.dart';
import 'package:cloud_user/features/profile/presentation/providers/user_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _resetOnboardingForStability();
    _preloadHomeData();
  }

  void _resetOnboardingForStability() async {
    // For now, let's clear it so the user can definitely see it first
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('onboarding_complete');
  }

  void _preloadHomeData() {
    // Silently pre-fetch all Home data while user is onboarding
    // This ensures that when they reach home, data is already in cache
    Future.microtask(() {
      ref.read(categoriesProvider.future);
      ref.read(homeBannersProvider.future);
      ref.read(spotlightServicesProvider.future);
      ref.read(topServicesProvider.future);
      ref.read(subCategoriesProvider.future);
      ref.read(whyChooseUsProvider.future);
      ref.read(heroSectionProvider.future);
      ref.read(userProfileProvider.future);
    });
  }

  void _onFinish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) {
      context.go('/register');
    }
  }

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Premium Care for\nYour Wardrobe',
      description:
          'Expert laundry and dry cleaning services delivered right to your doorstep.',
      icon: Icons.local_laundry_service_outlined,
      color: const Color(0xFF6366F1),
    ),
    OnboardingData(
      title: 'Smart Scheduling,\nZero Hassle',
      description:
          'Book your pickup in seconds and track your clothes in real-time.',
      icon: Icons.timer_outlined,
      color: const Color(0xFF10B981),
    ),
    OnboardingData(
      title: 'Environmentally\nFriendly Cleaning',
      description:
          'We use eco-safe detergents and advanced tech to keep your whites whiter.',
      icon: Icons.eco_outlined,
      color: const Color(0xFFF59E0B),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // If on web, skip onboarding as requested
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/register');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: AnimatedBackground(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData page) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: page.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(page.icon, size: 100, color: page.color)
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1.1, 1.1),
                      duration: 2.seconds,
                      curve: Curves.easeInOut,
                    )
                    .rotate(
                      begin: -0.05,
                      end: 0.05,
                      duration: 2.seconds,
                      curve: Curves.easeInOut,
                    ),
              )
              .animate()
              .fadeIn(duration: 800.ms)
              .scale(begin: const Offset(0.5, 0.5)),
          const SizedBox(height: 60),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 20),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Indicator
            Row(
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: 300.ms,
                  margin: const EdgeInsets.only(right: 8),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppTheme.primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            // Next / Get Started Button
            ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _pages.length - 1) {
                      _onFinish();
                    } else {
                      _pageController.nextPage(
                        duration: 400.ms,
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    shadowColor: AppTheme.primary.withValues(alpha: 0.4),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'GET STARTED' : 'NEXT',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                )
                .animate(target: _currentPage == _pages.length - 1 ? 1 : 0)
                .shimmer(duration: 1.5.seconds, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
