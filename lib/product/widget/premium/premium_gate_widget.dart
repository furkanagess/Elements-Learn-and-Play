import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/feature/provider/purchase_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/widget/premium/premium_features_widget.dart';

/// Widget that shows premium features dialog when user tries to access premium content
class PremiumGateWidget extends StatelessWidget {
  final Widget child;
  final String? featureName;
  final VoidCallback? onPremiumAccess;

  const PremiumGateWidget({
    super.key,
    required this.child,
    this.featureName,
    this.onPremiumAccess,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PurchaseProvider>(
      builder: (context, purchaseProvider, child) {
        if (purchaseProvider.isPremium) {
          return this.child;
        }

        return _buildPremiumGate(context, purchaseProvider);
      },
    );
  }

  Widget _buildPremiumGate(BuildContext context, PurchaseProvider provider) {
    final isTr = context.watch<LocalizationProvider>().isTr;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.glowGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lock icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.glowGreen.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.glowGreen.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: const Icon(Icons.lock, color: AppColors.glowGreen, size: 32),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            isTr ? 'Premium Özellik' : 'Premium Feature',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            featureName != null
                ? (isTr
                      ? '$featureName özelliğine erişmek için Premium\'a yükseltin'
                      : 'Upgrade to Premium to access $featureName')
                : (isTr
                      ? 'Bu özelliğe erişmek için Premium\'a yükseltin'
                      : 'Upgrade to Premium to access this feature'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),

          // Upgrade button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showPremiumDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.glowGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                isTr ? 'Premium\'a Yükselt' : 'Upgrade to Premium',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Restore purchases button
          TextButton(
            onPressed: () => _restorePurchases(context, provider),
            child: Text(
              isTr ? 'Satın alımları geri yükle' : 'Restore Purchases',
              style: const TextStyle(
                color: AppColors.glowGreen,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: PremiumFeaturesWidget(
          onPurchaseSuccess: () {
            Navigator.of(context).pop();
            onPremiumAccess?.call();
          },
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Future<void> _restorePurchases(
    BuildContext context,
    PurchaseProvider provider,
  ) async {
    try {
      final success = await provider.restorePurchases();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? (context.read<LocalizationProvider>().isTr
                        ? 'Satın alımlar geri yüklendi!'
                        : 'Purchases restored!')
                  : (context.read<LocalizationProvider>().isTr
                        ? 'Geri yüklenecek satın alım bulunamadı'
                        : 'No purchases to restore'),
            ),
            backgroundColor: success
                ? AppColors.glowGreen
                : AppColors.powderRed,
          ),
        );

        if (success) {
          onPremiumAccess?.call();
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<LocalizationProvider>().isTr
                  ? 'Geri yükleme başarısız: $e'
                  : 'Restore failed: $e',
            ),
            backgroundColor: AppColors.powderRed,
          ),
        );
      }
    }
  }
}
