import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/widget/button/back_button.dart';
import 'package:elements_app/product/widget/ads/banner_ad_widget.dart';
import 'package:elements_app/product/widget/ads/interstitial_ad_widget.dart';
import 'package:elements_app/feature/service/google_ads_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class IOSAdMobTestView extends StatefulWidget {
  const IOSAdMobTestView({super.key});

  @override
  State<IOSAdMobTestView> createState() => _IOSAdMobTestViewState();
}

class _IOSAdMobTestViewState extends State<IOSAdMobTestView> {
  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.purple,
                AppColors.pink.withValues(alpha: 0.95),
                AppColors.turquoise.withValues(alpha: 0.9),
              ],
            ),
          ),
        ),
        leading: const ModernBackButton(),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.ads_click,
                color: AppColors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              isTr ? 'iOS AdMob Test' : 'iOS AdMob Test',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // App Information Card
            _buildInfoCard(
              title: isTr ? 'Uygulama Bilgileri' : 'Application Information',
              items: [
                _buildInfoItem(
                  label: isTr ? 'Uygulama Adı' : 'Application Name',
                  value: 'Periodic Table: Learn & Play',
                  icon: Icons.apps,
                ),
                _buildInfoItem(
                  label: isTr ? 'Uygulama Kimliği' : 'Application ID',
                  value: GoogleAdsService.applicationId,
                  icon: Icons.fingerprint,
                  isCopyable: true,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Ad Unit IDs Card
            _buildInfoCard(
              title: isTr ? 'Reklam Birim Kimlikleri' : 'Ad Unit IDs',
              items: [
                _buildInfoItem(
                  label: isTr ? 'Banner Reklam' : 'Banner Ad',
                  value: GoogleAdsService.bannerAdUnitId,
                  icon: Icons.view_stream,
                  isCopyable: true,
                ),
                _buildInfoItem(
                  label: isTr ? 'Geçiş Reklamı' : 'Interstitial Ad',
                  value: GoogleAdsService.interstitialAdUnitId,
                  icon: Icons.fullscreen,
                  isCopyable: true,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Banner Ad Test
            _buildTestCard(
              title: isTr ? 'Banner Reklam Testi' : 'Banner Ad Test',
              child: BannerAdWidget(
                adUnitId: GoogleAdsService.bannerAdUnitId,
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),

            const SizedBox(height: 20),

            // Interstitial Ad Test
            _buildTestCard(
              title: isTr ? 'Geçiş Reklamı Testi' : 'Interstitial Ad Test',
              child: Column(
                children: [
                  Text(
                    isTr
                        ? 'Geçiş reklamını test etmek için butona tıklayın'
                        : 'Click the button to test interstitial ad',
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      await InterstitialAdManager.instance.showAdOnAction();
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: Text(isTr ? 'Reklamı Göster' : 'Show Ad'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Test Status
            _buildTestCard(
              title: isTr ? 'Test Durumu' : 'Test Status',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusItem(
                    label: isTr
                        ? 'Geçiş Reklamı Yüklendi'
                        : 'Interstitial Ad Loaded',
                    isLoaded: InterstitialAdWidget.isAdLoaded,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isTr
                        ? '• Reklamların yüklenmesi birkaç saniye sürebilir\n• Test cihazında test reklamları gösterilir\n• Gerçek cihazda canlı reklamlar gösterilir'
                        : '• Ad loading may take a few seconds\n• Test ads are shown on test devices\n• Live ads are shown on real devices',
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> items}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkBlue.withValues(alpha: 0.8),
            AppColors.purple.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    required IconData icon,
    bool isCopyable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.white.withValues(alpha: 0.7), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          value,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      if (isCopyable)
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: value));
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Copied: $label'),
                                backgroundColor: AppColors.purple,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.copy,
                              color: AppColors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.turquoise.withValues(alpha: 0.8),
            AppColors.pink.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStatusItem({required String label, required bool isLoaded}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isLoaded ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: AppColors.white, fontSize: 16),
        ),
      ],
    );
  }
}
