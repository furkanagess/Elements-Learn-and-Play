import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// RevenueCat service for handling in-app purchases and subscriptions
class RevenueCatService {
  static const String _premiumKey = 'is_premium_user';
  static const String _userIdKey = 'revenue_cat_user_id';

  // RevenueCat API Keys
  static const String _androidApiKey =
      'goog_YOUR_ANDROID_API_KEY_HERE'; // Replace with your actual Android key from RevenueCat dashboard
  static const String _iosApiKey =
      'appl_WOGaKGocybabmcYEOKXeeUOWPfq'; // Your iOS API key

  // Product IDs - Your actual product IDs
  static const String _premiumProductId = 'remove_elements_ads';

  // Offering and Package identifiers from RevenueCat dashboard
  static const String _offeringIdentifier = 'remove_elements_ads';
  static const String _packageIdentifier = '\$rc_lifetime';

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

  /// Initialize RevenueCat
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configure RevenueCat
      final apiKey = Platform.isIOS ? _iosApiKey : _androidApiKey;

      await Purchases.setLogLevel(LogLevel.debug);
      await Purchases.configure(PurchasesConfiguration(apiKey));

      // Set up listener for customer info updates
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdate);

      // Load cached premium status
      await _loadCachedPremiumStatus();

      // Get current customer info
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
      final offerings = await Purchases.getOfferings();

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
      final offerings = await Purchases.getOfferings();

      if (offerings.all[identifier] != null) {
        debugPrint('✅ Found offering: $identifier');
        return offerings.all[identifier];
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

      if (result.entitlements.all[_premiumProductId]?.isActive == true) {
        await _updatePremiumStatus(true);
      }

      return result;
    } catch (e) {
      debugPrint('❌ Purchase failed: $e');
      rethrow;
    }
  }

  /// Purchase a package
  Future<CustomerInfo> purchasePackage(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);

      if (result.entitlements.all[_premiumProductId]?.isActive == true) {
        await _updatePremiumStatus(true);
      }

      return result;
    } catch (e) {
      debugPrint('❌ Package purchase failed: $e');
      rethrow;
    }
  }

  /// Purchase remove ads product directly (iOS optimized)
  Future<CustomerInfo> purchaseRemoveAds() async {
    try {
      // First try to get the specific "remove_elements_ads" offering
      final removeAdsOffering = await getRemoveAdsOffering();
      if (removeAdsOffering != null) {
        // Look for the lifetime package
        for (final package in removeAdsOffering.availablePackages) {
          if (package.identifier == _packageIdentifier) {
            debugPrint(
              '✅ Found lifetime package in remove_elements_ads offering, purchasing...',
            );
            return await purchasePackage(package);
          }
        }

        // If lifetime package not found, try any package with remove_elements_ads product
        for (final package in removeAdsOffering.availablePackages) {
          if (package.storeProduct.identifier == _premiumProductId) {
            debugPrint(
              '✅ Found remove ads package in remove_elements_ads offering, purchasing...',
            );
            return await purchasePackage(package);
          }
        }
      }

      // Fallback: Try current offering
      final offerings = await getOfferings();
      if (offerings?.current != null) {
        for (final package in offerings!.current!.availablePackages) {
          if (package.storeProduct.identifier == _premiumProductId) {
            debugPrint(
              '✅ Found remove ads package in current offering, purchasing...',
            );
            return await purchasePackage(package);
          }
        }
      }

      // Final fallback: Get product directly and purchase
      debugPrint(
        '⚠️ Package not found in offerings, trying direct product purchase...',
      );
      final products = await getProductsByIds([_premiumProductId]);

      if (products.isEmpty) {
        throw Exception(
          'Remove ads product not found. Please check your RevenueCat configuration.',
        );
      }

      final product = products.first;
      debugPrint('✅ Found remove ads product directly, purchasing...');
      return await purchaseProduct(product);
    } catch (e) {
      debugPrint('❌ Remove ads purchase failed: $e');
      rethrow;
    }
  }

  /// Restore purchases
  Future<CustomerInfo> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      await _updateCustomerInfo();
      return customerInfo;
    } catch (e) {
      debugPrint('❌ Restore purchases failed: $e');
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
