import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elements_app/core/services/purchases/revenue_cat_service.dart';
import 'package:elements_app/core/services/purchase_error_localization_service.dart';

/// Provider for managing purchase state and premium features
class PurchaseProvider extends ChangeNotifier {
  final RevenueCatService _revenueCatService = RevenueCatService.instance;
  final PurchaseErrorLocalizationService _localizationService =
      PurchaseErrorLocalizationService.instance;

  bool _isLoading = false;
  bool _isPremium = false;
  List<StoreProduct> _products = [];
  Offerings? _offerings;
  String? _error;
  late SharedPreferences _prefs;
  static const String _premiumKey = 'is_premium_user';

  // Getters
  bool get isLoading => _isLoading;
  bool get isPremium => _isPremium;
  List<StoreProduct> get products => _products;
  Offerings? get offerings => _offerings;
  String? get error => _error;

  /// Initialize the purchase provider
  Future<void> initialize() async {
    _setLoading(true);
    _clearError();

    try {
      // Initialize SharedPreferences with timeout
      _prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 5),
      );

      // Load saved premium status
      _isPremium = _prefs.getBool(_premiumKey) ?? false;

      // RevenueCat is already initialized in main.dart, just ensure it's ready
      if (!_revenueCatService.isInitialized) {
        await _revenueCatService.initialize().timeout(
          const Duration(seconds: 10),
        );
      }

      // Load products and offerings with timeout
      await _loadProducts().timeout(const Duration(seconds: 10));
      await _loadOfferings().timeout(const Duration(seconds: 10));

