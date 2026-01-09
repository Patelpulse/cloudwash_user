import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_user/core/models/banner_model.dart';
import 'package:cloud_user/core/models/category_model.dart';
import 'package:cloud_user/core/models/service_model.dart';
import 'package:cloud_user/core/models/sub_category_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class HomeShimmerLoading extends StatelessWidget {
  const HomeShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    // Generate Full Demo Data
    final demoCategories = _getDemoCategories();
    final demoBanners = _getDemoBanners();
    final demoSpotlight = _getDemoServices().take(5).toList();
    final demoTopServices = _getDemoServices().skip(5).toList();
    final demoSubCategories = _getDemoSubCategories();

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      enabled: true,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Section Shimmer
            Container(height: 300, width: double.infinity, color: Colors.white),

            const SizedBox(height: 20),

            // 2. Categories Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Services'),
                  const SizedBox(height: 15),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: demoCategories.length,
                    itemBuilder: (context, index) {
                      final cat = demoCategories[index];
                      return Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: cat.imageUrl.isNotEmpty
                                  ? Image.network(
                                      cat.imageUrl,
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cat.name,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 3. Banners
            CarouselSlider.builder(
              itemCount: demoBanners.length,
              options: CarouselOptions(
                height: 180,
                viewportFraction: 0.9,
                enlargeCenterPage: true,
              ),
              itemBuilder: (context, index, realIndex) {
                final banner = demoBanners[index];
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: banner.imageUrl.isNotEmpty
                      ? Image.network(banner.imageUrl, fit: BoxFit.cover)
                      : null,
                );
              },
            ),

            const SizedBox(height: 30),

            // 4. Spotlight Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Spotlight'),
                  const SizedBox(height: 15),
                  CarouselSlider.builder(
                    itemCount: demoSpotlight.length,
                    options: CarouselOptions(
                      height: 280,
                      viewportFraction: 0.65,
                      enlargeCenterPage: true,
                    ),
                    itemBuilder: (context, index, realIndex) {
                      return _buildSpotlightCard(demoSpotlight[index]);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 5. Top Services (Grid)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Top Services'),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 15,
                        ),
                    itemCount: demoTopServices.length,
                    itemBuilder: (context, index) {
                      return _buildServiceGridCard(demoTopServices[index]);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 6. Sub Categories
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('SUB CATEGORIES'),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: demoSubCategories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 15),
                      itemBuilder: (context, index) {
                        return _buildSubCategoryCard(demoSubCategories[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(width: 150, height: 24, color: Colors.white),
    );
  }

  Widget _buildSpotlightCard(ServiceModel service) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (service.image != null && service.image!.isNotEmpty)
            Image.network(service.image!, fit: BoxFit.cover),

          // Overlay to ensure text is visible even if image loads
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                stops: const [0.0, 0.6],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 20,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 60,
                      height: 24,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
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

  Widget _buildServiceGridCard(ServiceModel service) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.grey, // Placeholder for image
              ),
              child: (service.image != null && service.image!.isNotEmpty)
                  ? Image.network(service.image!, fit: BoxFit.cover)
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 100, height: 14, color: Colors.grey[300]),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 50, height: 18, color: Colors.grey[300]),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
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

  Widget _buildSubCategoryCard(SubCategoryModel cat) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (cat.imageUrl.isNotEmpty)
            Image.network(cat.imageUrl, fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.1)),
        ],
      ),
    );
  }

  // --- Mock Data Generators ---

  List<CategoryModel> _getDemoCategories() {
    return [
      CategoryModel(
        id: '1',
        name: 'Wash & Fold',
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/3003/3003984.png',
        description: '',
        price: 0,
        isActive: true,
      ),
      CategoryModel(
        id: '2',
        name: 'Dry Clean',
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/2954/2954835.png',
        description: '',
        price: 0,
        isActive: true,
      ),
      CategoryModel(
        id: '3',
        name: 'Ironing',
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/2954/2954930.png',
        description: '',
        price: 0,
        isActive: true,
      ),
      CategoryModel(
        id: '4',
        name: 'Shoe Care',
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/2523/2523961.png',
        description: '',
        price: 0,
        isActive: true,
      ),
      CategoryModel(
        id: '5',
        name: 'Duvet',
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/2954/2954898.png',
        description: '',
        price: 0,
        isActive: true,
      ),
      CategoryModel(
        id: '6',
        name: 'Curtains',
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/2954/2954884.png',
        description: '',
        price: 0,
        isActive: true,
      ),
      CategoryModel(
        id: '7',
        name: 'Accessories',
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/2954/2954906.png',
        description: '',
        price: 0,
        isActive: true,
      ),
      CategoryModel(
        id: '8',
        name: 'Others',
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/2954/2954911.png',
        description: '',
        price: 0,
        isActive: true,
      ),
    ];
  }

  List<BannerModel> _getDemoBanners() {
    return [
      BannerModel(
        id: '1',
        title: '50% Off First Order',
        description: 'Use code FIRST50',
        imageUrl:
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
        position: 'home',
        displayOrder: 1,
        isActive: true,
      ),
      BannerModel(
        id: '2',
        title: 'Express Delivery',
        description: 'Get it in 24 hours',
        imageUrl:
            'https://images.unsplash.com/photo-1582735689369-4fe89db7114c?w=600',
        position: 'home',
        displayOrder: 2,
        isActive: true,
      ),
    ];
  }

  List<SubCategoryModel> _getDemoSubCategories() {
    return [
      SubCategoryModel(
        id: '1',
        name: 'Men',
        imageUrl:
            'https://images.unsplash.com/photo-1617137968427-85924c809a10?w=600',
        price: 0,
      ),
      SubCategoryModel(
        id: '2',
        name: 'Women',
        imageUrl:
            'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=600',
        price: 0,
      ),
      SubCategoryModel(
        id: '3',
        name: 'Kids',
        imageUrl:
            'https://images.unsplash.com/photo-1622290291410-85fbdcd7a242?w=600',
        price: 0,
      ),
      SubCategoryModel(
        id: '4',
        name: 'Household',
        imageUrl:
            'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=600',
        price: 0,
      ),
    ];
  }

  List<ServiceModel> _getDemoServices() {
    return [
      ServiceModel(
        id: '1',
        title: 'Premium Suit Clean',
        category: 'Dry Clean',
        price: 499,
        rating: 4.8,
        image:
            'https://images.pexels.com/photos/6764007/pexels-photo-6764007.jpeg?auto=compress&w=600',
      ),
      ServiceModel(
        id: '2',
        title: 'Silk Saree Polish',
        category: 'Saree',
        price: 399,
        rating: 4.9,
        image:
            'https://images.pexels.com/photos/1598505/pexels-photo-1598505.jpeg?auto=compress&w=600',
      ),
      ServiceModel(
        id: '3',
        title: 'Leather Jacket',
        category: 'Leather',
        price: 999,
        rating: 4.7,
        image:
            'https://images.pexels.com/photos/1124468/pexels-photo-1124468.jpeg?auto=compress&w=600',
      ),
      ServiceModel(
        id: '4',
        title: 'Quilt Wash',
        category: 'Bedding',
        price: 599,
        rating: 4.6,
        image:
            'https://images.pexels.com/photos/4439425/pexels-photo-4439425.jpeg?auto=compress&w=600',
      ),
      ServiceModel(
        id: '5',
        title: 'Blanket',
        category: 'Bedding',
        price: 499,
        rating: 4.5,
        image:
            'https://images.pexels.com/photos/6585601/pexels-photo-6585601.jpeg?auto=compress&w=600',
      ),
      ServiceModel(
        id: '6',
        title: 'Shirt Steam Press',
        category: 'Ironing',
        price: 59,
        rating: 4.8,
        image:
            'https://images.pexels.com/photos/52518/jeans-pants-blue-shop-52518.jpeg?auto=compress&w=600',
      ),
      ServiceModel(
        id: '7',
        title: 'Trouser Wash',
        category: 'Wash & Fold',
        price: 79,
        rating: 4.7,
        image:
            'https://images.pexels.com/photos/6068961/pexels-photo-6068961.jpeg?auto=compress&w=600',
      ),
      ServiceModel(
        id: '8',
        title: 'Curtain Dry Clean',
        category: 'Home',
        price: 299,
        rating: 4.6,
        image:
            'https://images.pexels.com/photos/12316986/pexels-photo-12316986.jpeg?auto=compress&w=600',
      ),
    ];
  }
}
