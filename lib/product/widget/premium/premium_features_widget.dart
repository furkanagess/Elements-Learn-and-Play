import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/feature/provider/purchase_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Widget for displaying premium features and purchase options
class PremiumFeaturesWidget extends StatelessWidget {
  final VoidCallback? onPurchaseSuccess;
  final VoidCallback? onClose;

  const PremiumFeaturesWidget({
    super.key,
    this.onPurchaseSuccess,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;

    return Consumer<PurchaseProvider>(
      builder: (context, purchaseProvider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.glowGreen.withValues(alpha: 0.95),
                AppColors.steelBlue.withValues(alpha: 0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.glowGreen.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.star,
                      color: AppColors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isTr ? 'Premium Özellikler' : 'Premium Features',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isTr
                              ? 'Tüm özelliklerin kilidini aç'
                              : 'Unlock all features',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onClose != null)
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close, color: AppColors.white),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Features list
              _buildFeatureList(isTr),
              const SizedBox(height: 24),

              // Purchase options
              if (purchaseProvider.offerings?.current != null)
                _buildPurchaseOptions(context, purchaseProvider, isTr)
              else
                _buildLoadingState(),

              const SizedBox(height: 16),

              // Restore purchases button
              TextButton(
                onPressed: purchaseProvider.isLoading
                    ? null
                    : () => _restorePurchases(context, purchaseProvider),
                child: Text(
                  isTr ? 'Satın alımları geri yükle' : 'Restore Purchases',
                  style: const TextStyle(
                    color: AppColors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureList(bool isTr) {
    final features = [
      (isTr ? 'Reklamsız deneyim' : 'Ad-free experience', Icons.block),
      (isTr ? 'Sınırsız quiz' : 'Unlimited quizzes', Icons.quiz),
      (isTr ? 'Premium bulmacalar' : 'Premium puzzles', Icons.extension),
      (
        isTr ? 'Gelişmiş istatistikler' : 'Advanced statistics',
        Icons.analytics,
      ),
      (isTr ? 'Özel temalar' : 'Exclusive themes', Icons.palette),
    ];

    return Column(
      children: features
          .map((feature) => _buildFeatureItem(feature.$1, feature.$2))
          .toList(),
    );
  }

  Widget _buildFeatureItem(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseOptions(
    BuildContext context,
    PurchaseProvider provider,
    bool isTr,
  ) {
    final currentOffering = provider.offerings!.current!;

    return Column(
      children: [
        // Monthly subscription
        if (currentOffering.monthly != null)
          _buildPackageOption(
            context,
            currentOffering.monthly!,
            isTr ? 'Aylık' : 'Monthly',
            isTr ? 'En popüler' : 'Most Popular',
            provider,
          ),
        const SizedBox(height: 12),

        // Annual subscription
        if (currentOffering.annual != null)
          _buildPackageOption(
            context,
            currentOffering.annual!,
            isTr ? 'Yıllık' : 'Annual',
            isTr ? 'En iyi değer' : 'Best Value',
            provider,
          ),
        const SizedBox(height: 12),

        // Lifetime purchase
        if (currentOffering.lifetime != null)
          _buildPackageOption(
            context,
            currentOffering.lifetime!,
            isTr ? 'Yaşam boyu' : 'Lifetime',
            isTr ? 'Tek seferlik' : 'One-time',
            provider,
          ),
      ],
    );
  }

  Widget _buildPackageOption(
    BuildContext context,
    Package package,
    String title,
    String subtitle,
    PurchaseProvider provider,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  package.storeProduct.priceString,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: provider.isLoading
                ? null
                : () => _purchasePackage(context, package, provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: provider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                    ),
                  )
                : const Text(
                    'Satın Al',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
      ),
    );
  }

  Future<void> _purchasePackage(
    BuildContext context,
    Package package,
    PurchaseProvider provider,
  ) async {
    try {
      final success = await provider.purchasePackage(package);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<LocalizationProvider>().isTr
                  ? 'Satın alma başarılı!'
                  : 'Purchase successful!',
            ),
            backgroundColor: AppColors.glowGreen,
          ),
        );
        onPurchaseSuccess?.call();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<LocalizationProvider>().isTr
                  ? 'Satın alma başarısız: $e'
                  : 'Purchase failed: $e',
            ),
            backgroundColor: AppColors.powderRed,
          ),
        );
      }
    }
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
          onPurchaseSuccess?.call();
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
