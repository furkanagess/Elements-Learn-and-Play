import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:elements_app/core/services/notifications/fcm_token_service.dart';
import 'package:elements_app/core/services/ios_ad_tracking_service.dart';
import 'package:elements_app/core/services/ad_configuration_service.dart';
import 'package:elements_app/core/services/ios_production_ad_service.dart';
import 'package:elements_app/core/services/android_production_service.dart';
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
        print('🚀 Starting app initialization...');

        // Initialize Google Mobile Ads with timeout
        await MobileAds.instance.initialize().timeout(
          const Duration(seconds: 10),
        );

        // Initialize iOS ad tracking service with timeout
        await IOSAdTrackingService.instance.initialize().timeout(
          const Duration(seconds: 5),
        );

        // iOS-specific initialization delay (reduced)
        if (Platform.isIOS) {
          await Future.delayed(const Duration(milliseconds: 500));
        }

        // Initialize Interstitial Ad Manager with timeout
        await InterstitialAdManager.instance.initialize().timeout(
          const Duration(seconds: 10),
        );

        // Preload rewarded interstitial with timeout (non-critical)
        try {
          await RewardedHelper.initialize().timeout(const Duration(seconds: 5));
        } catch (e) {
          print('⚠️ Rewarded ads initialization failed (non-critical): $e');
        }

        // Log FCM token with timeout (non-critical)
        try {
          await FcmTokenService.instance.logFcmTokenIfAvailable().timeout(
            const Duration(seconds: 5),
          );
        } catch (e) {
          print('⚠️ FCM token logging failed (non-critical): $e');
        }

        // Initialize platform-specific production services
        if (Platform.isIOS) {
          try {
            await IOSProductionAdService.instance.initialize().timeout(
              const Duration(seconds: 5),
            );
          } catch (e) {
            print(
              '⚠️ iOS production ad service initialization failed (non-critical): $e',
            );
          }
        } else if (Platform.isAndroid) {
          try {
            await AndroidProductionService.instance.initialize().timeout(
              const Duration(seconds: 5),
            );
          } catch (e) {
            print(
              '⚠️ Android production service initialization failed (non-critical): $e',
            );
          }
        }

        // Verify ad configuration (non-blocking)
        try {
          AdConfigurationService.instance.logAdConfiguration();
        } catch (e) {
          print('⚠️ Ad configuration logging failed (non-critical): $e');
        }

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
