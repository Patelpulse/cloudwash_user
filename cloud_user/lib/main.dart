import 'package:cloud_user/core/firebase/firebase_options.dart';
import 'package:cloud_user/features/home/data/home_providers.dart';
import 'package:cloud_user/features/home/data/web_content_providers.dart';
import 'package:cloud_user/features/profile/presentation/providers/user_provider.dart';
import 'package:cloud_user/core/router/app_router.dart';
import 'package:cloud_user/core/theme/app_theme.dart';
import 'package:cloud_user/core/widgets/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:cloud_user/core/services/notification_service.dart';
import 'package:cloud_user/features/notifications/presentation/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy(); // Remove # from URLs

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final container = ProviderContainer();
  await container.read(notificationServiceProvider).init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const CloudUserApp(),
    ),
  );
}

class CloudUserApp extends ConsumerStatefulWidget {
  const CloudUserApp({super.key});

  @override
  ConsumerState<CloudUserApp> createState() => _CloudUserAppState();
}

class _CloudUserAppState extends ConsumerState<CloudUserApp> {
  bool _showSplash = !kIsWeb; // Skip splash on web/desktop

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return MaterialApp(
        title: 'Cloud Wash',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: AnimatedSplashScreen(
          onAnimationComplete: () {
            setState(() {
              _showSplash = false;
            });
          },
          loadData: () async {
            // Pre-fetch all home screen data
            await Future.wait([
              ref.read(heroSectionProvider.future),
              ref.read(categoriesProvider.future),
              ref.read(homeBannersProvider.future),
              ref.read(spotlightServicesProvider.future),
              ref.read(topServicesProvider.future),
              ref.read(subCategoriesProvider.future),
              ref.read(whyChooseUsProvider.future),
              ref.read(userProfileProvider.future),
              // Web specific but harmless to fetch
              ref.read(aboutUsProvider.future),
              ref.read(statsProvider.future),
              ref.read(testimonialsProvider.future),
            ]);
          },
        ),
      );
    }

    final router = ref.watch(goRouterProvider);
    // Keep notifications active
    ref.watch(notificationsProvider);

    return MaterialApp.router(
      title: 'Cloud Wash',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
