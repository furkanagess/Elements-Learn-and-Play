#!/bin/bash

# Android App Bundle Build Script (No Tree Shaking)
# This script builds an App Bundle without tree shaking using Flutter command

echo "🚀 Starting Android App Bundle Build (No Tree Shaking)..."

# Navigate to project root directory
cd "$(dirname "$0")/../.."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Build release App Bundle without tree shaking
echo "📦 Building release App Bundle (no tree shaking)..."
flutter build appbundle --release --no-tree-shake-icons

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ App Bundle build completed successfully!"
    echo "📱 App Bundle location: build/app/outputs/bundle/release/"
    echo "🔍 App Bundle files:"
    ls -la build/app/outputs/bundle/release/
    echo ""
    echo "📊 App Bundle size:"
    du -h build/app/outputs/bundle/release/*.aab
    echo ""
    echo "🎉 App Bundle is ready for Google Play Store upload!"
else
    echo "❌ App Bundle build failed!"
    exit 1
fi

echo "🎉 Build process completed!"
