import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:elements_app/feature/service/google_ads_service.dart';
import 'banner_ad_widget.dart';

class AdExamplePage extends StatelessWidget {
  const AdExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AdMob Banner Example')),
      body: Column(
        children: [
          // Top banner ad
          BannerAdWidget(
            adUnitId: kDebugMode
                ? AdUnitIds.testBanner
                : GoogleAdsService.bannerAdUnitId,
            margin: const EdgeInsets.all(8.0),
          ),

          // Main content
          Expanded(
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('List Item ${index + 1}'),
                  subtitle: Text('This is item number ${index + 1}'),
                );
              },
            ),
          ),

          // Bottom banner ad
          BannerAdWidget(
            adUnitId: kDebugMode
                ? AdUnitIds.testBanner
                : GoogleAdsService.bannerAdUnitId,
            margin: const EdgeInsets.all(8.0),
          ),
        ],
      ),
    );
  }
}
