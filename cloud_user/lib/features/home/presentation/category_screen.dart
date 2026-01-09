import 'package:cloud_user/features/cart/data/cart_provider.dart';
import 'package:cloud_user/features/home/data/home_providers.dart';
import 'package:cloud_user/features/home/presentation/widgets/service_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CategoryScreen extends ConsumerWidget {
  final String categoryId;
  final String categoryName;

  const CategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider(categoryId: categoryId));
    final cartState = ref.watch(cartProvider);
    final cartItems = cartState.items;

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => context.push('/cart'),
              ),
              if (cartItems.isNotEmpty || cartState.selectedAddons.isNotEmpty)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cartItems.length + cartState.selectedAddons.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: servicesAsync.when(
        data: (services) => ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return ServiceCard(
              service: service,
              onTap: () {
                context.push('/service-details', extra: service);
              },
              onAdd: () {
                ref.read(cartProvider.notifier).addToCart(service);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${service.title} added to cart'),
                    duration: const Duration(seconds: 1),
                    action: SnackBarAction(
                      label: 'View Cart',
                      onPressed: () => context.push('/cart'),
                    ),
                  ),
                );
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
