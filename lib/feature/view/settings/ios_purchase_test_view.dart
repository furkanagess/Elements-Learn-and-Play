import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/feature/provider/purchase_provider.dart';
import 'package:elements_app/product/widget/premium/ios_purchase_widget.dart';

/// Test view for iOS purchase functionality
class IOSPurchaseTestView extends StatelessWidget {
  const IOSPurchaseTestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('iOS Purchase Test'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Consumer<PurchaseProvider>(
        builder: (context, purchaseProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Purchase Status',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              purchaseProvider.isPremium
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: purchaseProvider.isPremium
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              purchaseProvider.isPremium
                                  ? 'Premium Active'
                                  : 'Free Version',
                              style: TextStyle(
                                color: purchaseProvider.isPremium
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (purchaseProvider.isLoading) ...[
                          const SizedBox(height: 8),
                          const LinearProgressIndicator(),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Products Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Products',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        if (purchaseProvider.products.isEmpty)
                          const Text('No products available')
                        else
                          ...purchaseProvider.products.map(
                            (product) => ListTile(
                              leading: const Icon(Icons.shopping_cart),
                              title: Text(product.title),
                              subtitle: Text(product.description),
                              trailing: Text(
                                product.priceString,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Offerings Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Offerings',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        if (purchaseProvider.offerings?.current == null)
                          const Text('No current offering configured')
                        else
                          Text(
                            'Current offering: ${purchaseProvider.offerings!.current!.identifier}',
                          ),
                        const SizedBox(height: 8),
                        // Show remove_elements_ads offering specifically
                        if (purchaseProvider
                                .offerings
                                ?.all['remove_elements_ads'] !=
                            null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'remove_elements_ads Offering Found',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Packages: ${purchaseProvider.offerings!.all['remove_elements_ads']!.availablePackages.length}',
                                  style: TextStyle(color: Colors.green[700]),
                                ),
                                ...purchaseProvider
                                    .offerings!
                                    .all['remove_elements_ads']!
                                    .availablePackages
                                    .map(
                                      (package) => Text(
                                        '• ${package.identifier}: ${package.storeProduct.title}',
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'remove_elements_ads offering not found',
                                    style: TextStyle(color: Colors.orange[700]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: purchaseProvider.isLoading
                            ? null
                            : () => _showPurchaseDialog(context),
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('Show Purchase Dialog'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: purchaseProvider.isLoading
                            ? null
                            : () =>
                                  _restorePurchases(context, purchaseProvider),
                        icon: const Icon(Icons.restore),
                        label: const Text('Restore Purchases'),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: purchaseProvider.isLoading
                            ? null
                            : () => _refreshStatus(context, purchaseProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Status'),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Error Display
                if (purchaseProvider.error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Error',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          purchaseProvider.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context) {
    showIOSPurchaseDialog(context);
  }

  Future<void> _restorePurchases(
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

  Future<void> _refreshStatus(
    BuildContext context,
    PurchaseProvider purchaseProvider,
  ) async {
    try {
      await purchaseProvider.checkPremiumStatus();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Status refreshed'),
            backgroundColor: Colors.green,
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
