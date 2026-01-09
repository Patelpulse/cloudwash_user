import 'package:cloud_user/core/models/service_model.dart';
import 'package:cloud_user/core/theme/app_theme.dart';
import 'package:cloud_user/features/cart/data/addons_provider.dart';
import 'package:cloud_user/features/cart/data/cart_model.dart';
import 'package:cloud_user/features/cart/data/cart_provider.dart';
import 'package:cloud_user/features/cart/presentation/widgets/cart_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';

class ServiceDetailsScreen extends ConsumerStatefulWidget {
  final ServiceModel service;

  const ServiceDetailsScreen({super.key, required this.service});

  @override
  ConsumerState<ServiceDetailsScreen> createState() =>
      _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends ConsumerState<ServiceDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openCart() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final addonsAsync = ref.watch(addonsProvider);
    final cartState = ref.watch(cartProvider);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FB),
      endDrawer: const CartSidebar(),
      appBar: isDesktop
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Colors.black,
                ),
                onPressed: () => context.pop(),
              ),
              title: Text(
                widget.service.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.black),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.black,
                  ),
                  onPressed: _openCart,
                ),
                const SizedBox(width: 16),
              ],
            )
          : null,
      body: isDesktop
          ? _buildDesktopLayout(context, ref, addonsAsync, cartState)
          : _buildMobileLayout(context, ref, addonsAsync, cartState),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<dynamic>> addonsAsync,
    CartState cartState,
  ) {
    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- 1. PREMIUM IMAGE HEADER ---
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.width,
              pinned: true,
              stretch: true,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: Colors.black,
                    ),
                    onPressed: () => context.pop(),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    child: IconButton(
                      icon: const Icon(
                        Icons.shopping_cart_outlined,
                        size: 18,
                        color: Colors.black,
                      ),
                      onPressed: _openCart,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    child: IconButton(
                      icon: const Icon(
                        Icons.share_outlined,
                        size: 18,
                        color: Colors.black,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                ],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'service_${widget.service.id}',
                      child: CachedNetworkImage(
                        imageUrl:
                            widget.service.image ??
                            'https://via.placeholder.com/600',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, size: 64),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- 2. SERVICE MAIN INFO ---
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: _buildMainInfo(context),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                      child: Text(
                        'What\'s Included',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildIncludedSection(),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 40, 24, 16),
                      child: Text(
                        'Frequently Added Together',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildAddonsCarousel(addonsAsync, cartState, ref),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
        _buildBottomAction(context, ref),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<dynamic>> addonsAsync,
    CartState cartState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Image Gallery
              Expanded(
                flex: 1,
                child: Hero(
                  tag: 'service_${widget.service.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CachedNetworkImage(
                        imageUrl:
                            widget.service.image ??
                            'https://via.placeholder.com/800',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, size: 64),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 40),
              // Right: Content & Action
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMainInfo(context),
                    const SizedBox(height: 32),
                    const Text(
                      'What\'s Included',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildIncludedSection(),
                    const SizedBox(height: 48),
                    // Desktop Action Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Price',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '₹${widget.service.price}',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  ref
                                      .read(cartProvider.notifier)
                                      .addToCart(widget.service);
                                  _openCart();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text(
                                  'Add to Cart',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Row(
                            children: [
                              Icon(
                                Icons.flash_on,
                                color: Colors.orange,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Fastest booking available for today',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          const Text(
            'Frequently Added Together',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildAddonsCarousel(addonsAsync, cartState, ref, isDesktop: true),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildMainInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'POPULAR',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${widget.service.rating ?? 4.8}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  ' (${widget.service.reviewCount ?? 120}+)',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.service.title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.timer_outlined, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              '${widget.service.duration ?? 60} minutes',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(width: 20),
            Icon(Icons.eco_outlined, size: 16, color: Colors.green.shade600),
            const SizedBox(width: 4),
            Text(
              'Eco Friendly',
              style: TextStyle(color: Colors.green.shade600),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'About Service',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          widget.service.description ??
              'Experience ultimate cleanliness with our professional service. We use premium products and cutting-edge techniques to ensure your satisfaction.',
          style: TextStyle(
            color: Colors.grey.shade700,
            height: 1.6,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildIncludedSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _IncludedRow(Icons.check_circle, 'Deep sterilization'),
          const SizedBox(height: 12),
          _IncludedRow(Icons.check_circle, 'Professional equipment'),
          const SizedBox(height: 12),
          _IncludedRow(Icons.check_circle, 'Background verified staff'),
          const SizedBox(height: 12),
          _IncludedRow(Icons.check_circle, 'Insurance coverage'),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context, WidgetRef ref) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Price',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      '₹${widget.service.price}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(cartProvider.notifier).addToCart(widget.service);
                      _openCart();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddonsCarousel(
    AsyncValue<List<dynamic>> addonsAsync,
    CartState cartState,
    WidgetRef ref, {
    bool isDesktop = false,
  }) {
    return addonsAsync.when(
      data: (addons) {
        final filtered = addons.where((a) {
          if (cartState.selectedAddons.any((sa) => sa.id == a.id)) return false;
          bool matchesCategory = a.category == widget.service.category;
          bool matchesSubCategory =
              a.subCategory != null &&
              a.subCategory == widget.service.subCategory;
          return matchesCategory || matchesSubCategory;
        }).toList();

        if (filtered.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: isDesktop ? 220 : 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 24),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final addon = filtered[index];
              return _AddonCarouselItem(
                addon: addon,
                isDesktop: isDesktop,
                onAdd: () {
                  ref.read(cartProvider.notifier).toggleAddon(addon);
                  _openCart();
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _IncludedRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IncludedRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _AddonCarouselItem extends StatelessWidget {
  final dynamic addon;
  final VoidCallback onAdd;
  final bool isDesktop;

  const _AddonCarouselItem({
    required this.addon,
    required this.onAdd,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isDesktop ? 180 : 150,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: CachedNetworkImage(
                imageUrl: addon.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade100,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => const Icon(Icons.image),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  addon.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 16 : 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${addon.price}',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: isDesktop ? 16 : 14,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.add_circle,
                        color: AppTheme.primary,
                        size: isDesktop ? 28 : 24,
                      ),
                      onPressed: onAdd,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
