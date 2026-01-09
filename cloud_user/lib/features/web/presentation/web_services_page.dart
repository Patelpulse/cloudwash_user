import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_user/core/theme/app_theme.dart';
import 'package:cloud_user/features/home/data/home_providers.dart';
import 'package:cloud_user/features/web/presentation/web_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WebServicesPage extends ConsumerWidget {
  const WebServicesPage({super.key});

  // Category icon mapping
  IconData _getCategoryIcon(String name) {
    switch (name.toLowerCase()) {
      case 'cleaning':
        return Icons.cleaning_services;
      case 'repair':
        return Icons.build;
      case 'painting':
        return Icons.format_paint;
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical':
        return Icons.electrical_services;
      case 'carpentry':
        return Icons.carpenter;
      case 'ac repair':
        return Icons.ac_unit;
      case 'pest control':
        return Icons.bug_report;
      case 'home salon':
        return Icons.content_cut;
      case 'gardening':
        return Icons.grass;
      case 'car wash':
        return Icons.local_car_wash;
      case 'laundry':
        return Icons.local_laundry_service;
      default:
        return Icons.home_repair_service;
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
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1000;

    return WebLayout(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 40 : 60,
          horizontal: isMobile ? 20 : 40,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Our Services',
                  style: TextStyle(
                    fontSize: isMobile ? 32 : 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Professional home services at your doorstep',
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 40),

                // Categories Grid
                categoriesAsync.when(
                  data: (categories) => Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: categories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final category = entry.value;
                      return _ServiceCategoryCard(
                        name: category.name,
                        imageUrl: category.imageUrl, // Pass image URL
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
                    }).toList(),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Text('Error loading services: $err'),
                ),

                const SizedBox(height: 80),

                // How It Works Section
                Text(
                  'How It Works',
                  style: TextStyle(
                    fontSize: isMobile ? 24 : 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                isMobile
                    ? Column(
                        children: [
                          _StepCard(
                            number: '1',
                            title: 'Choose Service',
                            description:
                                'Select the service you need from our wide range of categories.',
                          ),
                          const SizedBox(height: 20),
                          _StepCard(
                            number: '2',
                            title: 'Book Time Slot',
                            description:
                                'Pick a convenient date and time that works for you.',
                          ),
                          const SizedBox(height: 20),
                          _StepCard(
                            number: '3',
                            title: 'Get It Done',
                            description:
                                'Our verified professional arrives and completes the job.',
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _StepCard(
                              number: '1',
                              title: 'Choose Service',
                              description:
                                  'Select the service you need from our wide range of categories.',
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _StepCard(
                              number: '2',
                              title: 'Book Time Slot',
                              description:
                                  'Pick a convenient date and time that works for you.',
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _StepCard(
                              number: '3',
                              title: 'Get It Done',
                              description:
                                  'Our verified professional arrives and completes the job.',
                            ),
                          ),
                        ],
                      ),

                const SizedBox(height: 80),

                // CTA Section
                Container(
                  padding: EdgeInsets.all(isMobile ? 24 : 40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Need a Custom Service?',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Can't find what you're looking for? Contact us for custom solutions.",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => context.push('/contact'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppTheme.primary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: const Text(
                                  'Contact Us',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
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
                                  const Text(
                                    'Need a Custom Service?',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Can't find what you're looking for? Contact us for custom solutions.",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => context.push('/contact'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppTheme.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                              ),
                              child: const Text(
                                'Contact Us',
                                style: TextStyle(fontWeight: FontWeight.bold),
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

  String _getDescription(String name) {
    switch (name.toLowerCase()) {
      case 'cleaning':
        return 'Deep cleaning, bathroom, kitchen & more';
      case 'repair':
        return 'General home repairs and fixes';
      case 'painting':
        return 'Interior & exterior painting';
      case 'plumbing':
        return 'Leaks, installations & repairs';
      case 'electrical':
        return 'Wiring, fixtures & repairs';
      case 'carpentry':
        return 'Furniture repair & custom work';
      case 'ac repair':
        return 'Service, repair & installation';
      case 'pest control':
        return 'Cockroach, termite & pest removal';
      default:
        return 'Professional service at your doorstep';
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
    final bool isMobile = MediaQuery.of(context).size.width < 1000;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isMobile ? (MediaQuery.of(context).size.width - 64) / 2 : 280,
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          transform: Matrix4.identity()..scale(_hovered ? 1.03 : 1.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _hovered
                    ? Colors.black.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: _hovered ? 20 : 10,
                offset: Offset(0, _hovered ? 10 : 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: widget.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: widget.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: widget.bgColor,
                            child: Icon(
                              widget.icon,
                              size: 32,
                              color: HSLColor.fromColor(widget.bgColor)
                                  .withLightness(0.5) // Darker for visibility
                                  .toColor(),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Icon(
                            widget.icon,
                            size: 32,
                            color: HSLColor.fromColor(
                              widget.bgColor,
                            ).withLightness(0.3).toColor(),
                          ),
                        ),
                      )
                    : Icon(
                        widget.icon,
                        size: 32,
                        color: HSLColor.fromColor(
                          widget.bgColor,
                        ).withLightness(0.3).toColor(),
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.description,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'View Services',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16, color: AppTheme.primary),
                ],
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(description, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
