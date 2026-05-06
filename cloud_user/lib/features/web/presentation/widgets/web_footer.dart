import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cloud_user/core/theme/app_theme.dart';
import 'package:cloud_user/core/utils/logo_cache_utils.dart';
import 'package:cloud_user/features/home/data/footer_model.dart';
import 'package:cloud_user/features/home/data/web_content_providers.dart';

class WebFooter extends ConsumerWidget {
  final String? logoUrl;
  final double logoHeight;

  const WebFooter({
    super.key,
    required this.logoUrl,
    required this.logoHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;
    final isDesktop = width >= 1024;

    final horizontalPadding = width * 0.05;

    final footerAsync = ref.watch(liveFooterProvider);
    final footer = footerAsync.valueOrNull;

    final exploreLinks = _resolveLinks(footer?.exploreLinks, [
      {'label': 'Home', 'route': '/'},
      {'label': 'About Us', 'route': '/about'},
      {'label': 'Services', 'route': '/services'},
      {'label': 'Membership', 'route': '/membership'},
      {'label': 'Blog', 'route': '/blog'},
    ]);

    final servicesLinks = _resolveLinks(footer?.serviceLinks, [
      {'label': 'Dry Cleaning', 'route': '/services'},
      {'label': 'Wash & Fold', 'route': '/services'},
      {'label': 'Shoe Restoration', 'route': '/services'},
      {'label': 'Leather Care', 'route': '/services'},
      {'label': 'Steam Ironing', 'route': '/services'},
    ]);

    final description =
        footer?.description ??
        'Redefining premium garment care with technology and craftsmanship. Your wardrobe deserves nothing but the best.';

    final phone = footer?.phone ?? '+91 98765 43210';

    final email = _resolveContactEmail(footer);

    final address =
        footer?.address ??
        'Suite 402, Laundry Lane,\nBangalore, KA 560001';

    final copyrightText =
        footer?.copyright ??
        '© ${DateTime.now().year} Cloud Wash. Crafted with precision.';

    final socialLinks =
        footer?.socialLinks ?? {'facebook': '', 'instagram': '', 'email': ''};

    final policyLinks = _resolveLinks(footer?.policyLinks, [
      {'label': 'Privacy Policy', 'route': '/privacy'},
      {'label': 'Terms of Service', 'route': '/terms'},
      {'label': 'Child Protection', 'route': '/child-protection'},
      {'label': 'Sitemap', 'route': '/'},
    ]);

    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFC),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 40 : 70,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            children: [
              Wrap(
                alignment: isMobile
                    ? WrapAlignment.center
                    : WrapAlignment.spaceBetween,
                runSpacing: 50,
                spacing: 50,
                children: [
                  SizedBox(
                    width: isMobile
                        ? width * 0.85
                        : isTablet
                        ? 350
                        : 420,
                    child: _buildBrandColumn(
                      isMobile,
                      logoUrl,
                      description,
                      socialLinks,
                      logoHeight,
                    ),
                  ),

                  SizedBox(
                    width: isMobile ? width * 0.4 : 180,
                    child: _buildFooterColumn(
                      'EXPLORE',
                      exploreLinks,
                      isCenter: isMobile,
                    ),
                  ),

                  SizedBox(
                    width: isMobile ? width * 0.4 : 180,
                    child: _buildFooterColumn(
                      'SERVICES',
                      servicesLinks,
                      isCenter: isMobile,
                    ),
                  ),

                  SizedBox(
                    width: isMobile
                        ? width * 0.85
                        : isTablet
                        ? 320
                        : 350,
                    child: _buildContactColumn(
                      isMobile,
                      phone,
                      email,
                      address,
                    ),
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 40 : 70),

              Container(
                height: 1,
                color: const Color(0xFFE2E8F0),
              ),

              SizedBox(height: isMobile ? 25 : 35),

              if (isMobile)
                Column(
                  children: [
                    _buildPolicyLinks(
                      policyLinks,
                      isMobile: true,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      copyrightText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        copyrightText,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    Flexible(
                      child: _buildPolicyLinks(
                        policyLinks,
                        isMobile: false,
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

  Widget _buildBrandColumn(
    bool isMobile,
    String? logoUrl,
    String description,
    Map<String, String>? socialLinks,
    double logoHeight,
  ) {
    final trimmedLogoUrl = (logoUrl ?? '').trim();

    final embeddedLogoBytes = _decodeDataImage(trimmedLogoUrl);

    final hasNetworkLogo =
        trimmedLogoUrl.isNotEmpty &&
        embeddedLogoBytes == null;

    return Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        embeddedLogoBytes != null
            ? Image.memory(
                embeddedLogoBytes,
                height: isMobile
                    ? logoHeight * 0.65
                    : logoHeight,
              )
            : hasNetworkLogo
            ? Image.network(
                withLogoCacheBust(trimmedLogoUrl),
                height: isMobile
                    ? logoHeight * 0.65
                    : logoHeight,
                errorBuilder: (_, __, ___) =>
                    Image.asset(
                  'assets/images/logo.png',
                  height: isMobile
                      ? logoHeight * 0.65
                      : logoHeight,
                ),
              )
            : Image.asset(
                'assets/images/logo.png',
                height: isMobile
                    ? logoHeight * 0.65
                    : logoHeight,
              ),

        const SizedBox(height: 25),

        Text(
          description,
          textAlign:
              isMobile ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.inter(
            color: const Color(0xFF475569),
            fontSize: isMobile ? 14 : 15,
            height: 1.8,
          ),
        ),

        const SizedBox(height: 30),

        Wrap(
          alignment: isMobile
              ? WrapAlignment.center
              : WrapAlignment.start,
          spacing: 12,
          runSpacing: 12,
          children: [
            if ((socialLinks?['facebook'] ?? '').isNotEmpty)
              const _SocialButton(
                icon: Icons.facebook_rounded,
                color: Color(0xFF1877F2),
              ),

            if ((socialLinks?['instagram'] ?? '').isNotEmpty)
              const _SocialButton(
                icon: Icons.camera_alt_rounded,
                color: Color(0xFFE1306C),
              ),

            if ((socialLinks?['mail'] ?? '').isNotEmpty)
              const _SocialButton(
                icon: Icons.email_rounded,
                color: Color(0xFF0EA5E9),
              ),
          ],
        ),
      ],
    );
  }

  Uint8List? _decodeDataImage(String imageUrl) {
    if (!imageUrl.startsWith('data:image')) return null;

    final commaIndex = imageUrl.indexOf(',');

    if (commaIndex == -1) return null;

    try {
      return base64Decode(
        imageUrl.substring(commaIndex + 1),
      );
    } catch (_) {
      return null;
    }
  }

  Widget _buildFooterColumn(
    String title,
    List<Map<String, String>> links, {
    bool isCenter = false,
  }) {
    return Column(
      crossAxisAlignment: isCenter
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            fontSize: 14,
            color: const Color(0xFF0F172A),
          ),
        ),

        const SizedBox(height: 25),

        ...links.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _FooterLink(
              label: link['label'] ?? '',
              route: link['route'] ?? '/',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactColumn(
    bool isMobile,
    String phone,
    String email,
    String address,
  ) {
    return Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          'CONTACT',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            fontSize: 14,
            color: const Color(0xFF0F172A),
          ),
        ),

        const SizedBox(height: 28),

        _buildContactItem(
          Icons.phone_iphone_rounded,
          phone,
          isMobile,
        ),

        const SizedBox(height: 18),

        _buildContactItem(
          Icons.email_rounded,
          email,
          isMobile,
        ),

        const SizedBox(height: 18),

        _buildContactItem(
          Icons.location_on_rounded,
          address,
          isMobile,
        ),
      ],
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String text,
    bool isMobile,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isMobile
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppTheme.primary,
          ),
        ),

        const SizedBox(width: 14),

        Flexible(
          child: Text(
            text,
            textAlign:
                isMobile ? TextAlign.center : TextAlign.start,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPolicyLinks(
    List<Map<String, String>> links, {
    required bool isMobile,
  }) {
    return Wrap(
      alignment: isMobile
          ? WrapAlignment.center
          : WrapAlignment.end,
      spacing: 20,
      runSpacing: 10,
      children: links
          .map(
            (link) => _MinimalLink(
              link['label'] ?? '',
              route: link['route'] ?? '/',
            ),
          )
          .toList(),
    );
  }
}

List<Map<String, String>> _resolveLinks(
  List<FooterLinkModel>? links,
  List<Map<String, String>> fallback,
) {
  if (links == null || links.isEmpty) return fallback;

  return links
      .map(
        (e) => {
          'label': e.label,
          'route': e.route,
        },
      )
      .toList();
}

String _resolveContactEmail(FooterModel? footer) {
  final socialLinks =
      footer?.socialLinks ?? const <String, String>{};

  return (socialLinks['mail'] ??
          socialLinks['email'] ??
          footer?.email ??
          'hello@cloudwash.com')
      .trim();
}

class _FooterLink extends StatefulWidget {
  final String label;
  final String route;

  const _FooterLink({
    required this.label,
    required this.route,
  });

  @override
  State<_FooterLink> createState() =>
      _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => context.go(widget.route),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: GoogleFonts.inter(
            color: _hover
                ? AppTheme.primary
                : const Color(0xFF64748B),
            fontSize: 14,
            fontWeight: _hover
                ? FontWeight.w600
                : FontWeight.w400,
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}

class _SocialButton extends StatefulWidget {
  final IconData icon;
  final Color color;

  const _SocialButton({
    required this.icon,
    required this.color,
  });

  @override
  State<_SocialButton> createState() =>
      _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _hover
              ? widget.color
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          widget.icon,
          color:
              _hover ? Colors.white : const Color(0xFF64748B),
          size: 20,
        ),
      ),
    );
  }
}

class _MinimalLink extends StatelessWidget {
  final String label;
  final String route;

  const _MinimalLink(
    this.label, {
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(route),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: const Color(0xFF94A3B8),
          fontSize: 13,
        ),
      ),
    );
  }
}