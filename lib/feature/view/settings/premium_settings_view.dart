import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/feature/provider/purchase_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/widget/premium/premium_features_widget.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/widget/appBar/app_bars.dart';

/// Settings view for premium features and subscription management
class PremiumSettingsView extends StatefulWidget {
  const PremiumSettingsView({super.key});

  @override
  State<PremiumSettingsView> createState() => _PremiumSettingsViewState();
}

class _PremiumSettingsViewState extends State<PremiumSettingsView> {
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
          title: isTr ? 'Premium Ayarları' : 'Premium Settings',
        ).toAppBar(),
        body: Consumer<PurchaseProvider>(
          builder: (context, purchaseProvider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Premium status card
                  _buildPremiumStatusCard(context, purchaseProvider, isTr),
                  const SizedBox(height: 20),

                  // Premium features
                  _buildPremiumFeaturesSection(context, purchaseProvider, isTr),
                  const SizedBox(height: 20),

                  // Subscription management
                  if (purchaseProvider.isPremium)
                    _buildSubscriptionManagement(
                      context,
                      purchaseProvider,
                      isTr,
                    ),

                  const SizedBox(height: 20),

                  // Purchase options
                  if (!purchaseProvider.isPremium)
                    _buildPurchaseOptions(context, purchaseProvider, isTr),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPremiumStatusCard(
    BuildContext context,
    PurchaseProvider provider,
    bool isTr,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (provider.isPremium ? AppColors.glowGreen : AppColors.darkBlue)
                    .withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  provider.isPremium ? Icons.star : Icons.star_border,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.isPremium
                          ? (isTr ? 'Premium Aktif' : 'Premium Active')
                          : (isTr ? 'Premium Değil' : 'Not Premium'),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      provider.isPremium
                          ? (isTr
                                ? 'Tüm özelliklerin kilidi açık'
                                : 'All features unlocked')
                          : (isTr
                                ? 'Premium\'a yükseltin'
                                : 'Upgrade to Premium'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (provider.isLoading) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPremiumFeaturesSection(
    BuildContext context,
    PurchaseProvider provider,
    bool isTr,
  ) {
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
        const SizedBox(height: 16),
        ...features
            .map(
              (feature) =>
                  _buildFeatureItem(feature.$1, feature.$2, provider.isPremium),
            )
            .toList(),
      ],
    );
  }

  Widget _buildFeatureItem(String title, IconData icon, bool isUnlocked) {
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
              color: isUnlocked
                  ? AppColors.glowGreen.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isUnlocked
                  ? AppColors.glowGreen
                  : Colors.white.withValues(alpha: 0.6),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isUnlocked
                    ? AppColors.white
                    : Colors.white.withValues(alpha: 0.6),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            isUnlocked ? Icons.check_circle : Icons.lock,
            color: isUnlocked
                ? AppColors.glowGreen
                : Colors.white.withValues(alpha: 0.4),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionManagement(
    BuildContext context,
    PurchaseProvider provider,
    bool isTr,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isTr ? 'Abonelik Yönetimi' : 'Subscription Management',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : () => _restorePurchases(context, provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.glowGreen,
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
                    : Text(
                        isTr
                            ? 'Satın alımları geri yükle'
                            : 'Restore Purchases',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                isTr
                    ? 'Aboneliğinizi App Store veya Google Play\'den yönetebilirsiniz'
                    : 'Manage your subscription from App Store or Google Play',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseOptions(
    BuildContext context,
    PurchaseProvider provider,
    bool isTr,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isTr ? 'Premium\'a Yükselt' : 'Upgrade to Premium',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
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
              isTr ? 'Premium Özellikleri Görüntüle' : 'View Premium Features',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
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
