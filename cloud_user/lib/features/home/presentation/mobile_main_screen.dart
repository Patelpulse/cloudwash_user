import 'package:cloud_user/core/theme/app_theme.dart';
import 'package:cloud_user/features/orders/data/order_model.dart';
import 'package:cloud_user/features/orders/data/order_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class MobileMainScreen extends ConsumerWidget {
  final Widget child;

  const MobileMainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for real-time order status updates from Firebase
    ref.listen(userOrdersRealtimeProvider, (previous, next) {
      if (previous != null &&
          previous is AsyncData<List<OrderModel>> &&
          next is AsyncData<List<OrderModel>>) {
        final previousOrders = previous.value;
        final currentOrders = next.value;

        for (var order in currentOrders) {
          final oldOrder = previousOrders.firstWhere(
            (o) => o.id == order.id,
            orElse: () => order.copyWith(status: 'NEW'),
          );

          if (oldOrder.status != 'NEW' && oldOrder.status != order.status) {
            // Status updated! Show notification
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppTheme.primary,
                content: Text(
                  'Booking #${order.orderNumber} status updated to ${order.status.toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      }
    });

    return Scaffold(body: child, bottomNavigationBar: _MobileBottomBar());
  }
}

class _MobileBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;

    int getCurrentIndex() {
      if (location == '/') return 0;
      if (location == '/services') return 1;
      if (location == '/cart') return 2;
      if (location == '/bookings') return 3;
      if (location == '/profile') return 4;
      return -1;
    }

    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              isActive: getCurrentIndex() == 0,
              onTap: () => context.go('/'),
            ),
            _BottomNavItem(
              icon: Icons.grid_view_rounded,
              label: 'Services',
              isActive: getCurrentIndex() == 1,
              onTap: () => context.go('/services'),
            ),
            _BottomNavItem(
              icon: Icons.shopping_basket_rounded,
              label: 'Cart',
              isActive: getCurrentIndex() == 2,
              onTap: () => context.go('/cart'),
            ),
            _BottomNavItem(
              icon: Icons.calendar_month_rounded,
              label: 'Bookings',
              isActive: getCurrentIndex() == 3,
              onTap: () => context.go('/bookings'),
            ),
            _BottomNavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              isActive: getCurrentIndex() == 4,
              onTap: () => context.go('/profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: isActive ? AppTheme.primary : const Color(0xFF9CA3AF),
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? AppTheme.primary : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
