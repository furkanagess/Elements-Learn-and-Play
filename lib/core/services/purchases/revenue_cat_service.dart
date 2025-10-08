import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// RevenueCat service for handling in-app purchases and subscriptions
class RevenueCatService {
  static const String _premiumKey = 'is_premium_user';
  static const String _userIdKey = 'revenue_cat_user_id';

  // RevenueCat API Keys - Load from environment or use defaults
  static String get _androidApiKey =>
      Platform.environment['REVENUECAT_ANDROID_API_KEY'] ??
      'goog_QpLHDriAAYWHMAYETGlrIEaGQhg';

  static String get _iosApiKey =>
      Platform.environment['REVENUECAT_IOS_API_KEY'] ??
      'appl_WOGaKGocybabmcYEOKXeeUOWPfq';

  // Platform-specific Product IDs
  static const String _androidPremiumProductId = 'remove_ads_elements';
  static const String _iosPremiumProductId = 'remove_elements_ads';

  // Platform-specific Offering identifiers
  static const String _androidOfferingIdentifier = 'remove_ads_elements';
  static const String _iosOfferingIdentifier = 'remove_elements_ads';

  // Package identifier (same for both platforms)
  static const String _packageIdentifier = '\$rc_lifetime';

  // Get platform-specific product ID
  static String get _premiumProductId {
    return Platform.isAndroid ? _androidPremiumProductId : _iosPremiumProductId;
  }

  // Get platform-specific offering identifier
  static String get _offeringIdentifier {
    return Platform.isAndroid
        ? _androidOfferingIdentifier
        : _iosOfferingIdentifier;
  }

  static RevenueCatService? _instance;
  static RevenueCatService get instance => _instance ??= RevenueCatService._();

  RevenueCatService._();

  bool _isInitialized = false;
  bool _isPremium = false;
  String? _userId;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isPremium => _isPremium;
  String? get userId => _userId;
  String get premiumProductId => _premiumProductId;
  String get offeringIdentifier => _offeringIdentifier;

  /// Initialize RevenueCat
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configure RevenueCat
      final apiKey = Platform.isIOS ? _iosApiKey : _androidApiKey;
      final platform = Platform.isIOS ? 'iOS' : 'Android';

      debugPrint('🚀 Initializing RevenueCat for $platform');
      debugPrint('📱 Platform: $platform');
      debugPrint('🔑 API Key: ${apiKey.substring(0, 10)}...');
      debugPrint('🛍️ Product ID: $_premiumProductId');
      debugPrint('📦 Offering ID: $_offeringIdentifier');
      debugPrint('🎁 Package ID: $_packageIdentifier');

      await Purchases.setLogLevel(LogLevel.debug);
      await Purchases.configure(PurchasesConfiguration(apiKey));

