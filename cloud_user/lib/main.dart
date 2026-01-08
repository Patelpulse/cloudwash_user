import 'package:cloud_user/core/firebase/firebase_options.dart';
import 'package:cloud_user/core/router/app_router.dart';
import 'package:cloud_user/core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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

class CloudUserApp extends ConsumerWidget {
  const CloudUserApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
