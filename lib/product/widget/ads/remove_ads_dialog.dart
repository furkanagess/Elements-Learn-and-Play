import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/feature/provider/purchase_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';

/// Dialog that appears after interstitial ads to encourage users to remove ads
class RemoveAdsDialog extends StatefulWidget {
  final VoidCallback? onClose;

  const RemoveAdsDialog({super.key, this.onClose});

  @override
  State<RemoveAdsDialog> createState() => _RemoveAdsDialogState();
}

class _RemoveAdsDialogState extends State<RemoveAdsDialog> {
  bool _isPurchasing = false;

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 350),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.powderRed.withValues(alpha: 0.95),
              AppColors.pink.withValues(alpha: 0.9),
              AppColors.purple.withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.powderRed.withValues(alpha: 0.4),
              blurRadius: 25,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: AppColors.darkBlue.withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: -2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: CustomPaint(
                painter: PatternService().getPatternPainter(
                  type: PatternType.circuit,
                  color: Colors.white,
                  opacity: 0.03,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
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
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.ads_click,
                      color: AppColors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    isTr ? '🚫 Reklamları Kaldır' : '🚫 Remove Ads',
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
                    isTr
                        ? 'Reklamsız deneyim için tek seferlik ödeme yapın ve kesintisiz uygulama deneyimi yaşayın!'
                        : 'Make a one-time payment for an ad-free experience and enjoy uninterrupted app experience!',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Benefits
                  _buildBenefitsList(isTr),
                  const SizedBox(height: 24),

                  // Purchase Button
                  Consumer<PurchaseProvider>(
                    builder: (context, purchaseProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isPurchasing
                              ? null
                              : () => _handlePurchase(
                                  context,
                                  purchaseProvider,
                                  isTr,
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.9,
                            ),
                            foregroundColor: AppColors.powderRed,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: Colors.white.withValues(alpha: 0.3),
                          ),
                          child: _isPurchasing
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.powderRed,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      isTr
                                          ? 'Satın Alınıyor...'
                                          : 'Purchasing...',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Text(
                                      isTr
                                          ? 'Tek Seferlik Satın Al'
                                          : 'One-Time Purchase',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (purchaseProvider.removeAdsProduct !=
                                        null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '${purchaseProvider.currencyCode} ${purchaseProvider.priceAmount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.powderRed.withValues(
                                            alpha: 0.8,
                                          ),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onClose?.call();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white.withValues(alpha: 0.8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        isTr ? 'Şimdi Değil' : 'Not Now',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  Widget _buildBenefitsList(bool isTr) {
    final benefits = isTr
        ? [
            'Reklamsız deneyim',
            'Kesintisiz kullanım',
            'Tek seferlik ödeme',
            'Tüm özelliklere erişim',
          ]
        : [
            'Ad-free experience',
            'Uninterrupted usage',
            'One-time payment',
            'Access to all features',
          ];

    return Column(
      children: benefits
          .map(
            (benefit) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.white,
                      size: 12,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      benefit,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Future<void> _handlePurchase(
    BuildContext context,
    PurchaseProvider purchaseProvider,
    bool isTr,
  ) async {
    setState(() {
      _isPurchasing = true;
    });

    try {
      final result = await purchaseProvider
          .directPurchaseRemoveAdsWithDetails();

      if (context.mounted) {
        setState(() {
          _isPurchasing = false;
        });

        if (result['success'] == true) {
          // Purchase successful
          Navigator.of(context).pop();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isTr
                    ? '🎉 Reklamlar başarıyla kaldırıldı!'
                    : '🎉 Ads successfully removed!',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          // Purchase failed
          _showPurchaseErrorDialog(context, result, isTr);
        }
      }
    } catch (e) {
      if (context.mounted) {
        setState(() {
          _isPurchasing = false;
        });
        _showPurchaseErrorDialog(context, {'error': e.toString()}, isTr);
      }
    }
  }

  void _showPurchaseErrorDialog(
    BuildContext context,
    Map<String, dynamic> result,
    bool isTr,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBlue,
        title: Text(
          isTr ? 'Satın Alma Hatası' : 'Purchase Error',
          style: const TextStyle(color: AppColors.white),
        ),
        content: Text(
          result['error'] ??
              (isTr
                  ? 'Satın alma sırasında bir hata oluştu.'
                  : 'An error occurred during purchase.'),
          style: const TextStyle(color: AppColors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              isTr ? 'Tamam' : 'OK',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
