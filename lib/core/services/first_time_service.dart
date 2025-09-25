import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class FirstTimeService {
  static FirstTimeService? _instance;
  static FirstTimeService get instance => _instance ??= FirstTimeService._();

  FirstTimeService._();

  static const String _firstTimeKey = 'first_time_user';
  static const String _paywallShownKey = 'paywall_shown';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  /// Check if this is the first time the user is opening the app
  Future<bool> isFirstTimeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_firstTimeKey) ?? true;
    } catch (e) {
      debugPrint('❌ Error checking first time user: $e');
      return true; // Default to first time if error
    }
  }

  /// Mark that the user is no longer a first-time user
  Future<void> markAsNotFirstTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_firstTimeKey, false);
      debugPrint('✅ User marked as not first time');
    } catch (e) {
      debugPrint('❌ Error marking user as not first time: $e');
    }
  }

  /// Check if paywall has been shown to the user
  Future<bool> hasPaywallBeenShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_paywallShownKey) ?? false;
    } catch (e) {
      debugPrint('❌ Error checking paywall shown: $e');
      return false; // Default to not shown if error
    }
  }

  /// Mark that paywall has been shown to the user
  Future<void> markPaywallAsShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_paywallShownKey, true);
      debugPrint('✅ Paywall marked as shown');
    } catch (e) {
      debugPrint('❌ Error marking paywall as shown: $e');
    }
  }

  /// Check if onboarding has been completed
  Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingCompletedKey) ?? false;
    } catch (e) {
      debugPrint('❌ Error checking onboarding completed: $e');
      return false; // Default to not completed if error
    }
  }

  /// Mark onboarding as completed
  Future<void> markOnboardingAsCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompletedKey, true);
      debugPrint('✅ Onboarding marked as completed');
    } catch (e) {
      debugPrint('❌ Error marking onboarding as completed: $e');
    }
  }

  /// Check if we should show onboarding
  /// Show onboarding if:
  /// 1. User is first time user AND
  /// 2. Onboarding hasn't been completed yet
  Future<bool> shouldShowOnboarding() async {
    final isFirstTime = await isFirstTimeUser();
    final onboardingCompleted = await isOnboardingCompleted();

    return isFirstTime && !onboardingCompleted;
  }

  /// Check if we should show the paywall
  /// Show paywall if:
  /// 1. User is first time user AND
  /// 2. Onboarding has been completed AND
  /// 3. Paywall hasn't been shown yet AND
  /// 4. User is not premium
  Future<bool> shouldShowPaywall({required bool isPremium}) async {
    if (isPremium) return false; // Don't show to premium users

    final isFirstTime = await isFirstTimeUser();
    final onboardingCompleted = await isOnboardingCompleted();
    final paywallShown = await hasPaywallBeenShown();

    return isFirstTime && onboardingCompleted && !paywallShown;
  }

  /// Complete the first-time flow
  /// This should be called when onboarding is completed
  Future<void> completeFirstTimeFlow() async {
    await Future.wait([
      markAsNotFirstTime(),
      markPaywallAsShown(),
      markOnboardingAsCompleted(),
    ]);
    debugPrint('✅ First time flow completed');
  }

  /// Mark only the paywall as shown (without completing the entire first-time flow)
  /// This should be called when user dismisses the paywall
  Future<void> markPaywallAsShownOnly() async {
    await markPaywallAsShown();
    debugPrint('✅ Paywall marked as shown');
  }

  /// Reset first time status (for testing purposes)
  Future<void> resetFirstTimeStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_firstTimeKey);
      await prefs.remove(_paywallShownKey);
      await prefs.remove(_onboardingCompletedKey);
      debugPrint('🔄 First time status reset');
    } catch (e) {
      debugPrint('❌ Error resetting first time status: $e');
    }
  }

  /// Debug method to check current status
  Future<void> debugStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool(_firstTimeKey) ?? true;
      final paywallShown = prefs.getBool(_paywallShownKey) ?? false;
      final onboardingCompleted =
          prefs.getBool(_onboardingCompletedKey) ?? false;

      debugPrint('🔍 FirstTimeService Debug Status:');
      debugPrint('  - isFirstTimeUser: $isFirstTime');
      debugPrint('  - paywallShown: $paywallShown');
      debugPrint('  - onboardingCompleted: $onboardingCompleted');
    } catch (e) {
      debugPrint('❌ Error getting debug status: $e');
    }
  }
}
