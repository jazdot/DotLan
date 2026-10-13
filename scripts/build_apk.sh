#!/usr/bin/env bash
set -e

echo "=== Jazdot DotLan APK Build Engine ==="

# Check Android SDK
if [ -z "$ANDROID_HOME" ]; then
    export ANDROID_HOME="/home/richu/development/android"
    echo "• Setting ANDROID_HOME=$ANDROID_HOME"
fi

# Check Java
if ! command -v java &> /dev/null; then
    echo "❌ Error: Java (JDK 17+) is required to compile the Android APK."
    exit 1
fi
echo "• Java detected: $(java -version 2>&1 | head -n 1)"

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter SDK is required to compile DotLan."
    exit 1
fi
echo "• Flutter detected: $(flutter --version | head -n 1)"

# Build APK
echo "• Resolving dependencies..."
flutter pub get

echo "• Compiling Release APK..."
flutter build apk --release

echo "✅ Success! APK generated at:"
echo "    build/app/outputs/flutter-apk/app-release.apk"
