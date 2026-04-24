// import 'package:cloud_user/core/firebase/firebase_options.dart';
// import 'package:cloud_user/features/home/data/home_providers.dart';
// import 'package:cloud_user/features/home/data/web_content_providers.dart';
// import 'package:cloud_user/features/profile/presentation/providers/user_provider.dart';
// import 'package:cloud_user/core/router/app_router.dart';
// import 'package:cloud_user/core/theme/app_theme.dart';
// import 'package:cloud_user/core/utils/device_logo_utils.dart';
// import 'package:cloud_user/core/widgets/animated_splash_screen.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_web_plugins/url_strategy.dart';
// import 'package:sizer/sizer.dart';

// import 'package:cloud_user/core/services/notification_service.dart';
// import 'package:cloud_user/features/notifications/presentation/providers/notification_provider.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   // Make status bar transparent
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.dark,
//       statusBarBrightness: Brightness.light, // For iOS
//     ),
//   );

//   usePathUrlStrategy(); // Remove # from URLs

//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   final container = ProviderContainer();
//   // Local notifications are not supported on web; initializing here can block startup.
//   if (!kIsWeb) {
//     await container.read(notificationServiceProvider).init();
//   }

//   runApp(
//     UncontrolledProviderScope(
//       container: container,
//       child: const CloudUserApp(),
//     ),
//   );
// }

// class CloudUserApp extends ConsumerStatefulWidget {
//   const CloudUserApp({super.key});

//   @override
//   ConsumerState<CloudUserApp> createState() => _CloudUserAppState();
// }

// class _CloudUserAppState extends ConsumerState<CloudUserApp> {
//   bool _showSplash = !kIsWeb;

//   @override
//   Widget build(BuildContext context) {
//     final router = ref.watch(goRouterProvider);
//     ref.watch(notificationsProvider);

//     return Sizer(
//       builder: (context, orientation, deviceType) {
//         return MaterialApp.router(
//           title: 'Cloud Wash',
//           theme: AppTheme.lightTheme,
//           routerConfig: router,
//           debugShowCheckedModeBanner: false,
//           builder: (context, child) {
//             return Stack(
//               children: [
//                 if (child != null) child,
//                 if (_showSplash)
//                   Positioned.fill(
//                     child: AnimatedSplashScreen(
//                       onAnimationComplete: () {
//                         setState(() {
//                           _showSplash = false;
//                         });
//                       },
//                       loadData: () async {
//                         if (kIsWeb) {
//                           ref.read(aboutUsProvider.future);
//                           ref.read(statsProvider.future);
//                           ref.read(testimonialsProvider.future);
//                           ref.read(footerProvider.future);
//                           ref.read(heroSectionProvider.future);
//                           ref.read(categoriesProvider.future);
//                           ref.read(homeBannersProvider.future);
//                           ref.read(userProfileProvider.future).catchError((_) => null);
//                         }
//                       },
//                     ),
//                   ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
// }
//  if (_showSplash) {
//       final hero = ref.watch(heroSectionProvider).valueOrNull;
//       final heroLogoUrl = resolveHeroLogoForDevice(
//         hero: hero,
//         deviceType: LogoDeviceType.phone,
//       );
//       return MaterialApp(
//         title: 'Cloud Wash',
//         theme: AppTheme.lightTheme,
//         debugShowCheckedModeBanner: false,
//         home: AnimatedSplashScreen(
//           dynamicLogoUrl: heroLogoUrl,
//           onAnimationComplete: () {
//             setState(() {
//               _showSplash = false;
//             });
//           },
//           loadData: () async {
//             // Only pre-fetch essential data for the first screen
//             await Future.wait([
//               ref.read(heroSectionProvider.future),
//               ref.read(categoriesProvider.future),
//               ref.read(homeBannersProvider.future),
//               ref.read(userProfileProvider.future).catchError((_) => null),
//             ]);
            
//             // Background fetch non-essential data without awaiting
//             if (kIsWeb) {
//               ref.read(aboutUsProvider.future);
//               ref.read(statsProvider.future);
//               ref.read(testimonialsProvider.future);
//               ref.read(footerProvider.future);
//             }
//           },
//         ),
//       );
//     }
