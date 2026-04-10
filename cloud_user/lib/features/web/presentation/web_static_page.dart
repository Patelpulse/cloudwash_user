import 'package:cloud_user/features/home/data/about_us_model.dart';
import 'package:cloud_user/features/home/data/static_page_model.dart';
import 'package:cloud_user/features/home/data/web_content_providers.dart';
import 'package:cloud_user/core/theme/app_theme.dart';
import 'package:cloud_user/core/utils/image_data_utils.dart';
import 'package:cloud_user/features/web/presentation/web_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

/// Static page types
enum StaticPageType {
  aboutUs,
  terms,
  privacy,
  contactUs,
  blog,
  reviews,
  childProtection,
  help,
  refundPolicy,
}

class WebStaticPage extends ConsumerWidget {
  final StaticPageType pageType;

  const WebStaticPage({super.key, required this.pageType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1000;

    // Use wider layout for blog page
    final isWideLayout =
        pageType == StaticPageType.blog || pageType == StaticPageType.reviews;

    if (pageType == StaticPageType.aboutUs) {
      final aboutUsAsync = ref.watch(aboutUsProvider);
      return aboutUsAsync.when(
        data: (aboutUs) {
          if (aboutUs != null && aboutUs.isActive) {
            return WebLayout(
              child: _buildPageShell(
                context,
                isMobile: isMobile,
                isWideLayout: isWideLayout,
                title: aboutUs.title.trim().isNotEmpty
                    ? aboutUs.title
                    : _getPageData(pageType).title,
                content: isMobile
                    ? Column(
                        children: [
                          _buildDynamicAboutContent(aboutUs, isMobile),
                          const SizedBox(height: 60),
                          _buildDynamicAboutImage(aboutUs.imageUrl, isMobile),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 5,
                            child: _buildDynamicAboutImage(
                              aboutUs.imageUrl,
                              isMobile,
                            ),
                          ),
                          const SizedBox(width: 100),
                          Expanded(
                            flex: 5,
                            child: _buildDynamicAboutContent(aboutUs, isMobile),
                          ),
                        ],
                      ),
              ),
            );
          }

          final fallback = _getPageData(pageType);
          return WebLayout(
            child: _buildPageShell(
              context,
              isMobile: isMobile,
              isWideLayout: isWideLayout,
              title: fallback.title,
              content: fallback.content,
            ),
          );
        },
        loading: () {
          final fallback = _getPageData(pageType);
          return WebLayout(
            child: _buildPageShell(
              context,
              isMobile: isMobile,
              isWideLayout: isWideLayout,
              title: fallback.title,
              content: fallback.content,
            ),
          );
        },
        error: (_, __) {
          final fallback = _getPageData(pageType);
          return WebLayout(
            child: _buildPageShell(
              context,
              isMobile: isMobile,
              isWideLayout: isWideLayout,
              title: fallback.title,
              content: fallback.content,
            ),
          );
        },
      );
    }

    if (_isDynamicPolicyPage(pageType)) {
      final slug = _pageSlug(pageType);
      final pageAsync = ref.watch(staticPageProvider(slug));
      return pageAsync.when(
        data: (page) {
          if (page != null) {
            final fallback = _getPageData(pageType);
            return WebLayout(
              child: _buildPageShell(
                context,
                isMobile: isMobile,
                isWideLayout: isWideLayout,
                title: page.title.trim().isNotEmpty ? page.title : fallback.title,
                content: _buildDynamicPolicyContent(
                  context,
                  page,
                  fallback: fallback,
                  isMobile: isMobile,
                ),
              ),
            );
          }

          final fallback = _getPageData(pageType);
          return WebLayout(
            child: _buildPageShell(
              context,
              isMobile: isMobile,
              isWideLayout: isWideLayout,
              title: fallback.title,
              content: fallback.content,
            ),
          );
        },
        loading: () {
          final fallback = _getPageData(pageType);
          return WebLayout(
            child: _buildPageShell(
              context,
              isMobile: isMobile,
              isWideLayout: isWideLayout,
              title: fallback.title,
              content: fallback.content,
            ),
          );
        },
        error: (_, __) {
          final fallback = _getPageData(pageType);
          return WebLayout(
            child: _buildPageShell(
              context,
              isMobile: isMobile,
              isWideLayout: isWideLayout,
              title: fallback.title,
              content: fallback.content,
            ),
          );
        },
      );
    }

    final pageData = _getPageData(pageType);
    return WebLayout(
      child: _buildPageShell(
        context,
        isMobile: isMobile,
        isWideLayout: isWideLayout,
        title: pageData.title,
        content: pageData.content,
      ),
    );
  }

