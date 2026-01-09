import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_user/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1000;

    return Container(
      color: const Color(0xFFF1F5F9), // Light Slate
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 30 : 50, 
        horizontal: isMobile ? 20 : 40
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1300),
          child: Column(
            children: [
              if (isMobile)
                Column(
                  children: [
                    _buildBrandColumn(isMobile),
                    const SizedBox(height: 60),
                    _buildFooterGrid(isMobile),
                    const SizedBox(height: 60),
                    _buildContactColumn(isMobile),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildBrandColumn(isMobile)),
                    const SizedBox(width: 100),
                    Expanded(child: _buildFooterColumn('EXPLORE', [
                      {'label': 'Home', 'route': '/'},
                      {'label': 'About Us', 'route': '/about'},
                      {'label': 'Services', 'route': '/services'},
                      {'label': 'Membership', 'route': '/membership'},
                      {'label': 'Blog', 'route': '/blog'},
                    ])),
                    Expanded(child: _buildFooterColumn('SERVICES', [
                      {'label': 'Dry Cleaning', 'route': '/services'},
                      {'label': 'Wash & Fold', 'route': '/services'},
                      {'label': 'Shoe Restoration', 'route': '/services'},
                      {'label': 'Leather Care', 'route': '/services'},
                      {'label': 'Steam Ironing', 'route': '/services'},
                    ])),
                    Expanded(flex: 1, child: _buildContactColumn(isMobile)),
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
                    const Text(
                      '© 2025 Cloud Wash. Crafted with precision.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 10,
                      children: [
                        _MinimalLink('Privacy Policy', route: '/privacy'),
                        _MinimalLink('Terms of Service', route: '/terms'),
                        _MinimalLink('Child Protection', route: '/child-protection'),
                        _MinimalLink('Sitemap', route: '/'),
                      ],
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '© 2025 Cloud Wash. Crafted with precision.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                    Row(
                      children: [
                        _MinimalLink('Privacy Policy', route: '/privacy'),
                        const SizedBox(width: 32),
                        _MinimalLink('Terms of Service', route: '/terms'),
                        const SizedBox(width: 32),
                        _MinimalLink('Child Protection', route: '/child-protection'),
                        const SizedBox(width: 32),
                        _MinimalLink('Sitemap', route: '/'),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandColumn(bool isMobile) {
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
             Image.asset(
               'assets/images/logo.png',
               height: isMobile ? 100 : 140,
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
          'Redefining premium garment care with technology and craftsmanship. Your wardrobe deserves nothing but the best.',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 16,
            height: 1.8,
          ),
        ),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            _SocialButton(icon: Icons.facebook_rounded, color: const Color(0xFF3B82F6)),
            const SizedBox(width: 12),
            _SocialButton(icon: Icons.camera_alt_rounded, color: const Color(0xFFEC4899)),
            const SizedBox(width: 12),
            _SocialButton(icon: Icons.alternate_email_rounded, color: const Color(0xFF10B981)),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterGrid(bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildFooterColumn('EXPLORE', [
            {'label': 'Home', 'route': '/'},
            {'label': 'About Us', 'route': '/about'},
            {'label': 'Services', 'route': '/services'},
            {'label': 'Membership', 'route': '/membership'},
            {'label': 'Blog', 'route': '/blog'},
          ], isCenter: isMobile),
        ),
        Expanded(
          child: _buildFooterColumn('SERVICES', [
            {'label': 'Dry Cleaning', 'route': '/services'},
            {'label': 'Wash & Fold', 'route': '/services'},
            {'label': 'Shoe Restoration', 'route': '/services'},
            {'label': 'Leather Care', 'route': '/services'},
            {'label': 'Steam Ironing', 'route': '/services'},
          ], isCenter: isMobile),
        ),
      ],
    );
  }

  Widget _buildFooterColumn(String title, List<Map<String, String>> links, {bool isCenter = false}) {
    return Column(
      crossAxisAlignment: isCenter ? CrossAxisAlignment.center : CrossAxisAlignment.start,
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
        ...links.map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _FooterLink(link['label']!),
        )).toList(),
      ],
    );
  }

  Widget _buildContactColumn(bool isMobile) {
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
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
        _buildContactItem(Icons.phone_rounded, '+91 98765 43210', isMobile),
        const SizedBox(height: 20),
        _buildContactItem(Icons.email_rounded, 'hello@cloudwash.com', isMobile),
        const SizedBox(height: 20),
        _buildContactItem(
          Icons.location_on_rounded, 
          'Suite 402, Laundry Lane,\nBangalore, KA 560001',
          isMobile,
        ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text, bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF818CF8), size: 20),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            text,
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: const TextStyle(color: Color(0xFF475569), fontSize: 15, height: 1.5),
          ),
        ),
      ],
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String label;
  const _FooterLink(this.label);

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
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          color: _isHovered ? const Color(0xFF818CF8) : const Color(0xFF64748B),
          fontSize: 15,
          fontWeight: _isHovered ? FontWeight.bold : FontWeight.normal,
        ),
        child: Text(widget.label),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isHovered ? widget.color : Colors.black.withValues(alpha: 0.05),
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
