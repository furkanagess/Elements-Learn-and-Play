import 'dart:io';
import 'package:flutter/foundation.dart';

/// Service to provide localized purchase error messages
class PurchaseErrorLocalizationService {
  static PurchaseErrorLocalizationService? _instance;

  PurchaseErrorLocalizationService._internal();

  static PurchaseErrorLocalizationService get instance {
    _instance ??= PurchaseErrorLocalizationService._internal();
    return _instance!;
  }

  /// Parse purchase error and return localized error details
  Map<String, String> parsePurchaseError(
    dynamic error, {
    bool isTurkish = true,
  }) {
    final errorString = error.toString().toLowerCase();
    final storeName = Platform.isIOS ? 'App Store' : 'Google Play';

    if (isTurkish) {
      return _parseErrorTurkish(errorString, storeName);
    } else {
      return _parseErrorEnglish(errorString, storeName);
    }
  }

  /// Parse error in Turkish
  Map<String, String> _parseErrorTurkish(String errorString, String storeName) {
    // Network errors
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('unreachable')) {
      return {
        'message': 'İnternet bağlantınızı kontrol edin',
        'reason': 'İnternet bağlantınız kesilmiş veya yavaş olabilir',
        'solution':
            'Wi-Fi veya mobil veri bağlantınızı kontrol edip tekrar deneyin',
        'icon': '🌐',
      };
    }

    // Payment errors
    if (errorString.contains('payment') ||
        errorString.contains('billing') ||
        errorString.contains('card') ||
        errorString.contains('declined')) {
      return {
        'message': 'Ödeme bilgilerinizi kontrol edin',
        'reason':
            'Kartınız reddedilmiş veya ödeme bilgilerinizde sorun olabilir',
        'solution':
            'Kart bilgilerinizi kontrol edin veya farklı bir ödeme yöntemi deneyin',
        'icon': '💳',
      };
    }

    // User cancellation
    if (errorString.contains('cancel') ||
        errorString.contains('user') ||
        errorString.contains('abort') ||
        errorString.contains('dismiss')) {
      return {
        'message': 'Satın alma iptal edildi',
        'reason': 'İşlemi iptal ettiniz veya çıkış yaptınız',
        'solution': 'İstediğiniz zaman tekrar satın alabilirsiniz',
        'icon': '❌',
      };
    }

    // Product not found
    if (errorString.contains('product') ||
        errorString.contains('not found') ||
        errorString.contains('unavailable') ||
        errorString.contains('missing')) {
      return {
        'message': 'Ürün şu anda mevcut değil',
        'reason': 'Ürün mağazada bulunamadı veya geçici olarak kaldırılmış',
        'solution':
            'Lütfen daha sonra tekrar deneyin veya uygulamayı güncelleyin',
        'icon': '🔍',
      };
    }

    // Store errors
    if (errorString.contains('store') ||
        errorString.contains('app store') ||
        errorString.contains('itunes') ||
        errorString.contains('play store') ||
        errorString.contains('google play')) {
      return {
        'message': '$storeName servisi geçici olarak kullanılamıyor',
        'reason': '$storeName servislerinde geçici bir sorun var',
        'solution': 'Birkaç dakika sonra tekrar deneyin',
        'icon': '🏪',
      };
    }

    // Configuration errors
    if (errorString.contains('config') ||
        errorString.contains('setup') ||
        errorString.contains('api') ||
        errorString.contains('key')) {
      return {
        'message': 'Uygulama yapılandırması hatası',
        'reason': 'Uygulama ayarlarında bir sorun oluştu',
        'solution':
            'Uygulamayı güncelleyin veya destek ekibiyle iletişime geçin',
        'icon': '⚙️',
      };
    }

    // Insufficient funds
    if (errorString.contains('fund') ||
        errorString.contains('balance') ||
        errorString.contains('insufficient') ||
        errorString.contains('limit')) {
      return {
        'message': 'Yetersiz bakiye',
        'reason': 'Hesabınızda yeterli bakiye bulunmuyor',
        'solution': 'Hesabınıza yeterli bakiye ekleyip tekrar deneyin',
        'icon': '💰',
      };
    }

    // Account issues
    if (errorString.contains('account') ||
        errorString.contains('login') ||
        errorString.contains('auth') ||
        errorString.contains('sign')) {
      return {
        'message': 'Hesap doğrulama hatası',
        'reason':
            'Hesap bilgilerinizde bir sorun var veya oturum süreniz dolmuş',
        'solution': 'Hesabınızdan çıkış yapıp tekrar giriş yapın',
        'icon': '👤',
      };
    }

