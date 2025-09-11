import 'package:elements_app/core/initialize/app_initializer.dart';
import 'package:elements_app/core/initialize/application_provider.dart';
import 'package:elements_app/feature/view/home/home_view.dart';
import 'package:elements_app/product/constants/stringConstants/en_app_strings.dart';
import 'package:elements_app/core/theme/app_theme.dart';
import 'package:elements_app/core/observer/route_observer.dart';
import 'package:elements_app/core/services/widget/element_home_widget_service.dart';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';
import 'package:home_widget/home_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Google Mobile Ads
  await MobileAds.instance.initialize();

  await AppInitializer().initialize();

  // Register HomeWidget background callback (no-op placeholder)
  await HomeWidget.registerBackgroundCallback(_backgroundCallback);

  runApp(
    DevicePreview(
      enabled: false, // Set to false for production
      builder: (context) => MultiProvider(
        providers: [
          ...ApplicationProvider.instance.appProviders,
        ],
        child: const MyApp(),
      ),
    ),
  );
}

@pragma('vm:entry-point')
Future<void> _backgroundCallback(Uri? uri) async {
  // Reserved for future background updates (e.g., periodic refresh)
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: EnAppStrings.appName,
      theme: AppTheme().theme,
      home: const HomeView(),
      navigatorObservers: [
        AdRouteObserver(),
      ],
      // Device Preview Configuration
      locale: DevicePreview.locale(context),
      builder: (context, child) {
        // Ensure widget updated after providers are available
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ElementHomeWidgetService.updateFromContext(context);
        });
        return DevicePreview.appBuilder(context, child);
      },
    );
  }
}
