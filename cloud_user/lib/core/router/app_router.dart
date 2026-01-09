import 'package:cloud_user/core/models/service_model.dart';
import 'package:cloud_user/features/auth/data/auth_repository.dart';
import 'package:cloud_user/features/auth/presentation/otp_screen.dart';
import 'package:cloud_user/features/auth/presentation/register_screen.dart';
import 'package:cloud_user/features/auth/presentation/login_screen.dart';
import 'package:cloud_user/features/bookings/presentation/booking_details_screen.dart';
import 'package:cloud_user/features/cart/presentation/cart_screen.dart';
import 'package:cloud_user/features/cart/presentation/checkout_screen.dart';
import 'package:cloud_user/features/cart/presentation/thank_you_screen.dart';
import 'package:cloud_user/features/home/presentation/mobile_home_screen.dart';
import 'package:cloud_user/features/home/presentation/mobile_main_screen.dart';
import 'package:cloud_user/features/home/presentation/onboarding_screen.dart';
import 'package:cloud_user/features/home/presentation/service_details_screen.dart';
import 'package:cloud_user/features/location/presentation/add_address_screen.dart';
import 'package:cloud_user/features/location/presentation/address_list_screen.dart';
import 'package:cloud_user/features/location/presentation/map_screen.dart';
import 'package:cloud_user/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:cloud_user/features/profile/presentation/edit_profile_screen.dart';
import 'package:cloud_user/features/profile/presentation/personal_info_screen.dart';
import 'package:cloud_user/features/profile/presentation/profile_screen.dart';
import 'package:cloud_user/features/web/presentation/web_bookings_screen.dart';
import 'package:cloud_user/features/web/presentation/web_home_screen.dart';
import 'package:cloud_user/features/web/presentation/web_services_list_screen.dart';
import 'package:cloud_user/features/web/presentation/web_services_page.dart';
import 'package:cloud_user/features/web/presentation/web_static_page.dart';
import 'package:cloud_user/features/web/presentation/web_sub_categories_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

@Riverpod(keepAlive: true)
GoRouter goRouter(GoRouterRef ref) {
  final authRepo = ref.watch(authRepositoryProvider);

  // Use Web Router for both Web and Mobile to ensure consistent responsive design
  return GoRouter(
    initialLocation: kIsWeb ? '/' : '/onboarding',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      final isAuthenticated = await authRepo.isAuthenticated();
      final isAuthRoute =
          state.uri.path == '/login' ||
          state.uri.path == '/register' ||
          state.uri.path == '/otp';
      final isOnboarding = state.uri.path == '/onboarding';

      if (isAuthenticated) {
        // If logged in and trying to access auth pages, go to home
        if (isAuthRoute) {
          return '/';
        }
      } else {
        // Not authenticated
        if (!kIsWeb) {
          // Mobile: Keep onboarding flow
          final prefs = await SharedPreferences.getInstance();
          final onboardingComplete =
              prefs.getBool('onboarding_complete') ?? false;

          if (!onboardingComplete) {
            // Force onboarding if not complete
            if (!isOnboarding) return '/onboarding';
          } else {
            // Onboarding complete
            // If not on auth/public route, go to register
            if (!isAuthRoute &&
                state.uri.path != '/' &&
                state.uri.path != '/services' &&
                state.uri.path != '/about' &&
                state.uri.path != '/contact' &&
                !state.uri.path.startsWith('/category') &&
                !state.uri.path.startsWith('/services-list')) {
              return '/register';
            }
          }
        }
        // Web: Allow browsing without authentication
        // No redirect needed - users can browse freely
      }
      return null;
    },
    routes: _buildWebRoutes(),
  );
}

