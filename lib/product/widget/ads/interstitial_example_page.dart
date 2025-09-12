import 'package:flutter/material.dart';
import 'interstitial_ad_widget.dart';

class InterstitialExamplePage extends StatefulWidget {
  const InterstitialExamplePage({super.key});

  @override
  State<InterstitialExamplePage> createState() =>
      _InterstitialExamplePageState();
}

class _InterstitialExamplePageState extends State<InterstitialExamplePage> {
  int _actionCount = 0;

  @override
  void initState() {
    super.initState();
    // Initialize interstitial ads when the page loads
    InterstitialAdManager.instance.initialize();
  }

  @override
  void dispose() {
    InterstitialAdWidget.dispose();
    super.dispose();
  }

  void _performAction() {
    setState(() {
      _actionCount++;
    });

    // Show interstitial ad every 3 actions
    if (_actionCount % 3 == 0) {
      InterstitialAdManager.instance.showAdOnAction();
    }
  }

  void _showAdManually() {
    InterstitialAdManager.instance.showAdOnAction();
  }

  void _navigateToAnotherPage() {
    // Show ad when navigating to another major section
    InterstitialAdManager.instance.showAdOnNavigation();

    // Navigate to another page (example)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AnotherPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interstitial Ad Example'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.touch_app,
                      size: 48,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Action Count: $_actionCount',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Interstitial ads will show every 3 actions',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _performAction,
              icon: const Icon(Icons.add),
              label: const Text('Perform Action'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showAdManually,
              icon: const Icon(Icons.ads_click),
              label: const Text('Show Ad Manually'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _navigateToAnotherPage,
              icon: const Icon(Icons.navigation),
              label: const Text('Navigate (Shows Ad)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interstitial Ad Tips:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Show ads between major actions'),
                    Text('• Don\'t show ads too frequently'),
                    Text('• Test with test ad units in debug mode'),
                    Text('• Handle ad loading failures gracefully'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnotherPage extends StatelessWidget {
  const AnotherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Another Page'),
      ),
      body: const Center(
        child: Text(
          'This is another page.\nInterstitial ad was shown when navigating here.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
