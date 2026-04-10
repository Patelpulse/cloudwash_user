import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_user/core/theme/app_theme.dart';
import 'package:cloud_user/core/utils/logo_cache_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_user/features/home/data/footer_model.dart';
import 'package:cloud_user/features/home/data/web_content_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

List<Map<String, String>> _resolveLinks(
  List<FooterLinkModel>? links,
  List<Map<String, String>> fallback,
) {
  if (links == null || links.isEmpty) return fallback;

  final mapped = links
      .map(
        (e) => {'label': e.label, 'route': e.route},
      )
      .where((link) => (link['label'] ?? '').trim().isNotEmpty)
      .toList();

  return mapped.isEmpty ? fallback : mapped;
}

String _resolveContactEmail(FooterModel? footer) {
  final socialLinks = footer?.socialLinks ?? const <String, String>{};
  final supportMail = (socialLinks['mail'] ?? '').trim();
  if (supportMail.isNotEmpty) return supportMail;

  final socialEmail = (socialLinks['email'] ?? '').trim();
  if (socialEmail.isNotEmpty) return socialEmail;

  final directEmail = (footer?.email ?? '').trim();
  if (directEmail.isNotEmpty) return directEmail;

  return 'hello@cloudwash.com';
}

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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1000;
    final footerAsync = ref.watch(liveFooterProvider);
    final footer = footerAsync.valueOrNull;

    final exploreLinks = _resolveLinks(
      footer?.exploreLinks,
      [
        {'label': 'Home', 'route': '/'},
        {'label': 'About Us', 'route': '/about'},
        {'label': 'Services', 'route': '/services'},
        {'label': 'Membership', 'route': '/membership'},
        {'label': 'Blog', 'route': '/blog'},
      ],
    );
    final servicesLinks = _resolveLinks(
      footer?.serviceLinks,
      [
        {'label': 'Dry Cleaning', 'route': '/services'},
        {'label': 'Wash & Fold', 'route': '/services'},
        {'label': 'Shoe Restoration', 'route': '/services'},
        {'label': 'Leather Care', 'route': '/services'},
        {'label': 'Steam Ironing', 'route': '/services'},
      ],
    );

    final description = footer?.description ??
        'Redefining premium garment care with technology and craftsmanship. Your wardrobe deserves nothing but the best.';
    final phone = footer?.phone ?? '+91 98765 43210';
    final email = _resolveContactEmail(footer);
    final address =
        footer?.address ?? 'Suite 402, Laundry Lane,\nBangalore, KA 560001';
    final copyrightText = footer?.copyright ??
        '© ${DateTime.now().year} Cloud Wash. Crafted with precision.';
    final socialLinks =
        footer?.socialLinks ?? {'facebook': '', 'instagram': '', 'email': ''};
    final policyLinks = _resolveLinks(
      footer?.policyLinks,
      [
        {'label': 'Privacy Policy', 'route': '/privacy'},
        {'label': 'Terms of Service', 'route': '/terms'},
        {'label': 'Child Protection', 'route': '/child-protection'},
        {'label': 'Sitemap', 'route': '/'},
      ],
    );

    return Container(
      color: const Color(0xFFF1F5F9), // Light Slate
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 30 : 50,
        horizontal: isMobile ? 20 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1300),
          child: Column(
            children: [
              if (isMobile)
                Column(
                  children: [
                    _buildBrandColumn(
                      isMobile,
                      logoUrl,
                      description,
                      socialLinks,
                      logoHeight,
                    ),
                    const SizedBox(height: 60),
                    _buildFooterGrid(isMobile, exploreLinks, servicesLinks),
                    const SizedBox(height: 60),
                    _buildContactColumn(isMobile, phone, email, address),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildBrandColumn(
                        isMobile,
                        logoUrl,
                        description,
                        socialLinks,
                        logoHeight,
                      ),
                    ),
                    const SizedBox(width: 100),
                    Expanded(
                      child: _buildFooterColumn('EXPLORE', exploreLinks),
                    ),
                    Expanded(
                      child: _buildFooterColumn('SERVICES', servicesLinks),
                    ),
                    Expanded(
                      flex: 1,
                      child: _buildContactColumn(
                        isMobile,
                        phone,
                        email,
                        address,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 60),
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.black.withValues(alpha: 0.05),
              ),
              const SizedBox(height: 48),
              if (isMobile)
                Column(
                  children: [
                    Text(
                      copyrightText,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildPolicyLinks(policyLinks, isMobile: true),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      copyrightText,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                      ),
                    ),
                    _buildPolicyLinks(policyLinks, isMobile: false),
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
        trimmedLogoUrl.isNotEmpty && embeddedLogoBytes == null;
    final double targetHeight =
        (isMobile ? logoHeight * 0.7 : logoHeight).clamp(24, 220);
    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            embeddedLogoBytes != null
                ? Image.memory(
                    embeddedLogoBytes,
                    height: targetHeight,
                    fit: BoxFit.contain,
                  )
                : hasNetworkLogo
                    ? Image.network(
                        withLogoCacheBust(trimmedLogoUrl),
                        height: targetHeight,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/logo.png',
                          height: targetHeight,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Image.asset(
                        'assets/images/logo.png',
                        height: targetHeight,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Text(
                          'CLINOWASH',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 32 : 44,
                            color: AppTheme.primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          description,
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 16,
            height: 1.8,
          ),
        ),
        const SizedBox(height: 48),
        if ((socialLinks ?? {}).isNotEmpty)
          Row(
            mainAxisAlignment:
                isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              if ((socialLinks?['facebook'] ?? '').isNotEmpty) ...[
                const _SocialButton(
                  icon: Icons.facebook_rounded,
                  color: Color(0xFF3B82F6),
                ),
                const SizedBox(width: 12),
              ],
              if ((socialLinks?['instagram'] ?? '').isNotEmpty) ...[
                const _SocialButton(
                  icon: Icons.camera_alt_rounded,
                  color: Color(0xFFEC4899),
                ),
                const SizedBox(width: 12),
              ],
              if ((socialLinks?['mail'] ?? '').isNotEmpty ||
                  (socialLinks?['email'] ?? '').isNotEmpty)
                const _SocialButton(
                  icon: Icons.alternate_email_rounded,
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
    if (commaIndex == -1 || commaIndex >= imageUrl.length - 1) return null;
    try {
      return base64Decode(imageUrl.substring(commaIndex + 1));
    } catch (_) {
      return null;
    }
  }

  Widget _buildFooterGrid(
    bool isMobile,
    List<Map<String, String>> explore,
    List<Map<String, String>> services,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildFooterColumn('EXPLORE', explore, isCenter: isMobile),
        ),
        Expanded(
          child: _buildFooterColumn('SERVICES', services, isCenter: isMobile),
        ),
      ],
    );
  }

  Widget _buildFooterColumn(
    String title,
    List<Map<String, String>> links, {
    bool isCenter = false,
  }) {
    return Column(
      crossAxisAlignment:
          isCenter ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: const Color(0xFF1E293B),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 24),
        ...links
            .map(
              (link) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
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
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          'CONTACT',
          style: GoogleFonts.inter(
            color: const Color(0xFF1E293B),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 32),
        _buildContactItem(Icons.phone_rounded, phone, isMobile),
        const SizedBox(height: 20),
        _buildContactItem(Icons.email_rounded, email, isMobile),
        const SizedBox(height: 20),
        _buildContactItem(Icons.location_on_rounded, address, isMobile),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text, bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF3B82F6), size: 20),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            text,
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 15,
              height: 1.5,
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
      alignment: isMobile ? WrapAlignment.center : WrapAlignment.end,
      spacing: isMobile ? 20 : 32,
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

class _FooterLink extends StatefulWidget {
  final String label;
  final String route;
  const _FooterLink({required this.label, required this.route});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.route),
        child: Text(
          widget.label,
          style: TextStyle(
            color:
                _isHovered ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
            fontSize: 15,
            fontWeight: _isHovered ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  const _SocialButton({required this.icon, required this.color});

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              _isHovered ? widget.color : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          widget.icon,
          color: _isHovered ? Colors.white : const Color(0xFF64748B),
          size: 20,
        ),
      ),
    );
  }
}

class _MinimalLink extends StatelessWidget {
  final String label;
  final String route;
  const _MinimalLink(this.label, {required this.route});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(route),
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      ),
    );
  }
}