      // Set up listener for customer info updates
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdate);

      // Load cached premium status
      await _loadCachedPremiumStatus();

      // Get current customer info (this will also check billing availability)
      await _updateCustomerInfo();

      _isInitialized = true;
      debugPrint('✅ RevenueCat initialized successfully');
    } catch (e) {
      debugPrint('❌ RevenueCat initialization failed: $e');
      rethrow;
    }
  }

  /// Set user ID for RevenueCat
  Future<void> setUserId(String userId) async {
    try {
      await Purchases.logIn(userId);
      _userId = userId;

      // Cache user ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId);

      debugPrint('✅ RevenueCat user ID set: $userId');
    } catch (e) {
      debugPrint('❌ Failed to set RevenueCat user ID: $e');
      rethrow;
    }
  }

  /// Get available products from offerings
  Future<List<StoreProduct>> getProducts() async {
    try {
      final offerings = await Purchases.getOfferings();

      if (offerings.current != null) {
        final products = <StoreProduct>[];
        for (final package in offerings.current!.availablePackages) {
          products.add(package.storeProduct);
        }
        return products;
      }

      return [];
    } catch (e) {
      debugPrint('❌ Failed to get products: $e');
      return [];
    }
  }

  /// Get products directly by product IDs (fallback when offerings are empty)
  Future<List<StoreProduct>> getProductsByIds(List<String> productIds) async {
    try {
      final products = await Purchases.getProducts(productIds);
      return products;
    } catch (e) {
      debugPrint('❌ Failed to get products by IDs: $e');
      return [];
    }
  }

  /// Get available offerings
  Future<Offerings?> getOfferings() async {
    try {
      final platform = Platform.isIOS ? 'iOS' : 'Android';
      debugPrint('🔍 Getting offerings for $platform...');

      final offerings = await Purchases.getOfferings();

      debugPrint('📦 Total offerings: ${offerings.all.length}');
      debugPrint('🎯 Current offering: ${offerings.current?.identifier}');

      if (offerings.current != null) {
        debugPrint(
          '📋 Available packages: ${offerings.current!.availablePackages.length}',
        );
        for (final package in offerings.current!.availablePackages) {
          debugPrint('  - Package: ${package.identifier}');
          debugPrint('  - Product: ${package.storeProduct.identifier}');
          debugPrint('  - Price: ${package.storeProduct.priceString}');
        }
      }

      // Check if offerings are empty
      if (offerings.current == null ||
          offerings.current!.availablePackages.isEmpty) {
        debugPrint(
          '⚠️ No offerings available. This is normal if you haven\'t configured offerings in RevenueCat dashboard yet.',
        );
        debugPrint('💡 You can either:');
        debugPrint('   1. Configure offerings in RevenueCat dashboard, or');
        debugPrint('   2. Use direct product purchases without offerings');
        return null;
      }

      return offerings;
    } catch (e) {
      debugPrint('❌ Failed to get offerings: $e');
      return null;
    }
  }

  /// Get specific offering by identifier
  Future<Offering?> getSpecificOffering(String identifier) async {
    try {
      final platform = Platform.isIOS ? 'iOS' : 'Android';
      debugPrint(
        '🔍 Looking for specific offering: $identifier (Platform: $platform)',
      );

      final offerings = await Purchases.getOfferings();

      debugPrint('📦 All available offerings: ${offerings.all.keys.toList()}');

      if (offerings.all[identifier] != null) {
        final offering = offerings.all[identifier]!;
        debugPrint('✅ Found offering: $identifier');
        debugPrint(
          '📋 Packages in offering: ${offering.availablePackages.length}',
        );

        for (final package in offering.availablePackages) {
          debugPrint('  - Package: ${package.identifier}');
          debugPrint('  - Product: ${package.storeProduct.identifier}');
          debugPrint('  - Price: ${package.storeProduct.priceString}');
        }

        return offering;
      } else {
        debugPrint('⚠️ Offering not found: $identifier');
        debugPrint('Available offerings: ${offerings.all.keys.toList()}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Failed to get specific offering: $e');
      return null;
    }
  }

  /// Get remove ads offering specifically
  Future<Offering?> getRemoveAdsOffering() async {
    return await getSpecificOffering(_offeringIdentifier);
  }

  /// Purchase a product
  Future<CustomerInfo> purchaseProduct(StoreProduct product) async {
    try {
      final result = await Purchases.purchaseStoreProduct(product);

      if (result.customerInfo.entitlements.all[_premiumProductId]?.isActive ==
          true) {
        await _updatePremiumStatus(true);
      }

      return result.customerInfo;
    } catch (e) {
      debugPrint('❌ Purchase failed: $e');
      rethrow;
    }
  }

  /// Purchase a package
  Future<CustomerInfo> purchasePackage(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);

      if (result.customerInfo.entitlements.all[_premiumProductId]?.isActive ==
          true) {
        await _updatePremiumStatus(true);
      }

      return result.customerInfo;
    } catch (e) {
      debugPrint('❌ Package purchase failed: $e');
      rethrow;
    }
  }

  /// Purchase remove ads product directly (Platform optimized)
  Future<CustomerInfo> purchaseRemoveAds() async {
    try {
      final platform = Platform.isIOS ? 'iOS' : 'Android';
      debugPrint('🛒 Starting remove ads purchase for $platform');
      debugPrint('🎯 Looking for offering: $_offeringIdentifier');
      debugPrint('🛍️ Looking for product: $_premiumProductId');
      debugPrint(
        '🔑 Using API Key: ${Platform.isIOS ? _iosApiKey.substring(0, 10) : _androidApiKey.substring(0, 10)}...',
      );

      // Platform-specific purchase strategy
      if (Platform.isIOS) {
        return await _purchaseRemoveAdsIOS();
      } else {
        return await _purchaseRemoveAdsAndroid();
      }
    } catch (e) {
      final platform = Platform.isIOS ? 'iOS' : 'Android';
      debugPrint('❌ Remove ads purchase failed for $platform: $e');
      rethrow;
    }
  }

  /// iOS-specific remove ads purchase
  Future<CustomerInfo> _purchaseRemoveAdsIOS() async {
    debugPrint('🍎 iOS-specific purchase strategy');

    // First try to get the iOS-specific offering
    final removeAdsOffering = await getRemoveAdsOffering();
    if (removeAdsOffering != null) {
      debugPrint('📦 Found iOS offering: ${removeAdsOffering.identifier}');

      // Look for the lifetime package first
      for (final package in removeAdsOffering.availablePackages) {
        if (package.identifier == _packageIdentifier) {
          debugPrint('✅ Found iOS lifetime package, purchasing...');
          return await purchasePackage(package);
        }
      }

      // If lifetime package not found, try any package with iOS product
      for (final package in removeAdsOffering.availablePackages) {
        if (package.storeProduct.identifier == _premiumProductId) {
          debugPrint('✅ Found iOS remove ads package, purchasing...');
          return await purchasePackage(package);
        }
      }
    }

    // Fallback: Try current offering
    final offerings = await getOfferings();
    if (offerings?.current != null) {
      debugPrint('📦 Trying current iOS offering...');
      for (final package in offerings!.current!.availablePackages) {
        if (package.storeProduct.identifier == _premiumProductId) {
          debugPrint('✅ Found iOS product in current offering, purchasing...');
          return await purchasePackage(package);
        }
      }
    }

    // Final fallback: Direct product purchase for iOS
    debugPrint(
      '⚠️ iOS: Package not found in offerings, trying direct product purchase...',
    );
    return await _directProductPurchase();
  }

  /// Android-specific remove ads purchase
  Future<CustomerInfo> _purchaseRemoveAdsAndroid() async {
    debugPrint('🤖 Android-specific purchase strategy');
    debugPrint('🎯 Target Product: remove_ads_elements (Non-consumable)');
    debugPrint('🎯 Target Offering: remove_ads_elements');

    // Android often works better with direct product purchase
    debugPrint('🔍 Android: Trying direct product purchase first...');

    try {
      final result = await _directProductPurchase();
      debugPrint('✅ Android direct purchase successful');
      return result;
    } catch (e) {
      debugPrint(
        '⚠️ Android direct purchase failed, trying offering approach...',
      );
      debugPrint('❌ Direct purchase error: $e');
    }

    // Fallback: Try offering approach for Android
    final removeAdsOffering = await getRemoveAdsOffering();
    if (removeAdsOffering != null) {
      debugPrint('📦 Found Android offering: ${removeAdsOffering.identifier}');

      // Look for Android-specific product
      for (final package in removeAdsOffering.availablePackages) {
        if (package.storeProduct.identifier == _premiumProductId) {
          debugPrint('✅ Found Android remove ads package, purchasing...');
          return await purchasePackage(package);
        }
      }
    }

    // Final fallback: Try current offering
    final offerings = await getOfferings();
    if (offerings?.current != null) {
      debugPrint('📦 Trying current Android offering...');
      for (final package in offerings!.current!.availablePackages) {
        if (package.storeProduct.identifier == _premiumProductId) {
          debugPrint(
            '✅ Found Android product in current offering, purchasing...',
          );
          return await purchasePackage(package);
        }
      }
    }

    throw Exception(
      'Android: Remove ads product not found in any offering or direct purchase',
    );
  }

  /// Direct product purchase (platform-agnostic)
  Future<CustomerInfo> _directProductPurchase() async {
    debugPrint('🔍 Looking for product directly: $_premiumProductId');

    final products = await getProductsByIds([_premiumProductId]);
    debugPrint('📦 Found ${products.length} products');

    if (products.isEmpty) {
      final platform = Platform.isIOS ? 'iOS' : 'Android';
      debugPrint('❌ $platform: No products found for ID: $_premiumProductId');

      if (Platform.isAndroid) {
        debugPrint('💡 Android Troubleshooting:');
        debugPrint('   1. Check Google Play Console → Monetize → Products');
        debugPrint('   2. Verify remove_ads_elements is Published (not Draft)');
        debugPrint('   3. Check RevenueCat-Google Play Console connection');
        debugPrint('   4. Ensure test device is added to Google Play Console');
        debugPrint('   5. Verify test account is added to Google Play Console');
        debugPrint(
          '   6. Check if Google Play Services is available on device',
        );
      }

      throw Exception(
        '$platform: Remove ads product not found. Please check your RevenueCat and Google Play Console configuration.',
      );
    }

    final product = products.first;
    debugPrint('✅ Found remove ads product directly: ${product.identifier}');
    debugPrint('💰 Product price: ${product.priceString}');
    debugPrint('🏪 Product currency: ${product.currencyCode}');
    debugPrint('📱 Product title: ${product.title}');
    debugPrint('📝 Product description: ${product.description}');
    return await purchaseProduct(product);
  }

  /// Restore purchases (Platform optimized)
  Future<CustomerInfo> restorePurchases() async {
    try {
      final platform = Platform.isIOS ? 'iOS' : 'Android';
      debugPrint('🔄 Starting restore purchases for $platform');

      final customerInfo = await Purchases.restorePurchases();
      await _updateCustomerInfo();

      debugPrint('✅ Restore purchases successful for $platform');
      return customerInfo;
    } catch (e) {
      final platform = Platform.isIOS ? 'iOS' : 'Android';
      debugPrint('❌ Restore purchases failed for $platform: $e');
      rethrow;
    }
  }

  /// Check if user has premium access
  Future<bool> checkPremiumStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final isActive =
          customerInfo.entitlements.all[_premiumProductId]?.isActive ?? false;
      await _updatePremiumStatus(isActive);
      return isActive;
    } catch (e) {
      debugPrint('❌ Failed to check premium status: $e');
      return false;
    }
  }

  /// Get customer info
  Future<CustomerInfo> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('❌ Failed to get customer info: $e');
      rethrow;
    }
  }

  /// Handle customer info updates
  void _onCustomerInfoUpdate(CustomerInfo customerInfo) {
    final isActive =
        customerInfo.entitlements.all[_premiumProductId]?.isActive ?? false;
    _updatePremiumStatus(isActive);
  }

  /// Update premium status
  Future<void> _updatePremiumStatus(bool isPremium) async {
    _isPremium = isPremium;

    // Cache premium status
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, isPremium);

    debugPrint('✅ Premium status updated: $isPremium');
  }

  /// Load cached premium status
  Future<void> _loadCachedPremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremium = prefs.getBool(_premiumKey) ?? false;
      _userId = prefs.getString(_userIdKey);
    } catch (e) {
      debugPrint('❌ Failed to load cached premium status: $e');
    }
  }

  /// Update customer info
  Future<void> _updateCustomerInfo() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final isActive =
          customerInfo.entitlements.all[_premiumProductId]?.isActive ?? false;
      await _updatePremiumStatus(isActive);
    } catch (e) {
      debugPrint('❌ Failed to update customer info: $e');

      // Handle Android billing availability errors gracefully
      if (Platform.isAndroid) {
        final errorString = e.toString().toLowerCase();
        if (errorString.contains('billing') &&
            (errorString.contains('unavailable') ||
                errorString.contains('not available'))) {
          debugPrint('⚠️ Android billing service unavailable on this device');
          debugPrint('💡 This is normal for:');
          debugPrint('   - Emulators without Google Play Services');
          debugPrint('   - Devices without Google Play Store');
          debugPrint('   - Devices with outdated Google Play Services');
          debugPrint('   - Test devices not properly configured');
          debugPrint('✅ App will continue with cached premium status');
          return;
        }
      }

      // For other errors, just log them but don't throw
      debugPrint('⚠️ Customer info update failed, using cached status');
    }
  }

  /// Log out user
  Future<void> logOut() async {
    try {
      await Purchases.logOut();
      _userId = null;
      await _updatePremiumStatus(false);

      // Clear cached user ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);

      debugPrint('✅ RevenueCat user logged out');
    } catch (e) {
      debugPrint('❌ Failed to log out RevenueCat user: $e');
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    Purchases.removeCustomerInfoUpdateListener(_onCustomerInfoUpdate);
    _isInitialized = false;
  }
}
