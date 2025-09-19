import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/feature/provider/purchase_provider.dart';

/// iOS optimized purchase widget for Remove Ads
class IOSPurchaseWidget extends StatelessWidget {
  final VoidCallback? onPurchaseSuccess;
  final VoidCallback? onCancel;

  const IOSPurchaseWidget({super.key, this.onPurchaseSuccess, this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Consumer<PurchaseProvider>(
      builder: (context, purchaseProvider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.ads_click, color: Colors.orange, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Remove Ads',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Enjoy ad-free experience',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Features
              _buildFeatureItem(
                context,
                Icons.speed,
                'Faster Loading',
                'No interruptions while using the app',
              ),
              _buildFeatureItem(
                context,
                Icons.center_focus_strong,
                'Better Focus',
                'Concentrate on learning without distractions',
              ),
              _buildFeatureItem(
                context,
                Icons.battery_charging_full,
                'Battery Saving',
                'Less battery consumption without ads',
              ),

              const SizedBox(height: 24),

              // Purchase Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: purchaseProvider.isLoading
                      ? null
                      : () => _handlePurchase(context, purchaseProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: purchaseProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Remove Ads - \$2.99',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Restore Button
              TextButton(
                onPressed: purchaseProvider.isLoading
                    ? null
                    : () => _handleRestore(context, purchaseProvider),
                child: const Text('Restore Purchases'),
              ),

              // Error Message
              if (purchaseProvider.error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          purchaseProvider.error!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase(
    BuildContext context,
    PurchaseProvider purchaseProvider,
  ) async {
    try {
      final success = await purchaseProvider.purchaseRemoveAds();

      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Ads removed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          onPurchaseSuccess?.call();
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Purchase failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleRestore(
    BuildContext context,
    PurchaseProvider purchaseProvider,
  ) async {
    try {
      final success = await purchaseProvider.restorePurchases();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? '✅ Purchases restored successfully!'
                  : 'ℹ️ No purchases to restore.',
            ),
            backgroundColor: success ? Colors.green : Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

/// Show iOS purchase dialog
void showIOSPurchaseDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Background overlay
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),
          // Dialog content
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IOSPurchaseWidget(
                    onPurchaseSuccess: () => Navigator.of(context).pop(),
                    onCancel: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 16),
                  // Close button
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Maybe Later',
                      style: TextStyle(color: Colors.grey),
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
