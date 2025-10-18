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
import 'package:elements_app/product/widget/splash/lottie_splash_screen.dart';

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

  try {
    // Initialize Firebase with timeout
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));

    // Register background handler before initializeApp (top-level function)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Initialize core services with timeout
    await AppInitializer().initialize().timeout(const Duration(seconds: 15));

    // Initialize push notifications asynchronously (non-blocking)
    _initializePushNotificationsAsync();

    // Initialize RevenueCat with timeout (non-blocking)
    _initializeRevenueCatAsync();

    // Initialize ApplicationProvider with timeout
    await ApplicationProvider.instance.initializeProviders().timeout(
      const Duration(seconds: 10),
    );

    // Configure iOS App Group for HomeWidget (non-blocking)
    _initializeHomeWidgetAsync();
  } catch (e) {
    debugPrint('❌ Critical initialization error: $e');
    // Continue with app launch even if some services fail
  }

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

/// Initialize RevenueCat asynchronously (non-blocking)
void _initializeRevenueCatAsync() {
  Future.microtask(() async {
    try {
      await RevenueCatService.instance.initialize().timeout(
        const Duration(seconds: 15),
      );
      debugPrint('✅ RevenueCat initialized successfully (async)');
    } catch (e) {
      debugPrint('❌ RevenueCat initialization failed (async): $e');
    }
  });
}

/// Initialize push notifications asynchronously (non-blocking)
void _initializePushNotificationsAsync() {
  Future.microtask(() async {
    try {
      await PushNotificationService.instance.initialize().timeout(
        const Duration(seconds: 15),
      );
      debugPrint('✅ Push notifications initialized successfully (async)');
    } catch (e) {
      debugPrint('❌ Push notifications initialization failed (async): $e');
    }
  });
}

/// Initialize HomeWidget asynchronously (non-blocking)
void _initializeHomeWidgetAsync() {
  Future.microtask(() async {
    try {
      await HomeWidget.setAppGroupId('group.com.furkanages.elements');
      await ElementHomeWidgetService.scheduleDailyUpdates();
      debugPrint('✅ HomeWidget initialized successfully (async)');
    } catch (e) {
      debugPrint('❌ HomeWidget initialization failed (async): $e');
    }
  });
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
  bool _isLoading = true;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _showSplashAndNavigate();
  }

  Future<void> _showSplashAndNavigate() async {
    // Always show splash screen for 3 seconds on every restart
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }

    // Then check initial screen
    await _checkInitialScreen();
  }

  Future<void> _checkInitialScreen() async {
    try {
      // Add timeout to prevent hanging
      final shouldShowOnboarding = await FirstTimeService.instance
          .shouldShowOnboarding()
          .timeout(const Duration(seconds: 5));

      if (mounted) {
        setState(() {
          _initialScreen = shouldShowOnboarding
              ? const OnboardingView()
              : const HomeView();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error checking initial screen: $e');
      if (mounted) {
        setState(() {
          _initialScreen = const HomeView(); // Default to home on error
          _isLoading = false;
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
      home: _showSplash
          ? _buildLoadingScreen()
          : (_isLoading
                ? _buildLoadingScreen()
                : (_initialScreen ??
                      const HomeView())), // Show home as fallback
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

  /// Build loading screen to show while initializing
  Widget _buildLoadingScreen() {
    return LottieSplashScreen(
      duration: const Duration(seconds: 3),
      onAnimationComplete: () {
        // Animation completed, but we still need to wait for initialization
        // The actual navigation will be handled by _checkInitialScreen
      },
    );
  }
}