  Widget _buildPageShell(
    BuildContext context, {
    required bool isMobile,
    required bool isWideLayout,
    required String title,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 40 : 60,
        horizontal: isMobile ? 20 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWideLayout ? 1100 : 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(height: 1, color: Colors.grey.shade300),
              const SizedBox(height: 32),
              content,
            ],
          ),
        ),
      ),
    );
  }

  bool _isDynamicPolicyPage(StaticPageType type) {
    return type == StaticPageType.terms ||
        type == StaticPageType.privacy ||
        type == StaticPageType.childProtection ||
        type == StaticPageType.help ||
        type == StaticPageType.refundPolicy;
  }

  String _pageSlug(StaticPageType type) {
    switch (type) {
      case StaticPageType.terms:
        return 'terms';
      case StaticPageType.privacy:
        return 'privacy';
      case StaticPageType.childProtection:
        return 'child-protection';
      case StaticPageType.help:
        return 'help';
      case StaticPageType.refundPolicy:
        return 'refund-policy';
      default:
        return '';
    }
  }

  Widget _buildDynamicAboutContent(AboutUsModel aboutUs, bool isMobile) {
    final subtitle = aboutUs.subtitle.trim();
    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFF59E0B).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
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
          aboutUs.title.trim().isNotEmpty
              ? aboutUs.title
              : 'Your Trusted Partner in\nLaundry Care.',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.playfairDisplay(
            fontSize: isMobile ? 36 : 54,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1E293B),
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            subtitle,
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3B82F6),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          aboutUs.description.trim().isNotEmpty
              ? aboutUs.description
              : 'We provide professional laundry and dry cleaning services with a focus on quality, convenience, and care.',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.inter(
            fontSize: 17,
            color: const Color(0xFF64748B),
            height: 1.7,
          ),
        ),
        const SizedBox(height: 24),
        if (aboutUs.experienceYears > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${aboutUs.experienceYears}+ Years Experience',
              style: GoogleFonts.inter(
                color: const Color(0xFF1D4ED8),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        const SizedBox(height: 32),
        if (aboutUs.points.isNotEmpty)
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

  Widget _buildDynamicAboutImage(String imageUrl, bool isMobile) {
    final trimmed = imageUrl.trim();
    if (trimmed.isEmpty) {
      return _buildAboutUsImages(isMobile);
    }

    final decodedBytes =
        isDataImageUrl(trimmed) ? decodeDataImage(trimmed) : null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: decodedBytes != null
            ? Image.memory(
                decodedBytes,
                width: double.infinity,
                height: isMobile ? 360 : 560,
                fit: BoxFit.cover,
              )
            : CachedNetworkImage(
                imageUrl: trimmed,
                width: double.infinity,
                height: isMobile ? 360 : 560,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: isMobile ? 360 : 560,
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => _buildAboutUsImages(isMobile),
              ),
      ),
    );
  }

  Widget _buildDynamicPolicyContent(
    BuildContext context,
    StaticPageModel page, {
    required _PageData fallback,
    required bool isMobile,
  }) {
    final body = page.body.trim().isNotEmpty ? page.body : '';
    final subtitle = page.subtitle.trim().isNotEmpty
        ? page.subtitle.trim()
        : fallback.title;
    final imageUrl = page.imageUrl.trim();
    final decodedBytes =
        isDataImageUrl(imageUrl) ? decodeDataImage(imageUrl) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (subtitle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: isMobile ? 15 : 16,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
        ),
        if (imageUrl.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: decodedBytes != null
                ? Image.memory(
                    decodedBytes,
                    width: double.infinity,
                    height: isMobile ? 180 : 280,
                    fit: BoxFit.cover,
                  )
                : CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: isMobile ? 180 : 280,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: isMobile ? 180 : 280,
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: isMobile ? 180 : 280,
                      color: Colors.grey.shade100,
                      child: const Center(child: Icon(Icons.image_not_supported)),
                    ),
                  ),
          ),
          const SizedBox(height: 28),
        ],
        if (body.isNotEmpty)
          ..._buildBodyBlocks(body)
        else
          fallback.content,
      ],
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
                    const Color(0xFF3B82F6).withOpacity(0.08),
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
            const Positioned(bottom: 0, left: 300, child: _FloatingStatsCard()),
        ],
      ),
    );
  }

  List<Widget> _buildBodyBlocks(String body) {
    final sections = body
        .split(RegExp(r'\n\s*\n'))
        .map((block) => block.trim())
        .where((block) => block.isNotEmpty)
        .toList();

    if (sections.isEmpty) {
      return [const SizedBox.shrink()];
    }

    final widgets = <Widget>[];
    for (final section in sections) {
      final lines = section
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
      if (lines.length > 1 && lines.every((line) => line.startsWith('- ') || line.startsWith('• '))) {
        widgets.add(_bulletList(lines.map((line) {
          return line.replaceFirst(RegExp(r'^[•-]\s*'), '').trim();
        }).where((line) => line.isNotEmpty).toList()));
        widgets.add(const SizedBox(height: 10));
        continue;
      }

      widgets.add(_paragraph(section));
    }

    return widgets;
  }

  Widget _bulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(Icons.fiber_manual_record, size: 8),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.6,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  _PageData _getPageData(StaticPageType type) {
    switch (type) {
      case StaticPageType.aboutUs:
        return _PageData(
          title: 'About Cloud Wash',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _paragraph(
                'Cloud Wash is India\'s premier laundry and dry cleaning service, providing doorstep pickup and delivery '
                'across major cities. Founded in 2024, our mission is to make laundry day hassle-free with professional '
                'garment care using world-class German eco-friendly solutions.',
              ),
              _paragraph(
                'What defines us is our commitment to quality. Every garment goes through our 6-stage care process - '
                'Sorting, Stain Treatment, Processing, Finishing, Quality Check, and Packing.',
              ),
              _heading('Our Vision'),
              _paragraph(
                'To be India\'s most trusted laundry brand, delivering fresh, clean clothes with care and convenience.',
              ),
              _heading('Our Mission'),
              _paragraph(
                'Provide professional laundry, dry cleaning, and specialty cleaning services with free pickup & delivery.',
              ),
              _heading('Our Services'),
              _paragraph(
                '• Laundry (Wash & Fold, Wash & Steam Iron)\n'
                '• Dry Cleaning (Designer Wear, Woollens, Silk)\n'
                '• Shoe Cleaning & Restoration\n'
                '• Leather Cleaning (Bags, Jackets, Belts)\n'
                '• Curtain & Carpet Cleaning',
              ),
            ],
          ),
        );

      case StaticPageType.terms:
        return _PageData(
          title: 'Terms & Conditions',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _paragraph('Last Updated: December 2024'),
              _heading('1. Introduction'),
              _paragraph(
                'Welcome to Cloud Wash. By using our website and app, you agree to these terms.',
              ),
              _heading('2. Service Bookings'),
              _paragraph(
                'Bookings are subject to professional availability. Cancellation fees may apply if cancelled within 2 hours of the scheduled time.',
              ),
              _heading('3. Payments'),
              _paragraph(
                'We accept credit cards, UPI, and cash. All payments are processed securely.',
              ),
              _heading('4. Liability'),
              _paragraph(
                'Cloud Wash facilitates the connection between customers and service providers. We are not liable for any damages caused during service delivery.',
              ),
            ],
          ),
        );

      case StaticPageType.privacy:
        return _PageData(
          title: 'Privacy Policy',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _paragraph(
                'Your privacy is important to us. This policy outlines how we collect, use, and protect your data.',
              ),
              _heading('Data Collection'),
              _paragraph(
                'We collect your name, phone number, and address to facilitate service delivery. Location data is used to match you with nearby professionals.',
              ),
              _heading('Data Security'),
              _paragraph(
                'We use industry-standard encryption to protect your personal information. We do not sell your data to third parties.',
              ),
              _heading('Your Rights'),
              _paragraph(
                'You have the right to access, correct, or delete your personal data at any time.',
              ),
            ],
          ),
        );

      case StaticPageType.contactUs:
        return _PageData(
          title: 'Contact Us',
          content: Builder(
            builder: (context) {
              final isMobile = MediaQuery.of(context).size.width < 1000;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _paragraph(
                    'We\'d love to hear from you. Reach out to us for any queries or feedback.',
                  ),
                  const SizedBox(height: 24),
                  _contactItem(
                    Icons.email_outlined,
                    'Email',
                    'help@cloudwash.com',
                    isMobile,
                  ),
                  _contactItem(
                    Icons.phone_outlined,
                    'Phone',
                    '+91 1800-123-4567',
                    isMobile,
                  ),
                  _contactItem(
                    Icons.location_on_outlined,
                    'Office',
                    'Cloud Wash HQ, Bangalore, 560038',
                    isMobile,
                  ),
                  const SizedBox(height: 32),
                  _heading('Business Hours'),
                  _paragraph(
                    'Monday - Saturday: 8:00 AM - 9:00 PM\nSunday: 9:00 AM - 6:00 PM',
                  ),
                ],
              );
            },
          ),
        );

      case StaticPageType.blog:
        return _PageData(
          title: 'Cloud Wash Blog',
          content: Builder(
            builder: (context) {
              final double screenWidth = MediaQuery.of(context).size.width;
              final bool isMobile = screenWidth < 1000;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _paragraph(
                    'Tips, tricks, and insights for garment care and laundry.',
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      SizedBox(
                        width: isMobile ? screenWidth - 40 : 520,
                        child: _blogCard(
                          'How to Keep Your White Clothes Bright',
                          'Expert tips on maintaining the brightness of your white garments...',
                          'https://images.unsplash.com/photo-1582735689369-4fe89db7114c?w=600',
                        ),
                      ),
                      SizedBox(
                        width: isMobile ? screenWidth - 40 : 520,
                        child: _blogCard(
                          'The Ultimate Guide to Dry Cleaning',
                          'When should you dry clean vs wash? Learn what fabrics need professional care...',
                          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600',
                        ),
                      ),
                      SizedBox(
                        width: isMobile ? screenWidth - 40 : 520,
                        child: _blogCard(
                          '5 Tips to Make Your Shoes Last Longer',
                          'Proper shoe care can extend the life of your footwear...',
                          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
                        ),
                      ),
                      SizedBox(
                        width: isMobile ? screenWidth - 40 : 520,
                        child: _blogCard(
                          'Caring for Leather Goods',
                          'Professional tips for maintaining your leather bags and jackets...',
                          'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600',
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );

      case StaticPageType.reviews:
        return _PageData(
          title: 'Customer Reviews',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _paragraph(
                'See what our happy customers have to say about our laundry services.',
              ),
              const SizedBox(height: 24),
              _reviewCard(
                5,
                '"Excellent laundry service! My clothes came back perfectly folded and smelling fresh. The pickup was right on time."',
                'Priya S., Bangalore',
              ),
              _reviewCard(
                5,
                '"Best dry cleaning I\'ve ever used. My silk sarees look brand new!"',
                'Deepika R., Mumbai',
              ),
              _reviewCard(
                5,
                '"Amazing shoe cleaning service. My white sneakers look spotless now. Highly recommend!"',
                'Rahul K., Delhi',
              ),
              _reviewCard(
                5,
                '"The curtain cleaning was fantastic. They handled my delicate curtains with care."',
                'Meera P., Hyderabad',
              ),
              _reviewCard(
                4,
                '"Great carpet cleaning! Removed all the stains and the carpet smells fresh."',
                'Amit S., Chennai',
              ),
            ],
          ),
        );

      case StaticPageType.childProtection:
        return _PageData(
          title: 'Child Protection Policy',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _paragraph('Last Updated: December 2024'),
              _paragraph(
                'At Cloud Wash, the safety and well-being of children are of paramount importance. This policy outlines our commitment to protecting children in the communities we serve.',
              ),
              _heading('1. Our Commitment'),
              _paragraph(
                'We are dedicated to maintaining a safe environment for everyone, especially minors. Our service professionals are trained to act with the highest level of integrity and respect when interacting with households where children are present.',
              ),
              _heading('2. Background Verifications'),
              _paragraph(
                'All Cloud Wash professionals undergo rigorous background checks and identity verification before being onboarded. This is to ensure that only trustworthy individuals are allowed access to our customers\' homes.',
              ),
              _heading('3. No Direct Interaction'),
              _paragraph(
                'Our services are intended for adults. We do not knowingly collect personal information from children under the age of 18. Service professionals are instructed to interact only with the adult customer who booked the service.',
              ),
              _heading('4. Reporting Concerns'),
              _paragraph(
                'If you have any concerns regarding the conduct of our staff or any potential safety issues involving a minor, please report it immediately to our 24/7 support team at safety@cloudwash.com.',
              ),
              _heading('5. Online Safety'),
              _paragraph(
                'Our digital platform is designed to be safe for all users. We implement strict security measures to prevent unauthorized access to customer data.',
              ),
            ],
          ),
        );

      case StaticPageType.help:
        return _PageData(
          title: 'Help & Support',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _paragraph(
                'Got questions? We\'re here to help you 24/7. Check out our common topics below or reach out to us directly.',
              ),
              _heading('Frequently Asked Topics'),
              _paragraph(
                '• How to track my order?\n'
                '• How do I reschedule a pickup?\n'
                '• What fabrics can be dry cleaned?\n'
                '• How to apply a coupon code?',
              ),
              _heading('Contact Support'),
              _paragraph(
                'Email: help@cloudwash.com\n'
                'Toll Free: 1800-123-4567\n'
                'WhatsApp: +91 9988776655',
              ),
              _heading('Service Hours'),
              _paragraph(
                'Our pickup and delivery agents operate from 8:00 AM to 9:00 PM every day.',
              ),
            ],
          ),
        );

      case StaticPageType.refundPolicy:
        return _PageData(
          title: 'Return & Refund Policy',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _paragraph('Last Updated: December 2024'),
              _paragraph(
                'At Cloud Wash, we strive for 100% customer satisfaction. If you\'re not happy with our service, here is our policy.',
              ),
              _heading('1. Rework Policy'),
              _paragraph(
                'If you\'re unsatisfied with the cleaning quality, we offer a "Free Rework". Please report the issue within 24 hours of delivery, and we will collect the garment for re-processing at no extra cost.',
              ),
              _heading('2. Cancellations'),
              _paragraph(
                'Cancellations made more than 2 hours before the scheduled pickup time are free. Late cancellations may incur a nominal fee of ₹50.',
              ),
              _heading('3. Refunds'),
              _paragraph(
                'For pre-paid orders: If a service is cancelled or cannot be fulfilled, a full refund will be processed to the original payment method within 5-7 business days.',
              ),
              _heading('4. Damage Policy'),
              _paragraph(
                'While we handle your clothes with extreme care, in the unlikely event of damage, our liability is limited to 10 times the cleaning cost of that specific item.',
              ),
            ],
          ),
        );
    }
  }

  Widget _paragraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          height: 1.6,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _heading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _contactItem(
    IconData icon,
    String label,
    String value,
    bool isMobile,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 24, color: AppTheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Icon(icon, size: 28, color: AppTheme.primary),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _blogCard(String title, String snippet, String imageUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 180,
                color: Colors.grey.shade200,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 180,
                color: Colors.grey.shade200,
                child: Center(
                  child: Icon(
                    Icons.image,
                    size: 50,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snippet,
                  style: TextStyle(color: Colors.grey.shade600, height: 1.5),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Read More',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(int stars, String review, String reviewer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < stars ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            review,
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '- $reviewer',
            style: const TextStyle(fontWeight: FontWeight.w600),
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

class _PageData {
  final String title;
  final Widget content;
  _PageData({required this.title, required this.content});
}
