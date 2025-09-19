import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/feature/provider/purchase_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/widget/premium/premium_features_widget.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/widget/appBar/app_bars.dart';

/// Dedicated view for removing ads through in-app purchase
class RemoveAdsView extends StatefulWidget {
  const RemoveAdsView({super.key});

  @override
  State<RemoveAdsView> createState() => _RemoveAdsViewState();
}

class _RemoveAdsViewState extends State<RemoveAdsView> {
  @override
  void initState() {
    super.initState();
    // Initialize purchase provider when view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PurchaseProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;

    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBarConfigs.custom(
          theme: AppBarVariant.settings,
          style: AppBarStyle.gradient,
          title: isTr ? 'Reklamları Kaldır' : 'Remove Ads',
        ).toAppBar(),
        body: Consumer<PurchaseProvider>(
          builder: (context, purchaseProvider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  _buildHeaderSection(context, purchaseProvider, isTr),
                  const SizedBox(height: 24),

                  // Benefits section
                  _buildBenefitsSection(isTr),
                  const SizedBox(height: 24),

                  // Purchase section
                  if (!purchaseProvider.isPremium)
                    _buildPurchaseSection(context, purchaseProvider, isTr)
                  else
                    _buildSuccessSection(context, isTr),

                  const SizedBox(height: 24),

                  // Restore purchases section
                  _buildRestoreSection(context, purchaseProvider, isTr),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    PurchaseProvider provider,
    bool isTr,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: provider.isPremium
              ? [
                  AppColors.glowGreen.withValues(alpha: 0.95),
                  AppColors.steelBlue.withValues(alpha: 0.9),
                ]
              : [
                  AppColors.darkBlue.withValues(alpha: 0.95),
                  AppColors.steelBlue.withValues(alpha: 0.9),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (provider.isPremium ? AppColors.glowGreen : AppColors.darkBlue)
                    .withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              provider.isPremium ? Icons.check_circle : Icons.block,
              color: AppColors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            provider.isPremium
                ? (isTr ? 'Reklamlar Kaldırıldı!' : 'Ads Removed!')
                : (isTr ? 'Reklamları Kaldır' : 'Remove Ads'),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            provider.isPremium
                ? (isTr
                      ? 'Artık uygulamada reklam görmeyeceksiniz. Teşekkürler!'
                      : 'You will no longer see ads in the app. Thank you!')
                : (isTr
                      ? 'Tek seferlik ödeme ile tüm reklamları kaldırın ve kesintisiz deneyim yaşayın.'
                      : 'Remove all ads with a one-time payment and enjoy an uninterrupted experience.'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection(bool isTr) {
    final benefits = [
      (isTr ? 'Reklamsız deneyim' : 'Ad-free experience', Icons.block),
      (isTr ? 'Kesintisiz oyun' : 'Uninterrupted gameplay', Icons.games),
      (isTr ? 'Daha hızlı yükleme' : 'Faster loading', Icons.speed),
      (isTr ? 'Odaklanmış öğrenme' : 'Focused learning', Icons.school),
      (isTr ? 'Tek seferlik ödeme' : 'One-time payment', Icons.payment),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isTr ? 'Faydalar' : 'Benefits',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...benefits
            .map((benefit) => _buildBenefitItem(benefit.$1, benefit.$2))
            .toList(),
      ],
    );
  }

  Widget _buildBenefitItem(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.glowGreen.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.glowGreen, size: 20),
          ),
          const SizedBox(width: 16),
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
          const Icon(Icons.check_circle, color: AppColors.glowGreen, size: 20),
        ],
      ),
    );
  }

  Widget _buildPurchaseSection(
    BuildContext context,
    PurchaseProvider provider,
    bool isTr,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isTr ? 'Reklamları Kaldır' : 'Remove Ads',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              // Price display
              Text(
                isTr ? 'Tek Seferlik Ödeme' : 'One-Time Payment',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '₺29,99', // You can make this dynamic based on your product price
                style: const TextStyle(
                  color: AppColors.glowGreen,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Purchase button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () => _showPurchaseDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.glowGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                      : Text(
                          isTr ? 'Reklamları Kaldır' : 'Remove Ads',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isTr
                    ? 'Güvenli ödeme ile tek seferlik satın alma'
                    : 'Secure one-time purchase',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessSection(BuildContext context, bool isTr) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.glowGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glowGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: AppColors.glowGreen, size: 48),
          const SizedBox(height: 16),
          Text(
            isTr
                ? 'Reklamlar Başarıyla Kaldırıldı!'
                : 'Ads Successfully Removed!',
            style: const TextStyle(
              color: AppColors.glowGreen,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isTr
                ? 'Artık uygulamada reklam görmeyeceksiniz.'
                : 'You will no longer see ads in the app.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreSection(
    BuildContext context,
    PurchaseProvider provider,
    bool isTr,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restore,
            color: Colors.white.withValues(alpha: 0.7),
            size: 24,
          ),
          const SizedBox(height: 12),
          Text(
            isTr ? 'Satın Alımları Geri Yükle' : 'Restore Purchases',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isTr
                ? 'Daha önce satın aldığınız reklam kaldırma özelliğini geri yükleyin'
                : 'Restore your previously purchased ad removal feature',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: provider.isLoading
                  ? null
                  : () => _restorePurchases(context, provider),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: provider.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      ),
                    )
                  : Text(
                      isTr ? 'Geri Yükle' : 'Restore',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: PremiumFeaturesWidget(
          onPurchaseSuccess: () {
            Navigator.of(context).pop();
            setState(() {}); // Refresh the UI
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
          setState(() {}); // Refresh the UI
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
