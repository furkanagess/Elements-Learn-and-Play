import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/provider/purchase_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/widget/appBar/app_bars.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final PatternService patternService = PatternService();

  @override
  void initState() {
    super.initState();
    // Initialize purchases once when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final purchaseProvider = context.read<PurchaseProvider>();
      if (purchaseProvider.products.isEmpty && !purchaseProvider.isLoading) {
        purchaseProvider.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTr = context.select<LocalizationProvider, bool>((p) => p.isTr);

    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBarConfigs.custom(
          theme: AppBarVariant.settings,
          style: AppBarStyle.gradient,
          title: isTr ? 'Ayarlar' : 'Settings',
        ).toAppBar(),
        body: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: patternService.getPatternPainter(
                    type: PatternType.atomic,
                    color: Colors.white,
                    opacity: 0.03,
                  ),
                ),
              ),
            ),
            // Main Content
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Language Settings Card
                          _buildLanguageCard(context, isTr),
                          const SizedBox(height: 20),

                          // // Rate App Card
                          // _buildRateAppCard(context, isTr),
                          // const SizedBox(height: 20),

                          // Premium / Non-premium area listens only to isPremium
                          Builder(
                            builder: (context) {
                              final bool isPremium = context
                                  .select<PurchaseProvider, bool>(
                                    (p) => p.isPremium,
                                  );
                              if (!isPremium) {
                                // Scope provider rebuilds only to this card
                                return Consumer<PurchaseProvider>(
                                  builder: (context, provider, _) => Column(
                                    children: [
                                      _buildEnhancedRemoveAdsCard(
                                        context,
                                        provider,
                                        isTr,
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                );
                              } else {
                                return Column(
                                  children: [
                                    _buildPremiumExperienceCard(context, isTr),
                                    const SizedBox(height: 20),
                                  ],
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context, bool isTr) {
    return _buildCardContainer(
      gradientColors: [
        AppColors.steelBlue.withValues(alpha: 0.9),
        AppColors.darkBlue.withValues(alpha: 0.8),
        AppColors.purple.withValues(alpha: 0.7),
      ],
      onTap: () {
        context.read<LocalizationProvider>().toggleBool();
      },
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: const Icon(Icons.language, color: AppColors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  isTr ? '🌍 Dil Değiştir' : '🌍 Change Language',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isTr ? 'Uygulama dilini değiştir' : 'Change app language',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.7),
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateAppCard(BuildContext context, bool isTr) {
    return _buildCardContainer(
      gradientColors: [
        AppColors.yellow.withValues(alpha: 0.9),
        AppColors.skinColor.withValues(alpha: 0.8),
        AppColors.powderRed.withValues(alpha: 0.7),
      ],
      onTap: () => _rateApp(context, isTr),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: const Icon(Icons.star, color: AppColors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTr ? '⭐ Uygulamayı Değerlendir' : '⭐ Rate App',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isTr
                      ? 'Uygulamamızı beğendiyseniz değerlendirin'
                      : 'Rate our app if you like it',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.7),
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Build premium experience card for premium users
  Widget _buildPremiumExperienceCard(BuildContext context, bool isTr) {
    return _buildCardContainer(
      gradientColors: [
        AppColors.glowGreen.withValues(alpha: 0.9),
        AppColors.steelBlue.withValues(alpha: 0.8),
        AppColors.purple.withValues(alpha: 0.7),
      ],
      padding: const EdgeInsets.all(24),
      radius: 20,
      borderColor: AppColors.glowGreen.withValues(alpha: 0.3),
      shadows: [
        BoxShadow(
          color: AppColors.glowGreen.withValues(alpha: 0.25),
          blurRadius: 20,
          spreadRadius: 2,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: AppColors.darkBlue.withValues(alpha: 0.3),
          blurRadius: 12,
          spreadRadius: -2,
          offset: const Offset(0, 4),
        ),
      ],
      child: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: PatternService().getPatternPainter(
                type: PatternType.atomic,
                color: Colors.white,
                opacity: 0.05,
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and title
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: AppColors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isTr ? '✨ Reklamsız Deneyim' : '✨ Ad-Free Experience',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isTr
                              ? 'Premium üyelik aktif - Tüm özelliklerden yararlanıyorsunuz'
                              : 'Premium membership active - Enjoying all features',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Premium benefits
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isTr ? 'Premium Avantajlar:' : 'Premium Benefits:',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildPremiumBenefit(
                      Icons.block,
                      isTr ? 'Reklamsız deneyim' : 'Ad-free experience',
                    ),
                    const SizedBox(height: 8),
                    _buildPremiumBenefit(
                      Icons.favorite,
                      isTr ? 'Oyunlarda daha fazla can' : 'More game lives',
                    ),
                    const SizedBox(height: 8),
                    _buildPremiumBenefit(
                      Icons.games,
                      isTr
                          ? 'Tüm oyunlarda avantaj'
                          : 'Advantages in all games',
                    ),
                    const SizedBox(height: 8),
                    _buildPremiumBenefit(
                      Icons.emoji_events,
                      isTr
                          ? 'Tüm başarımlar ve istatistiklere erişim'
                          : 'Access to all achievements and stats',
                    ),
                    const SizedBox(height: 8),
                    _buildPremiumBenefit(
                      Icons.favorite_border,
                      isTr ? 'Sınırsız favori' : 'Unlimited favorites',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build premium benefit item
  Widget _buildPremiumBenefit(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.glowGreen, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedRemoveAdsCard(
    BuildContext context,
    PurchaseProvider provider,
    bool isTr,
  ) {
    return _buildCardContainer(
      gradientColors: [
        AppColors.powderRed.withValues(alpha: 0.9),
        AppColors.pink.withValues(alpha: 0.8),
        AppColors.purple.withValues(alpha: 0.7),
      ],
      padding: const EdgeInsets.all(24),
      radius: 24,
      borderColor: Colors.white.withValues(alpha: 0.2),
      shadows: [
        BoxShadow(
          color: AppColors.powderRed.withValues(alpha: 0.3),
          blurRadius: 20,
          spreadRadius: 2,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: AppColors.darkBlue.withValues(alpha: 0.2),
          blurRadius: 12,
          spreadRadius: -2,
          offset: const Offset(0, 4),
        ),
      ],
      child: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: PatternService().getPatternPainter(
                type: PatternType.circuit,
                color: Colors.white,
                opacity: 0.05,
              ),
            ),
          ),
          // Content
          Column(
            children: [
              // Header with icon and title
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.ads_click,
                      color: AppColors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isTr ? '🚫 Reklamları Kaldır' : '🚫 Remove Ads',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isTr
                              ? 'Reklamsız deneyim için tek seferlik ödeme'
                              : 'One-time payment for ad-free experience',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Features list
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _buildFeatureRow(
                      Icons.visibility_off,
                      isTr ? 'Reklamsız Deneyim' : 'Ad-Free Experience',
                      isTr
                          ? 'Hiç reklam görmeden kullan'
                          : 'Use without any ads',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureRow(
                      Icons.favorite,
                      isTr ? 'Oyunlarda Fazladan Can' : 'More Game Lives',
                      isTr ? 'Daha fazla can ile oyna' : 'Play with more lives',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureRow(
                      Icons.emoji_events,
                      isTr
                          ? 'Tüm Başarımlar ve İstatistikler'
                          : 'All Achievements and Stats',
                      isTr
                          ? 'Tüm başarımlar ve istatistiklere erişim'
                          : 'Access to all achievements and stats',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureRow(
                      Icons.favorite_border,
                      isTr ? 'Sınırsız Favori' : 'Unlimited Favorites',
                      isTr
                          ? 'İstediğin kadar içeriği favorileyebilirsin'
                          : 'Favorite unlimited items',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Price and purchase button
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.formattedPrice,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isTr ? 'Tek seferlik ödeme' : 'One-time payment',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                        if (provider.removeAdsProduct != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${provider.currencyCode} • ${provider.priceAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.9),
                          Colors.white.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await provider
                            .directPurchaseRemoveAdsWithDetails();
                        _showPurchaseResultBottomSheet(
                          context,
                          result['success'] as bool,
                          isTr,
                          errorDetails: result,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        isTr ? 'Şimdi Kaldır' : 'Remove Now',
                        style: TextStyle(
                          color: AppColors.powderRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Restore Purchase Text
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final result = await provider.restorePurchasesWithDetails();
                    _showPurchaseResultBottomSheet(
                      context,
                      result['success'] as bool,
                      isTr,
                      errorDetails: result,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.restore,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isTr
                              ? 'Satın Alımları Geri Yükle'
                              : 'Restore Purchases',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Unified settings card container
  Widget _buildCardContainer({
    required List<Color> gradientColors,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    double radius = 16,
    double borderWidth = 1.5,
    Color? borderColor,
    List<BoxShadow>? shadows,
    GestureTapCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.15),
          width: borderWidth,
        ),
        boxShadow:
            shadows ??
            [
              BoxShadow(
                color: gradientColors.first.withValues(alpha: 0.25),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: AppColors.darkBlue.withValues(alpha: 0.2),
                blurRadius: 6,
                spreadRadius: -1,
                offset: const Offset(0, 2),
              ),
            ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: child,
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Show purchase result bottom sheet
  void _showPurchaseResultBottomSheet(
    BuildContext context,
    bool isSuccess,
    bool isTr, {
    Map<String, dynamic>? errorDetails,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSuccess
                ? [
                    AppColors.glowGreen.withValues(alpha: 0.9),
                    AppColors.steelBlue.withValues(alpha: 0.8),
                    AppColors.purple.withValues(alpha: 0.7),
                  ]
                : [
                    AppColors.powderRed.withValues(alpha: 0.9),
                    AppColors.pink.withValues(alpha: 0.8),
                    AppColors.purple.withValues(alpha: 0.7),
                  ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSuccess
                ? AppColors.glowGreen.withValues(alpha: 0.3)
                : AppColors.powderRed.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (isSuccess ? AppColors.glowGreen : AppColors.powderRed)
                  .withValues(alpha: 0.25),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.darkBlue.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: -2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: CustomPaint(
                painter: PatternService().getPatternPainter(
                  type: PatternType.atomic,
                  color: Colors.white,
                  opacity: 0.05,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isSuccess ? Icons.check_circle : Icons.error,
                      color: AppColors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    isSuccess
                        ? (isTr ? '🎉 Başarılı!' : '🎉 Success!')
                        : (isTr ? ' Başarısız' : 'Failed'),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Message
                  Column(
                    children: [
                      // Success message with congratulations
                      if (isSuccess) ...[
                        Text(
                          errorDetails != null &&
                                  errorDetails['congratulations'] != null
                              ? errorDetails['congratulations'] as String
                              : (isTr
                                    ? 'Reklamlar başarıyla kaldırıldı!'
                                    : 'Ads removed successfully!'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 18,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Benefits section
                        if (errorDetails != null &&
                            errorDetails['benefits'] != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isTr
                                          ? 'Artık Bu Özelliklerden Yararlanabilirsiniz:'
                                          : 'You Can Now Enjoy These Features:',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...(errorDetails['benefits'] as List<String>)
                                    .map(
                                      (benefit) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: AppColors.glowGreen,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                benefit,
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.85),
                                                  fontSize: 14,
                                                  height: 1.3,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ],
                            ),
                          ),
                        ],
                      ] else ...[
                        // Error message
                        Text(
                          errorDetails != null &&
                                  errorDetails['message'] != null
                              ? errorDetails['message'] as String
                              : (isTr
                                    ? 'Satın alma işlemi başarısız oldu.\nLütfen tekrar deneyin.'
                                    : 'Purchase failed.\nPlease try again.'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                      ],

                      // Error details for failed purchases
                      if (!isSuccess &&
                          errorDetails != null &&
                          errorDetails['errorType'] != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Error icon and title
                              Row(
                                children: [
                                  Text(
                                    errorDetails['icon'] ?? '⚠️',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      isTr
                                          ? 'Ne Yapabilirsiniz?'
                                          : 'What Can You Do?',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Solution message
                              if (errorDetails['solution'] != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.lightbulb_outline,
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          errorDetails['solution'] as String,
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.85,
                                            ),
                                            fontSize: 14,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // Error reason
                              if (errorDetails['reason'] != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isTr
                                                  ? 'Neden Oluştu?'
                                                  : 'Why Did This Happen?',
                                              style: TextStyle(
                                                color: Colors.white.withValues(
                                                  alpha: 0.8,
                                                ),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              errorDetails['reason'] as String,
                                              style: TextStyle(
                                                color: Colors.white.withValues(
                                                  alpha: 0.75,
                                                ),
                                                fontSize: 13,
                                                height: 1.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  if (isSuccess) ...[
                    // Success - Only Close Button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.2),
                            Colors.white.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          isTr ? 'Tebrikler!' : 'Congratulations!',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Failure - Only Close Button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.2),
                            Colors.white.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          isTr ? 'Tamam' : 'OK',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Rate app functionality
  Future<void> _rateApp(BuildContext context, bool isTr) async {
    try {
      // App Store URL for the app
      const String appStoreUrl =
          'https://apps.apple.com/app/com-furkanages-elements/id1234567890';

      // Try to launch the URL
      final Uri url = Uri.parse(appStoreUrl);

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isTr
                    ? 'Teşekkürler! App Store\'a yönlendiriliyorsunuz...'
                    : 'Thank you! Redirecting to App Store...',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Fallback: Show dialog if URL can't be launched
        if (context.mounted) {
          _showRateAppDialog(context, isTr);
        }
      }
    } catch (e) {
      // Error handling: Show dialog if something goes wrong
      if (context.mounted) {
        _showRateAppDialog(context, isTr);
      }
    }
  }

  /// Show rate app dialog as fallback
  void _showRateAppDialog(BuildContext context, bool isTr) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBlue,
        title: Text(
          isTr ? 'Uygulamayı Değerlendir' : 'Rate App',
          style: const TextStyle(color: AppColors.white),
        ),
        content: Text(
          isTr
              ? 'Uygulamamızı beğendiyseniz App Store\'da değerlendirmeyi unutmayın!\n\nApp ID: com.furkanages.elements'
              : 'If you like our app, don\'t forget to rate it on the App Store!\n\nApp ID: com.furkanages.elements',
          style: const TextStyle(color: AppColors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              isTr ? 'İptal' : 'Cancel',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: Text(
              isTr ? 'Tamam' : 'OK',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
