#!/bin/bash

# Android Release Build Script
# This script ensures proper release build configuration

echo "🚀 Starting Android Release Build..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
./gradlew clean

# Build release APK
echo "📦 Building release APK..."
./gradlew assembleRelease

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Release build completed successfully!"
    echo "📱 APK location: app/build/outputs/apk/release/"
    echo "🔍 APK files:"
    ls -la app/build/outputs/apk/release/
else
    echo "❌ Release build failed!"
    exit 1
fi

echo "🎉 Build process completed!"
