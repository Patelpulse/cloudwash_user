import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_user/core/theme/app_theme.dart';
import 'package:cloud_user/core/utils/image_data_utils.dart';
import 'package:cloud_user/features/home/data/home_providers.dart';
import 'package:cloud_user/features/web/presentation/web_layout.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class WebServicesPage extends ConsumerStatefulWidget {
  const WebServicesPage({super.key});

  @override
  ConsumerState<WebServicesPage> createState() => _WebServicesPageState();
}

class _WebServicesPageState extends ConsumerState<WebServicesPage> {
  // Category icon mapping
  IconData _getCategoryIcon(String name) {
    switch (name.toLowerCase()) {
      case 'cleaning':
        return Icons.cleaning_services_rounded;
      case 'repair':
        return Icons.build_rounded;
      case 'painting':
        return Icons.format_paint_rounded;
      case 'plumbing':
        return Icons.plumbing_rounded;
      case 'electrical':
        return Icons.electrical_services_rounded;
      case 'carpentry':
        return Icons.carpenter_rounded;
      case 'ac repair':
        return Icons.ac_unit_rounded;
      case 'pest control':
        return Icons.bug_report_rounded;
      case 'home salon':
        return Icons.face_retouching_natural_rounded;
      case 'gardening':
        return Icons.grass_rounded;
      case 'car wash':
        return Icons.local_car_wash_rounded;
      case 'laundry':
        return Icons.local_laundry_service_rounded;
      default:
        return Icons.home_repair_service_rounded;
    }
  }

