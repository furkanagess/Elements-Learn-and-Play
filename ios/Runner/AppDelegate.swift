import Flutter
import UIKit
import UserNotifications
import GoogleMobileAds

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Initialize Google Mobile Ads SDK
    GADMobileAds.sharedInstance().start(completionHandler: nil)
    
    // Ensure iOS foreground notification presentation via delegate
    UNUserNotificationCenter.current().delegate = self
    // Register for APNs to receive device token on real devices
    UIApplication.shared.registerForRemoteNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
