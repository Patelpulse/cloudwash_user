// import 'package:cloud_user/core/theme/app_theme.dart';
// import 'package:cloud_user/features/orders/data/order_model.dart';
// import 'package:cloud_user/features/orders/data/order_provider.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:sizer/sizer.dart';

// class MobileMainScreen extends ConsumerWidget {
//   final Widget child;

//   const MobileMainScreen({super.key, required this.child});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Listen for real-time order status updates from Firebase
//     ref.listen(userOrdersRealtimeProvider, (previous, next) {
//       if (previous != null &&
//           previous is AsyncData<List<OrderModel>> &&
//           next is AsyncData<List<OrderModel>>) {
//         final previousOrders = previous.value;
//         final currentOrders = next.value;
//         for (var order in currentOrders) {
//           final oldOrder = previousOrders.firstWhere(
//             (o) => o.id == order.id,
//             orElse: () => order.copyWith(status: 'NEW'),
//           );

//           if (oldOrder.status != 'NEW' && oldOrder.status != order.status) {
//             // Status updated! Show notification
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 behavior: SnackBarBehavior.floating,
//                 backgroundColor: AppTheme.primary,
//                 content: Text(
//                   'Booking #${order.orderNumber} status updated to ${order.status.toUpperCase()}',
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 duration: const Duration(seconds: 4),
//               ),
//             );
//           }
//         }
//       }
//     });

//     final String location = GoRouterState.of(context).uri.path;

//     int getCurrentIndex() {
//       if (location == '/') return 0;
//       if (location.startsWith('/services')) return 1;
//       if (location.startsWith('/cart')) return 2;
//       if (location.startsWith('/bookings')) return 3;
//       if (location.startsWith('/profile')) return 4;
//       return 0;
//     }

//     void onDestinationSelected(int index) {
//       switch (index) {
//         case 0:
//           context.go('/');
//           break;
//         case 1:
//           context.go('/services');
//           break;
//         case 2:
//           context.go('/cart');
//           break;
//         case 3:
//           context.go('/bookings');
//           break;
//         case 4:
//           context.go('/profile');
//           break;
//       }
//     }

//     return Scaffold(
//       body: child,
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.08),
//               blurRadius: 20,
//               offset: const Offset(0, -4),
//             ),
//           ],
//         ),
//         child: NavigationBarTheme(
//           data: NavigationBarThemeData(
//             height: 60,
//             backgroundColor: Colors.white,
//             indicatorColor: AppTheme.primary.withOpacity(0.08),
//             indicatorShape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             labelTextStyle: MaterialStateProperty.resolveWith((states) {
//               final isSelected = states.contains(MaterialState.selected);
//               return GoogleFonts.inter(
//                 fontSize: 11,
//                 fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
//                 color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
//               );
//             }),
//             iconTheme: MaterialStateProperty.resolveWith((states) {
//               final isSelected = states.contains(MaterialState.selected);
//               return IconThemeData(
//                 size: 26,
//                 color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
//               );
//             }),
//           ),
//           child: NavigationBar(
//             selectedIndex: getCurrentIndex(),
//             onDestinationSelected: onDestinationSelected,
//             elevation: 0,
//             destinations: const [
//               NavigationDestination(
//                 icon: Icon(Icons.home_outlined),
//                 selectedIcon: Icon(Icons.home_rounded),
//                 label: 'Home',
//               ),
//               NavigationDestination(
//                 icon: Icon(Icons.grid_view_outlined),
//                 selectedIcon: Icon(Icons.grid_view_rounded),
//                 label: 'Services',
//               ),
//               NavigationDestination(
//                 icon: Icon(Icons.shopping_basket_outlined),
//                 selectedIcon: Icon(Icons.shopping_basket_rounded),
//                 label: 'Cart',
//               ),
//               NavigationDestination(
//                 icon: Icon(Icons.calendar_month_outlined),
//                 selectedIcon: Icon(Icons.calendar_month_rounded),
//                 label: 'Bookings',
//               ),
//               NavigationDestination(
//                 icon: Icon(Icons.person_outline),
//                 selectedIcon: Icon(Icons.person_rounded),
//                 label: 'Profile',
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




import 'dart:io';

import 'package:cloud_user/core/theme/app_theme.dart';
import 'package:cloud_user/features/orders/data/order_model.dart';
import 'package:cloud_user/features/orders/data/order_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class MobileMainScreen extends ConsumerWidget {
  final Widget child;

  const MobileMainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// 🔔 Listen for realtime order updates
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

    final String location = GoRouterState.of(context).uri.path;

    int getCurrentIndex() {
      if (location == '/') return 0;
      if (location.startsWith('/services')) return 1;
      if (location.startsWith('/cart')) return 2;
      if (location.startsWith('/bookings')) return 3;
      if (location.startsWith('/profile')) return 4;
      return 0;
    }

    void onDestinationSelected(int index) {
      switch (index) {
        case 0:
          context.go('/');
          break;
        case 1:
          context.go('/services');
          break;
        case 2:
          context.go('/cart');
          break;
        case 3:
          context.go('/bookings');
          break;
        case 4:
          context.go('/profile');
          break;
      }
    }

    final currentIndex = getCurrentIndex();

    return Scaffold(
      body: child,

      /// 🔥 Adaptive Bottom Navigation
      bottomNavigationBar: SafeArea(
        child: Platform.isIOS
            ? _buildCupertinoTabBar(
                context,
                currentIndex,
                onDestinationSelected,
              )
            : _buildMaterialNavBar(
                context,
                currentIndex,
                onDestinationSelected,
              ),
      ),
    );
  }

  /// 🍏 iOS Style Bottom Nav
  Widget _buildCupertinoTabBar(
    BuildContext context,
    int currentIndex,
    Function(int) onTap,
  ) {
    return CupertinoTabBar(
      currentIndex: currentIndex,
      onTap: onTap,
      activeColor: AppTheme.primary,
      inactiveColor: Colors.grey,
      backgroundColor: Colors.white,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.square_grid_2x2),
          label: 'Services',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.cart),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.calendar),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  /// 🤖 Android Material 3 Nav
  Widget _buildMaterialNavBar(
    BuildContext context,
    int currentIndex,
    Function(int) onTap,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 65,
          backgroundColor: Colors.white,
          indicatorColor: AppTheme.primary.withOpacity(0.1),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            final isSelected = states.contains(MaterialState.selected);
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? AppTheme.primary
                  : AppTheme.textSecondary,
            );
          }),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            final isSelected = states.contains(MaterialState.selected);
            return IconThemeData(
              size: 26,
              color: isSelected
                  ? AppTheme.primary
                  : AppTheme.textSecondary,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'Services',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_basket_outlined),
              selectedIcon: Icon(Icons.shopping_basket_rounded),
              label: 'Cart',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded),
              label: 'Bookings',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}