/// Web Router Routes
List<RouteBase> _buildWebRoutes() {
  return [
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        if (kIsWeb) return child;
        return MobileMainScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) =>
              kIsWeb ? const WebHomeScreen() : const MobileHomeScreen(),
        ),
        // ... (rest of the file stays same)
        GoRoute(
          path: '/notifications',
          name: 'web-notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/category/:id',
          name: 'category',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final name = state.extra as String? ?? 'Services';
            return WebSubCategoriesScreen(categoryId: id, categoryName: name);
          },
        ),
        GoRoute(
          path: '/services-list/:subCategoryId',
          name: 'servicesList',
          builder: (context, state) {
            final id = state.pathParameters['subCategoryId']!;
            final name = state.extra as String? ?? 'Services';
            return WebServicesListScreen(
              subCategoryId: id,
              subCategoryName: name,
            );
          },
        ),
        GoRoute(
          path: '/cart',
          name: 'cart',
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: '/bookings',
          name: 'web-bookings',
          builder: (context, state) => const WebBookingsScreen(),
        ),
        GoRoute(
          path: '/profile',
          name: 'web-profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/services',
          name: 'services',
          builder: (context, state) => const WebServicesPage(),
        ),
        GoRoute(
          path: '/checkout',
          name: 'checkout',
          builder: (context, state) => const CheckoutScreen(),
        ),
        GoRoute(
          path: '/thank-you',
          name: 'thankYou',
          builder: (context, state) => const ThankYouScreen(),
        ),
        GoRoute(
          path: '/booking-details/:id',
          name: 'bookingDetails',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return BookingDetailsScreen(bookingId: id);
          },
        ),
      ],
    ),
    // Pages OUTSIDE the Shell (No Bottom Bar)
    GoRoute(
      path: '/service-details',
      name: 'serviceDetails',
      builder: (context, state) {
        final service = state.extra as ServiceModel;
        return ServiceDetailsScreen(service: service);
      },
    ),
    GoRoute(
      path: '/edit-profile',
      name: 'editProfile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/personal-info',
      name: 'personalInfo',
      builder: (context, state) => const PersonalInfoScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'web-login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/otp',
      name: 'web-otp',
      builder: (context, state) {
        final extras = state.extra as Map<String, String>;
        return OtpScreen(phone: extras['phone']!, generatedOtp: extras['otp']!);
      },
    ),
    GoRoute(
      path: '/about',
      name: 'about',
      builder: (context, state) =>
          const WebStaticPage(pageType: StaticPageType.aboutUs),
    ),
    GoRoute(
      path: '/contact',
      name: 'contact',
      builder: (context, state) =>
          const WebStaticPage(pageType: StaticPageType.contactUs),
    ),
    GoRoute(
      path: '/terms',
      builder: (context, state) =>
          const WebStaticPage(pageType: StaticPageType.terms),
    ),
    GoRoute(
      path: '/privacy',
      builder: (context, state) =>
          const WebStaticPage(pageType: StaticPageType.privacy),
    ),
    GoRoute(
      path: '/blog',
      builder: (context, state) =>
          const WebStaticPage(pageType: StaticPageType.blog),
    ),
    GoRoute(
      path: '/reviews',
      builder: (context, state) =>
          const WebStaticPage(pageType: StaticPageType.reviews),
    ),
    GoRoute(
      path: '/child-protection',
      builder: (context, state) =>
          const WebStaticPage(pageType: StaticPageType.childProtection),
    ),
    GoRoute(path: '/map', builder: (context, state) => const MapScreen()),
    GoRoute(
      path: '/addresses',
      name: 'addresses',
      builder: (context, state) => const AddressListScreen(),
    ),
    GoRoute(
      path: '/add-address',
      name: 'addAddress',
      builder: (context, state) => const AddAddressScreen(),
    ),
    GoRoute(
      path: '/help',
      name: 'help',
      builder: (context, state) =>
          const WebStaticPage(pageType: StaticPageType.help),
    ),
    GoRoute(
      path: '/refund-policy',
      name: 'refundPolicy',
      builder: (context, state) =>
          const WebStaticPage(pageType: StaticPageType.refundPolicy),
    ),
  ];
}