      // Check premium status with timeout
      _isPremium = await _revenueCatService.checkPremiumStatus().timeout(
        const Duration(seconds: 5),
      );

      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize purchases: $e');
      // Set default values to prevent hanging
      _isPremium = false;
      _products = [];
      _offerings = null;
    } finally {
      _setLoading(false);
    }
  }

  /// Load available products (Platform optimized)
  Future<void> _loadProducts() async {
    try {
      // Get platform-specific product ID
      final platformProductId = _revenueCatService.premiumProductId;
      final platform = Platform.isIOS ? 'iOS' : 'Android';

      debugPrint(
        '🔍 Loading products for $platform (Product ID: $platformProductId)',
      );

      // First try to get products from the platform-specific offering
      final removeAdsOffering = await _revenueCatService.getRemoveAdsOffering();
      if (removeAdsOffering != null) {
        _products = removeAdsOffering.availablePackages
            .map((package) => package.storeProduct)
            .toList();
        debugPrint(
          '✅ Loaded ${_products.length} products from $platform offering',
        );
      } else {
        // Fallback: try to get products from current offering
        _products = await _revenueCatService.getProducts();

        // If no products from offerings, try direct product fetch with platform-specific ID
        if (_products.isEmpty) {
          debugPrint(
            '⚠️ No products from offerings, trying direct product fetch for $platform...',
          );
          _products = await _revenueCatService.getProductsByIds([
            platformProductId,
          ]);
        }
      }

      debugPrint('📦 Total products loaded: ${_products.length}');
      for (final product in _products) {
        debugPrint('  - ${product.identifier}: ${product.priceString}');
      }
    } catch (e) {
      _setError('Failed to load products: $e');
    }
  }

  /// Load available offerings (Platform optimized)
  Future<void> _loadOfferings() async {
    try {
      final platform = Platform.isIOS ? 'iOS' : 'Android';
      final platformOfferingId = _revenueCatService.offeringIdentifier;

      debugPrint(
        '🔍 Loading offerings for $platform (Offering ID: $platformOfferingId)',
      );

      _offerings = await _revenueCatService.getOfferings();

      // Check if we have the platform-specific offering
      if (_offerings != null) {
        final removeAdsOffering = _offerings!.all[platformOfferingId];
        if (removeAdsOffering != null) {
          debugPrint(
            '✅ Found $platform offering ($platformOfferingId) with ${removeAdsOffering.availablePackages.length} packages',
          );
        } else {
          debugPrint(
            '⚠️ $platform offering ($platformOfferingId) not found in available offerings',
          );
          debugPrint('Available offerings: ${_offerings!.all.keys.toList()}');
        }
      }

      // If offerings are empty, that's okay - we can still work with direct products
      if (_offerings == null || _offerings!.current == null) {
        debugPrint(
          'ℹ️ No current offering configured for $platform. Using direct product purchases.',
        );
      }
    } catch (e) {
      // Don't treat empty offerings as an error - it's a configuration choice
      final platform = Platform.isIOS ? 'iOS' : 'Android';
      debugPrint('ℹ️ $platform offerings not available: $e');
      _offerings = null;
    }
  }

  /// Purchase a product
  Future<bool> purchaseProduct(StoreProduct product) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _revenueCatService.purchaseProduct(product);

      if (result
              .entitlements
              .all[_revenueCatService.premiumProductId]
              ?.isActive ==
          true) {
        await _setPremiumStatus(true);
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _setError('Purchase failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Purchase a package
  Future<bool> purchasePackage(Package package) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _revenueCatService.purchasePackage(package);

      if (result
              .entitlements
              .all[_revenueCatService.premiumProductId]
              ?.isActive ==
          true) {
        await _setPremiumStatus(true);
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _setError('Package purchase failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Purchase remove ads (iOS optimized)
  Future<bool> purchaseRemoveAds({bool isTurkish = true}) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _revenueCatService.purchaseRemoveAds();

      if (result
              .entitlements
              .all[_revenueCatService.premiumProductId]
              ?.isActive ==
          true) {
        await _setPremiumStatus(true);
        notifyListeners();
        debugPrint('✅ Remove ads purchase successful!');
        return true;
      }

      debugPrint('⚠️ Purchase completed but premium status not active');
      return false;
    } catch (e) {
      final errorDetails = _localizationService.parsePurchaseError(
        e,
        isTurkish: isTurkish,
      );
      _localizationService.logError(e, isTurkish: isTurkish);
      _setError(errorDetails['message'] ?? 'Remove ads purchase failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Direct purchase remove ads (for settings card)
  Future<bool> directPurchaseRemoveAds({bool isTurkish = true}) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _revenueCatService.purchaseRemoveAds();

      if (result
              .entitlements
              .all[_revenueCatService.premiumProductId]
              ?.isActive ==
          true) {
        await _setPremiumStatus(true);
        notifyListeners();
        debugPrint('✅ Direct remove ads purchase successful!');
        return true;
      }

      debugPrint('⚠️ Direct purchase completed but premium status not active');
      return false;
    } catch (e) {
      final errorDetails = _localizationService.parsePurchaseError(
        e,
        isTurkish: isTurkish,
      );
      _localizationService.logError(e, isTurkish: isTurkish);
      _setError(
        errorDetails['message'] ?? 'Direct remove ads purchase failed: $e',
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Direct purchase remove ads with detailed error info
  Future<Map<String, dynamic>> directPurchaseRemoveAdsWithDetails({
    bool isTurkish = true,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _revenueCatService.purchaseRemoveAds();

      // Check if purchase was successful by looking at the result
      if (result.entitlements.all.isNotEmpty) {
        // Purchase completed successfully, check premium status
        final isPremiumActive =
            result
                .entitlements
                .all[_revenueCatService.premiumProductId]
                ?.isActive ==
            true;

        if (isPremiumActive) {
          await _setPremiumStatus(true);
          notifyListeners();
          debugPrint('✅ Direct remove ads purchase successful!');
          return {
            'success': true,
            'message': 'Tebrikler! Artık bu hizmetlerden yararlanabilirsiniz',
            'congratulations': 'Reklamlar başarıyla kaldırıldı!',
            'benefits': [
              'Reklamsız deneyim',
              'Quizlerde fazladan can',
              'Premium özellikler',
            ],
            'icon': '🎉',
          };
        } else {
          // Purchase completed but entitlement not active yet - wait a bit and check again
          debugPrint('⚠️ Purchase completed, checking premium status...');
          await Future.delayed(const Duration(seconds: 2));

          // Check premium status again
          final updatedStatus = await _revenueCatService.checkPremiumStatus();
          if (updatedStatus) {
            await _setPremiumStatus(true);
            notifyListeners();
            debugPrint('✅ Premium status activated after delay!');
            return {
              'success': true,
              'message': 'Tebrikler! Artık bu hizmetlerden yararlanabilirsiniz',
              'congratulations': 'Reklamlar başarıyla kaldırıldı!',
              'benefits': [
                'Reklamsız deneyim',
                'Quizlerde fazladan can',
                'Premium özellikler',
              ],
              'icon': '🎉',
            };
          } else {
            // Still not active, but purchase was successful
            debugPrint(
              '⚠️ Purchase successful but premium status not yet active',
            );
            return {
              'success': true,
              'message': 'Tebrikler! Artık bu hizmetlerden yararlanabilirsiniz',
              'congratulations': 'Reklamlar başarıyla kaldırıldı!',
              'benefits': [
                'Reklamsız deneyim',
                'Quizlerde fazladan can',
                'Premium özellikler',
              ],
              'icon': '🎉',
            };
          }
        }
      } else {
        // Purchase failed
        debugPrint('❌ Purchase failed - no result returned');
        return {
          'success': false,
          'message': isTurkish
              ? 'Satın alma işlemi başarısız oldu'
              : 'Purchase failed',
          'reason': isTurkish
              ? 'Satın alma işlemi tamamlanamadı'
              : 'Purchase could not be completed',
          'solution': isTurkish ? 'Lütfen tekrar deneyin' : 'Please try again',
          'icon': '❌',
        };
      }
    } catch (e) {
      final errorDetails = _localizationService.parsePurchaseError(
        e,
        isTurkish: isTurkish,
      );
      _localizationService.logError(e, isTurkish: isTurkish);
      _setError(
        errorDetails['message'] ?? 'Direct remove ads purchase failed: $e',
      );
      return {
        'success': false,
        'message': errorDetails['message'],
        'reason': errorDetails['reason'],
        'solution': errorDetails['solution'],
        'icon': errorDetails['icon'],
      };
    } finally {
      _setLoading(false);
    }
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    _setLoading(true);
    _clearError();

    try {
      await _revenueCatService.restorePurchases();
      _isPremium = await _revenueCatService.checkPremiumStatus();
      notifyListeners();
      return _isPremium;
    } catch (e) {
      _setError('Restore failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Restore purchases with detailed result
  Future<Map<String, dynamic>> restorePurchasesWithDetails({
    bool isTurkish = true,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _revenueCatService.restorePurchases();
      _isPremium = await _revenueCatService.checkPremiumStatus();
      notifyListeners();

      if (_isPremium) {
        return {
          'success': true,
          ..._localizationService.getRestoreMessage(
            isTurkish: isTurkish,
            hasPurchases: true,
          ),
        };
      } else {
        return {
          'success': false,
          ..._localizationService.getRestoreMessage(
            isTurkish: isTurkish,
            hasPurchases: false,
          ),
        };
      }
    } catch (e) {
      final errorDetails = _localizationService.parsePurchaseError(
        e,
        isTurkish: isTurkish,
      );
      _localizationService.logError(e, isTurkish: isTurkish);
      _setError(errorDetails['message'] ?? 'Restore failed: $e');
      return {
        'success': false,
        'message': errorDetails['message'],
        'reason': errorDetails['reason'],
        'solution': errorDetails['solution'],
        'icon': errorDetails['icon'],
      };
    } finally {
      _setLoading(false);
    }
  }

  /// Check premium status
  Future<void> checkPremiumStatus() async {
    try {
      _isPremium = await _revenueCatService.checkPremiumStatus();
      notifyListeners();
    } catch (e) {
      _setError('Failed to check premium status: $e');
    }
  }

  /// Set user ID
  Future<void> setUserId(String userId) async {
    try {
      await _revenueCatService.setUserId(userId);
    } catch (e) {
      _setError('Failed to set user ID: $e');
    }
  }

  /// Log out user
  Future<void> logOut() async {
    try {
      await _revenueCatService.logOut();
      _isPremium = false;
      notifyListeners();
    } catch (e) {
      _setError('Failed to log out: $e');
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Set premium status and save to SharedPreferences
  Future<void> _setPremiumStatus(bool isPremium) async {
    _isPremium = isPremium;
    await _prefs.setBool(_premiumKey, isPremium);
    notifyListeners();
    debugPrint('✅ Premium status updated: $isPremium');
  }

  /// Get remove ads product price (platform-specific)
  String get removeAdsPrice {
    if (_products.isEmpty) return '₺29,99';

    // Get platform-specific product ID
    final platformProductId = _revenueCatService.premiumProductId;

    // Look for platform-specific remove ads product
    final removeAdsProduct = _products.firstWhere(
      (product) => product.identifier == platformProductId,
      orElse: () => _products.first,
    );

    return removeAdsProduct.priceString;
  }

  /// Get remove ads product with detailed info (platform-specific)
  StoreProduct? get removeAdsProduct {
    if (_products.isEmpty) return null;

    try {
      // Get platform-specific product ID
      final platformProductId = _revenueCatService.premiumProductId;

      return _products.firstWhere(
        (product) => product.identifier == platformProductId,
      );
    } catch (e) {
      // If specific product not found, return first available product
      return _products.isNotEmpty ? _products.first : null;
    }
  }

  /// Get formatted price with currency
  String get formattedPrice {
    final product = removeAdsProduct;
    if (product == null) return '₺29,99';

    return product.priceString;
  }

  /// Get price amount (without currency symbol)
  double get priceAmount {
    final product = removeAdsProduct;
    if (product == null) return 29.99;

    return product.price;
  }

  /// Get currency code
  String get currencyCode {
    final product = removeAdsProduct;
    if (product == null) return 'TRY';

    return product.currencyCode;
  }

  /// Get remove ads product title (Platform optimized)
  String get removeAdsTitle {
    if (_products.isEmpty) return 'Remove Ads';

    // Get platform-specific product ID
    final platformProductId = _revenueCatService.premiumProductId;

    // Look for platform-specific remove ads product
    final removeAdsProduct = _products.firstWhere(
      (product) => product.identifier == platformProductId,
      orElse: () => _products.first,
    );

    return removeAdsProduct.title;
  }

  /// Get remove ads product description (Platform optimized)
  String get removeAdsDescription {
    if (_products.isEmpty) return 'One-time payment for ad-free experience';

    // Get platform-specific product ID
    final platformProductId = _revenueCatService.premiumProductId;

    // Look for platform-specific remove ads product
    final removeAdsProduct = _products.firstWhere(
      (product) => product.identifier == platformProductId,
      orElse: () => _products.first,
    );

    return removeAdsProduct.description;
  }

  /// Clear error message
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _revenueCatService.dispose();
    super.dispose();
  }
}