    // Generic error
    return {
      'message': 'Beklenmeyen bir hata oluştu',
      'reason': 'Bilinmeyen bir sorun nedeniyle işlem tamamlanamadı',
      'solution':
          'Lütfen tekrar deneyin veya sorun devam ederse destek ekibiyle iletişime geçin',
      'icon': '⚠️',
    };
  }

  /// Parse error in English
  Map<String, String> _parseErrorEnglish(String errorString, String storeName) {
    // Network errors
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('unreachable')) {
      return {
        'message': 'Check your internet connection',
        'reason': 'Your internet connection may be lost or slow',
        'solution': 'Check your Wi-Fi or mobile data connection and try again',
        'icon': '🌐',
      };
    }

    // Payment errors
    if (errorString.contains('payment') ||
        errorString.contains('billing') ||
        errorString.contains('card') ||
        errorString.contains('declined')) {
      return {
        'message': 'Check your payment information',
        'reason':
            'Your card may have been declined or there may be an issue with your payment information',
        'solution': 'Check your card details or try a different payment method',
        'icon': '💳',
      };
    }

    // User cancellation
    if (errorString.contains('cancel') ||
        errorString.contains('user') ||
        errorString.contains('abort') ||
        errorString.contains('dismiss')) {
      return {
        'message': 'Purchase cancelled',
        'reason': 'You cancelled the transaction or exited',
        'solution': 'You can purchase again anytime you want',
        'icon': '❌',
      };
    }

    // Product not found
    if (errorString.contains('product') ||
        errorString.contains('not found') ||
        errorString.contains('unavailable') ||
        errorString.contains('missing')) {
      return {
        'message': 'Product is currently unavailable',
        'reason':
            'Product was not found in the store or has been temporarily removed',
        'solution': 'Please try again later or update the app',
        'icon': '🔍',
      };
    }

    // Store errors
    if (errorString.contains('store') ||
        errorString.contains('app store') ||
        errorString.contains('itunes') ||
        errorString.contains('play store') ||
        errorString.contains('google play')) {
      return {
        'message': '$storeName service is temporarily unavailable',
        'reason': 'There is a temporary issue with $storeName services',
        'solution': 'Please try again in a few minutes',
        'icon': '🏪',
      };
    }

    // Configuration errors
    if (errorString.contains('config') ||
        errorString.contains('setup') ||
        errorString.contains('api') ||
        errorString.contains('key')) {
      return {
        'message': 'Application configuration error',
        'reason': 'There was an issue with the application settings',
        'solution': 'Update the app or contact support team',
        'icon': '⚙️',
      };
    }

    // Insufficient funds
    if (errorString.contains('fund') ||
        errorString.contains('balance') ||
        errorString.contains('insufficient') ||
        errorString.contains('limit')) {
      return {
        'message': 'Insufficient balance',
        'reason': 'You don\'t have enough balance in your account',
        'solution': 'Add sufficient balance to your account and try again',
        'icon': '💰',
      };
    }

    // Account issues
    if (errorString.contains('account') ||
        errorString.contains('login') ||
        errorString.contains('auth') ||
        errorString.contains('sign')) {
      return {
        'message': 'Account verification error',
        'reason':
            'There is an issue with your account information or your session has expired',
        'solution': 'Sign out and sign in again to your account',
        'icon': '👤',
      };
    }

    // Generic error
    return {
      'message': 'An unexpected error occurred',
      'reason': 'The operation could not be completed due to an unknown issue',
      'solution': 'Please try again or contact support if the problem persists',
      'icon': '⚠️',
    };
  }

  /// Get localized success messages
  Map<String, dynamic> getSuccessMessage({bool isTurkish = true}) {
    if (isTurkish) {
      return {
        'message': 'Satın alım başarıyla tamamlandı!',
        'congratulations': 'Premium özellikleriniz aktif edildi!',
        'benefits': [
          'Reklamsız deneyim',
          'Quizlerde fazladan can',
          'Premium özellikler',
        ],
        'icon': '🎉',
      };
    } else {
      return {
        'message': 'Purchase completed successfully!',
        'congratulations': 'Your premium features have been activated!',
        'benefits': [
          'Ad-free experience',
          'Extra lives in quizzes',
          'Premium features',
        ],
        'icon': '🎉',
      };
    }
  }

  /// Get localized restore messages
  Map<String, dynamic> getRestoreMessage({
    bool isTurkish = true,
    bool hasPurchases = false,
  }) {
    if (isTurkish) {
      if (hasPurchases) {
        return {
          'message': 'Satın alımlar başarıyla geri yüklendi!',
          'congratulations': 'Premium özellikleriniz aktif edildi!',
          'benefits': [
            'Reklamsız deneyim',
            'Quizlerde fazladan can',
            'Premium özellikler',
          ],
          'icon': '🎉',
        };
      } else {
        final accountType = Platform.isIOS ? 'Apple ID' : 'Google hesabı';
        return {
          'message': 'Geri yüklenecek satın alım bulunamadı',
          'reason': 'Bu cihazda daha önce yapılmış bir satın alım bulunamadı',
          'solution':
              'Farklı bir $accountType ile giriş yapmayı deneyin veya satın alım yapın',
          'icon': '🔍',
        };
      }
    } else {
      if (hasPurchases) {
        return {
          'message': 'Purchases restored successfully!',
          'congratulations': 'Your premium features have been activated!',
          'benefits': [
            'Ad-free experience',
            'Extra lives in quizzes',
            'Premium features',
          ],
          'icon': '🎉',
        };
      } else {
        final accountType = Platform.isIOS ? 'Apple ID' : 'Google account';
        return {
          'message': 'No purchases found to restore',
          'reason': 'No previous purchases were found on this device',
          'solution':
              'Try signing in with a different $accountType or make a purchase',
          'icon': '🔍',
        };
      }
    }
  }

  /// Log error for debugging
  void logError(dynamic error, {bool isTurkish = true}) {
    if (kDebugMode) {
      final errorDetails = parsePurchaseError(error, isTurkish: isTurkish);
      debugPrint('❌ Purchase Error (${isTurkish ? 'TR' : 'EN'}):');
      debugPrint('   Message: ${errorDetails['message']}');
      debugPrint('   Reason: ${errorDetails['reason']}');
      debugPrint('   Solution: ${errorDetails['solution']}');
      debugPrint('   Original Error: $error');
    }
  }
}