  Color _getCategoryColor(int index) {
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF10B981), // Emerald
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFF43F5E), // Rose
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFFEC4899), // Pink
      const Color(0xFF06B6D4), // Cyan
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 700;
    final bool isMediumScreen = screenWidth >= 700 && screenWidth < 1200;

    return WebLayout(
      showNavBar: true,
      child: Container(
        color: AppTheme.background,
        child: Column(
          children: [
            // 1. HEADER SECTION
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 40 : 80,
                horizontal: isSmallScreen ? 20 : 40,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade100, width: 1),
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'EXPLORE OUR SERVICES',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Premium Care for Your Home',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: isSmallScreen ? 32 : 48,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Choose from our professional cleaning and maintenance services\ndelivered by verified experts at your doorstep.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: isSmallScreen ? 16 : 18,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. SERVICES GRID
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 60,
                horizontal: isSmallScreen ? 20 : 40,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: categoriesAsync.when(
                    data: (categories) {
                      if (categories.isEmpty) {
                        return const Center(child: Text('No services found.'));
                      }
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: isSmallScreen ? 0.85 : 1.2,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return _ServiceCategoryCard(
                            name: category.name,
                            imageUrl: category.imageUrl,
                            icon: _getCategoryIcon(category.name),
                            bgColor: _getCategoryColor(index),
                            description: category.description.isNotEmpty
                                ? category.description
                                : _getDescription(category.name),
                            onTap: () => context.push(
                              '/category/${category.id}',
                              extra: category.name,
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (err, _) => Center(child: Text('Error: $err')),
                  ),
                ),
              ),
            ),

            // 3. HOW IT WORKS
            _buildHowItWorks(isSmallScreen),

            // 4. CTA SECTION
            _buildCTA(isSmallScreen),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorks(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: isSmallScreen ? 20 : 40),
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'How It Works',
                style: GoogleFonts.playfairDisplay(
                  fontSize: isSmallScreen ? 28 : 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              if (isSmallScreen)
             const   Column(
                  children: [
                    _StepCard(
                      number: '1',
                      title: 'Choose Service',
                      description: 'Select the service you need from our wide range of categories.',
                    ),
                     SizedBox(height: 24),
                    _StepCard(
                      number: '2',
                      title: 'Book Time Slot',
                      description: 'Pick a convenient date and time that works for you.',
                    ),
                     SizedBox(height: 24),
                    _StepCard(
                      number: '3',
                      title: 'Get It Done',
                      description: 'Our verified professional arrives and completes the job.',
                    ),
                  ],
                )
              else
               const Row(
                  children: [
                     Expanded(
                      child: _StepCard(
                        number: '1',
                        title: 'Choose Service',
                        description: 'Select the service you need from our wide range of categories.',
                      ),
                    ),
                    const SizedBox(width: 32),
                    const Expanded(
                      child: _StepCard(
                        number: '2',
                        title: 'Book Time Slot',
                        description: 'Pick a convenient date and time that works for you.',
                      ),
                    ),
                    const SizedBox(width: 32),
                    const Expanded(
                      child: _StepCard(
                        number: '3',
                        title: 'Get It Done',
                        description: 'Our verified professional arrives and completes the job.',
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

  Widget _buildCTA(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: isSmallScreen ? 20 : 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 32 : 60),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppTheme.deepShadow,
            ),
            child: isSmallScreen
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Need a Custom Service?',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Can't find what you're looking for? Our team is here to help with personalized solutions for your home.",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: _ModernButton(
                          label: 'Contact Support',
                          onTap: () => context.push('/contact'),
                          isLight: true,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Need a Custom Service?',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Can't find what you're looking for? Our team is here to help with\npersonalized solutions for your home.",
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.8),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 40),
                      _ModernButton(
                        label: 'Contact Support',
                        onTap: () => context.push('/contact'),
                        isLight: true,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  String _getDescription(String name) {
    switch (name.toLowerCase()) {
      case 'cleaning':
        return 'Professional deep cleaning for every corner of your home.';
      case 'repair':
        return 'Expert repairs for appliances, furniture, and fixtures.';
      case 'painting':
        return 'Refresh your walls with premium interior and exterior painting.';
      case 'plumbing':
        return 'Reliable plumbing solutions for leaks and new installations.';
      case 'electrical':
        return 'Safe and certified electrical maintenance and repairs.';
      case 'carpentry':
        return 'Custom furniture work and expert woodwork repairs.';
      case 'ac repair':
        return 'Keep cool with professional AC servicing and maintenance.';
      case 'pest control':
        return 'Protect your home with eco-friendly pest removal services.';
      default:
        return 'Professional service delivered with care and expertise.';
    }
  }
}

class _ServiceCategoryCard extends StatefulWidget {
  final String name;
  final String imageUrl;
  final IconData icon;
  final Color bgColor;
  final String description;
  final VoidCallback onTap;

  const _ServiceCategoryCard({
    required this.name,
    required this.imageUrl,
    required this.icon,
    required this.bgColor,
    required this.description,
    required this.onTap,
  });

  @override
  State<_ServiceCategoryCard> createState() => _ServiceCategoryCardState();
}

class _ServiceCategoryCardState extends State<_ServiceCategoryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final normalizedImageUrl = widget.imageUrl.trim();
    final embeddedImageBytes = decodeDataImage(normalizedImageUrl);
    final hasNetworkImage = normalizedImageUrl.isNotEmpty && embeddedImageBytes == null;

    final bool isMobile = MediaQuery.of(context).size.width < 700;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuart,
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 20 : 28),
            boxShadow: _hovered 
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.06),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: -8,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
            border: Border.all(
              color: _hovered ? widget.bgColor.withOpacity(0.3) : const Color(0xFFF1F5F9),
              width: 1.5,
            ),
          ),
          transform: Matrix4.identity()..translate(0.0, _hovered ? -6.0 : 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon/Image Container with Gradient
              Container(
                height: isMobile ? 60 : 72,
                width: isMobile ? 60 : 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.bgColor,
                      Color.lerp(widget.bgColor, Colors.black, 0.1) ?? widget.bgColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                ),
                child: Center(
                  child: normalizedImageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                          child: embeddedImageBytes != null
                              ? Image.memory(
                                  embeddedImageBytes,
                                  width: isMobile ? 32 : 38,
                                  height: isMobile ? 32 : 38,
                                  fit: BoxFit.contain,
                                )
                              : hasNetworkImage
                                  ? CachedNetworkImage(
                                      imageUrl: normalizedImageUrl,
                                      width: isMobile ? 32 : 38,
                                      height: isMobile ? 32 : 38,
                                      fit: BoxFit.contain,
                                      placeholder: (context, url) => Icon(
                                        widget.icon,
                                        size: isMobile ? 24 : 28,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    )
                                  : Icon(widget.icon, size: isMobile ? 28 : 32, color: Colors.white))
                      : Icon(widget.icon, size: isMobile ? 28 : 32, color: Colors.white),
                ),
              ),
              SizedBox(height: isMobile ? 16 : 20),
              Text(
                widget.name,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: isMobile ? 18 : 22,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: isMobile ? 8 : 10),
              Text(
                widget.description,
                maxLines: isMobile ? 3 : 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: isMobile ? 13 : 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              // Modern Button-like Action
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16, 
                  vertical: isMobile ? 8 : 10
                ),
                decoration: BoxDecoration(
                  color: _hovered ? widget.bgColor.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _hovered ? widget.bgColor.withOpacity(0.2) : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Explore Services',
                      style: GoogleFonts.inter(
                        color: _hovered ? widget.bgColor : AppTheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: isMobile ? 12 : 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedPadding(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.only(left: _hovered ? 6 : 0),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: isMobile ? 16 : 18,
                        color: _hovered ? widget.bgColor : AppTheme.primary,
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

class _StepCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _StepCard({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: GoogleFonts.inter(
              color: AppTheme.textSecondary,
              fontSize: 16,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLight;

  const _ModernButton({
    required this.label,
    required this.onTap,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isLight ? Colors.white : AppTheme.primary,
        foregroundColor: isLight ? AppTheme.primary : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ).copyWith(
        overlayColor: MaterialStateProperty.all(
          (isLight ? AppTheme.primary : Colors.white).withOpacity(0.1),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
