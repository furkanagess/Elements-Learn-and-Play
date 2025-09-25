import 'package:elements_app/core/initialize/app_initializer.dart';
import 'package:elements_app/core/initialize/application_provider.dart';
import 'package:elements_app/feature/view/home/home_view.dart';
import 'package:elements_app/feature/view/onboarding/onboarding_view.dart';
import 'package:elements_app/product/constants/stringConstants/en_app_strings.dart';
import 'package:elements_app/core/theme/app_theme.dart';
import 'package:elements_app/core/observer/route_observer.dart';
import 'package:elements_app/core/services/widget/element_home_widget_service.dart';
import 'package:elements_app/core/services/purchases/revenue_cat_service.dart';
import 'package:elements_app/core/services/first_time_service.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';
import 'package:home_widget/home_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/notifications/push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register background handler before initializeApp (top-level function)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await AppInitializer().initialize();
  await PushNotificationService.instance.initialize();

  // Initialize RevenueCat
  try {
    await RevenueCatService.instance.initialize();
  } catch (e) {
    debugPrint('Failed to initialize RevenueCat: $e');
  }

  // Initialize ApplicationProvider (including PurchaseProvider)
  try {
    await ApplicationProvider.instance.initializeProviders();
  } catch (e) {
    debugPrint('Failed to initialize ApplicationProvider: $e');
  }

  // Configure iOS App Group for HomeWidget and optional background callback
  try {
    await HomeWidget.setAppGroupId('group.com.furkanages.elements');
    // await HomeWidget.registerInteractivityCallback(_backgroundCallback);
  } catch (_) {}

  runApp(
    DevicePreview(
      enabled: false, // Set to false for production
      builder: (context) => MultiProvider(
        providers: [...ApplicationProvider.instance.appProviders],
        child: const MyApp(),
      ),
    ),
  );
}

// @pragma('vm:entry-point')
// Future<void> _backgroundCallback(Uri? uri) async {
//   // Update widget when app is opened from widget
//   try {
//     await HomeWidget.updateWidget(
//       name: ElementHomeWidgetService.androidWidgetName,
//       iOSName: ElementHomeWidgetService.iOSWidgetName,
//     );
//   } catch (e) {
//     // Handle error silently in background
//   }
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? _initialScreen;

  @override
  void initState() {
    super.initState();
    _checkInitialScreen();
  }

  Future<void> _checkInitialScreen() async {
    try {
      final shouldShowOnboarding = await FirstTimeService.instance
          .shouldShowOnboarding();

      if (mounted) {
        setState(() {
          _initialScreen = shouldShowOnboarding
              ? const OnboardingView()
              : const HomeView();
        });
      }
    } catch (e) {
      debugPrint('❌ Error checking initial screen: $e');
      if (mounted) {
        setState(() {
          _initialScreen = const HomeView(); // Default to home on error
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: EnAppStrings.appName,
      theme: AppTheme.theme,
      home: _initialScreen ?? const HomeView(), // Show home as fallback
      navigatorObservers: [AdRouteObserver()],
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
