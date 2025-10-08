import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/feature/provider/purchase_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';

/// Dialog to show purchase errors with localized messages
class PurchaseErrorDialog extends StatelessWidget {
  final Map<String, dynamic> errorDetails;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const PurchaseErrorDialog({
    super.key,
    required this.errorDetails,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final localizationProvider = context.watch<LocalizationProvider>();
    final isTurkish = localizationProvider.isTr;

    return AlertDialog(
      title: Row(
        children: [
          Text(
            errorDetails['icon'] ?? '⚠️',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isTurkish ? 'Satın Alma Hatası' : 'Purchase Error',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error message
          Text(
            errorDetails['message'] ??
                (isTurkish
                    ? 'Bilinmeyen bir hata oluştu'
                    : 'An unknown error occurred'),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          // Error reason
          if (errorDetails['reason'] != null) ...[
            Text(
              isTurkish ? 'Neden:' : 'Reason:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              errorDetails['reason'],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
          ],

          // Solution
          if (errorDetails['solution'] != null) ...[
            Text(
              isTurkish ? 'Çözüm:' : 'Solution:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              errorDetails['solution'],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
      actions: [
        // Dismiss button
        TextButton(
          onPressed: onDismiss ?? () => Navigator.of(context).pop(),
          child: Text(isTurkish ? 'Tamam' : 'OK'),
        ),

        // Retry button (if provided)
        if (onRetry != null)
          ElevatedButton(
            onPressed: onRetry,
            child: Text(isTurkish ? 'Tekrar Dene' : 'Try Again'),
          ),
      ],
    );
  }

  /// Show purchase error dialog
  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> errorDetails,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PurchaseErrorDialog(
        errorDetails: errorDetails,
        onRetry: onRetry,
        onDismiss: onDismiss,
      ),
    );
  }
}

/// Dialog to show purchase success with localized messages
class PurchaseSuccessDialog extends StatelessWidget {
  final Map<String, dynamic> successDetails;
  final VoidCallback? onDismiss;

  const PurchaseSuccessDialog({
    super.key,
    required this.successDetails,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final localizationProvider = context.watch<LocalizationProvider>();
    final isTurkish = localizationProvider.isTr;

    return AlertDialog(
      title: Row(
        children: [
          Text(
            successDetails['icon'] ?? '🎉',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isTurkish ? 'Başarılı!' : 'Success!',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.green),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success message
          Text(
            successDetails['message'] ??
                (isTurkish
                    ? 'İşlem başarıyla tamamlandı!'
                    : 'Operation completed successfully!'),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          // Congratulations message
          if (successDetails['congratulations'] != null) ...[
            Text(
              successDetails['congratulations'],
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
          ],

          // Benefits list
          if (successDetails['benefits'] != null) ...[
            Text(
              isTurkish ? 'Premium özellikleriniz:' : 'Your premium features:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ...successDetails['benefits'].map<Widget>(
              (benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('✅ ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        benefit,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: onDismiss ?? () => Navigator.of(context).pop(),
          child: Text(isTurkish ? 'Harika!' : 'Awesome!'),
        ),
      ],
    );
  }

  /// Show purchase success dialog
  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> successDetails,
    VoidCallback? onDismiss,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PurchaseSuccessDialog(
        successDetails: successDetails,
        onDismiss: onDismiss,
      ),
    );
  }
}

/// Helper class to handle purchase operations with localized error handling
class PurchaseHelper {
  /// Purchase remove ads with localized error handling
  static Future<void> purchaseRemoveAds(
    BuildContext context, {
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) async {
    final purchaseProvider = context.read<PurchaseProvider>();
    final localizationProvider = context.read<LocalizationProvider>();
    final isTurkish = localizationProvider.isTr;

    try {
      final result = await purchaseProvider.directPurchaseRemoveAdsWithDetails(
        isTurkish: isTurkish,
      );

      if (result['success'] == true) {
        // Show success dialog
        await PurchaseSuccessDialog.show(context, successDetails: result);
        onSuccess?.call();
      } else {
        // Show error dialog
        await PurchaseErrorDialog.show(
          context,
          errorDetails: result,
          onRetry: () => purchaseRemoveAds(
            context,
            onSuccess: onSuccess,
            onError: onError,
          ),
        );
        onError?.call();
      }
    } catch (e) {
      // Show generic error dialog
      await PurchaseErrorDialog.show(
        context,
        errorDetails: {
          'message': isTurkish
              ? 'Beklenmeyen bir hata oluştu'
              : 'An unexpected error occurred',
          'reason': isTurkish
              ? 'Satın alma işlemi sırasında bir sorun oluştu'
              : 'A problem occurred during the purchase process',
          'solution': isTurkish ? 'Lütfen tekrar deneyin' : 'Please try again',
          'icon': '⚠️',
        },
        onRetry: () =>
            purchaseRemoveAds(context, onSuccess: onSuccess, onError: onError),
      );
      onError?.call();
    }
  }

  /// Restore purchases with localized error handling
  static Future<void> restorePurchases(
    BuildContext context, {
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) async {
    final purchaseProvider = context.read<PurchaseProvider>();
    final localizationProvider = context.read<LocalizationProvider>();
    final isTurkish = localizationProvider.isTr;

    try {
      final result = await purchaseProvider.restorePurchasesWithDetails(
        isTurkish: isTurkish,
      );

      if (result['success'] == true) {
        // Show success dialog
        await PurchaseSuccessDialog.show(context, successDetails: result);
        onSuccess?.call();
      } else {
        // Show error dialog
        await PurchaseErrorDialog.show(
          context,
          errorDetails: result,
          onRetry: () =>
              restorePurchases(context, onSuccess: onSuccess, onError: onError),
        );
        onError?.call();
      }
    } catch (e) {
      // Show generic error dialog
      await PurchaseErrorDialog.show(
        context,
        errorDetails: {
          'message': isTurkish
              ? 'Beklenmeyen bir hata oluştu'
              : 'An unexpected error occurred',
          'reason': isTurkish
              ? 'Geri yükleme işlemi sırasında bir sorun oluştu'
              : 'A problem occurred during the restore process',
          'solution': isTurkish ? 'Lütfen tekrar deneyin' : 'Please try again',
          'icon': '⚠️',
        },
        onRetry: () =>
            restorePurchases(context, onSuccess: onSuccess, onError: onError),
      );
      onError?.call();
    }
  }
}
