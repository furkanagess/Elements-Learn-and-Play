import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/feature/provider/admob_provider.dart';

/// Custom navigator observer that tracks route changes for AdMob interstitial ads
class AdRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _handleRouteChange(
      route.navigator?.context,
      routeName: route.settings.name,
      isPageRoute: route is PageRoute,
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // Count only when popping a PageRoute (not dialogs/sheets)
    _handleRouteChange(
      route.navigator?.context,
      routeName: previousRoute?.settings.name,
      isPageRoute: route is PageRoute,
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _handleRouteChange(
        newRoute.navigator?.context,
        routeName: newRoute.settings.name,
        isPageRoute: newRoute is PageRoute,
      );
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    // Count only when removing a PageRoute itself
    _handleRouteChange(
      route.navigator?.context,
      routeName: previousRoute?.settings.name,
      isPageRoute: route is PageRoute,
    );
  }

  void _handleRouteChange(BuildContext? context,
      {String? routeName, bool isPageRoute = true}) {
    if (context != null) {
      try {
        context
            .read<AdmobProvider>()
            .onRouteChanged(routeName: routeName, isPageRoute: isPageRoute);
      } catch (e) {
        debugPrint('Error tracking route change: \$e');
      }
    }
  }
}
