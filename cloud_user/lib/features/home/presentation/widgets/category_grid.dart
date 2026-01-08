import 'package:cloud_user/core/models/category_model.dart';
import 'package:cloud_user/features/home/data/home_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CategoryGrid extends ConsumerWidget {
  const CategoryGrid({super.key});

  // Color palette for categories (pastel backgrounds)
  static const List<Color> _categoryColors = [
    Color(0xFFE3F2FD), // Light Blue
    Color(0xFFFFF3E0), // Light Orange
    Color(0xFFE8F5E9), // Light Green
    Color(0xFFFCE4EC), // Light Pink
    Color(0xFFE0F7FA), // Light Cyan
    Color(0xFFF3E5F5), // Light Purple
  ];

  // Icon mapping for categories
  static IconData _getCategoryIcon(String name) {
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
      case 'ac':
        return Icons.ac_unit;
      case 'pest control':
        return Icons.bug_report;
      default:
        return Icons.home_repair_service;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      data: (categories) => LayoutBuilder(
        builder: (context, constraints) {
          // Responsive: 2 columns on mobile, 3-4 on tablet, 6 on desktop
          int crossAxisCount = 2;
          if (constraints.maxWidth > 600) crossAxisCount = 3;
          if (constraints.maxWidth > 900) crossAxisCount = 4;
          if (constraints.maxWidth > 1200) crossAxisCount = 6;

          return GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.0,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final bgColor = _categoryColors[index % _categoryColors.length];
              return _CategoryCard(
                category: category,
                backgroundColor: bgColor,
                icon: _getCategoryIcon(category.name),
                onTap: () => context.push(
                  '/category/${category.id}',
                  extra: category.name,
                ),
              );
            },
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final CategoryModel category;
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.backgroundColor,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? Colors.black.withOpacity(0.15)
                    : Colors.black.withOpacity(0.05),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  widget.icon,
                  size: 32,
                  color: HSLColor.fromColor(
                    widget.backgroundColor,
                  ).withLightness(0.3).toColor(),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.category.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
