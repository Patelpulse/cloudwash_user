import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_user/features/home/data/home_providers.dart';
import 'package:cloud_user/core/models/sub_category_model.dart';
import 'package:cloud_user/features/web/presentation/web_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WebSubCategoriesScreen extends ConsumerWidget {
  final String categoryId;
  final String categoryName;

  const WebSubCategoriesScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subCategoriesAsync = ref.watch(
      subCategoriesByCategoryProvider(categoryId),
    );

    return WebLayout(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Select a sub-category to explore services',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 40),
                subCategoriesAsync.when(
                  data: (data) {
                    if (data.isEmpty) {
                      return const Center(
                        child: Text('No sub-categories found.'),
                      );
                    }

                    // Responsive grid
                    final width = MediaQuery.of(context).size.width;
                    int crossAxisCount;
                    if (width < 600) {
                      crossAxisCount = 2; // Mobile
                    } else if (width < 900) {
                      crossAxisCount = 3; // Tablet
                    } else {
                      crossAxisCount = 4; // Desktop
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: width < 600 ? 0.7 : 0.8,
                      ),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return _SubCategoryCard(item: data[index]);
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, stack) => Center(child: Text('Error: $e')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubCategoryCard extends StatelessWidget {
  final SubCategoryModel item;

  const _SubCategoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          context.push('/services-list/${item.id}', extra: item.name);
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Badge
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade100,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey.shade100,
                        child: const Icon(
                          Icons.dry_cleaning,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.description ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
