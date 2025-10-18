#!/bin/bash

echo "🔧 Fixing ElementOfDayWidgetExtension build issue..."

# Navigate to project directory
cd "$(dirname "$0")"

echo "📱 Cleaning Flutter project..."
flutter clean

echo "📦 Getting Flutter dependencies..."
flutter pub get

echo "🗂️ Cleaning iOS build directory..."
rm -rf ios/build
rm -rf build/ios

echo "🍎 Cleaning Xcode derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData

echo "📱 Opening Xcode to manually fix widget extension..."
echo "Please follow these steps in Xcode:"
echo "1. Open ios/Runner.xcworkspace in Xcode"
echo "2. Select the ElementOfDayWidgetExtension target"
echo "3. Go to Build Settings"
echo "4. Make sure 'Code Signing Identity' is set to 'Automatic'"
echo "5. Make sure 'Development Team' is set correctly"
echo "6. Clean Build Folder (Cmd+Shift+K)"
echo "7. Build the project (Cmd+B)"

echo "🚀 Alternative: Try building with Xcode directly:"
echo "xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -destination 'platform=iOS Simulator,name=iPhone 15' build"

echo "✅ Done! Try building again."
