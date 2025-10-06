import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:elements_app/core/services/notifications/fcm_token_service.dart';
import 'package:elements_app/core/services/ios_ad_tracking_service.dart';
import 'package:elements_app/core/services/ad_configuration_service.dart';
import '../../product/widget/ads/interstitial_ad_widget.dart';
import '../../product/ads/rewarded_helper.dart';

/// The `AppInitializer` class is used to manage the initialization process
/// of your Flutter application. It orchestrates and executes crucial tasks that
/// need to be performed before the application starts. These tasks may include
/// initializing the Flutter binding or initializing ad services.
class AppInitializer {
  static AppInitializer? _instance;
  bool _isInitialized = false;

  /// Singleton constructor method for creating a single instance (Singleton design pattern).
  factory AppInitializer() {
    _instance ??= AppInitializer._internal();
    return _instance!;
  }

  /// Private constructor accessible only from within the class.
  AppInitializer._internal();

  /// Used to initialize the application and perform necessary startup tasks.
  ///
  /// This function is controlled by the `_isInitialized` flag, ensuring that
  /// the tasks are executed only once.
  Future<void> initialize() async {
    if (!_isInitialized) {
      try {
        // Initialize Google Mobile Ads with iOS-specific configuration
        await MobileAds.instance.initialize();

        // Initialize iOS ad tracking service
        await IOSAdTrackingService.instance.initialize();

        // iOS-specific initialization delay
        if (Platform.isIOS) {
          await Future.delayed(const Duration(milliseconds: 1000));
        }

        // Initialize Interstitial Ad Manager
        await InterstitialAdManager.instance.initialize();

        // Preload rewarded interstitial to reduce first-show latency
        await RewardedHelper.initialize();

        // Log FCM token once during app startup (Android/iOS)
        await FcmTokenService.instance.logFcmTokenIfAvailable();

        // Verify ad configuration
        AdConfigurationService.instance.logAdConfiguration();

        // Marks the completion of the initialization process.
        _isInitialized = true;
        print('✅ App initialization completed successfully');
      } catch (e) {
        // Handle any exceptions during initialization
        print('❌ Error during app initialization: $e');
        // Still mark as initialized to prevent infinite retry
        _isInitialized = true;
      }
    }
  }
}
