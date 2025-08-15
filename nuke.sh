#!/bin/bash
set -e

echo "🚀 Nuking Flutter & iOS caches..."

rm -rf ~/.pub-cache
flutter clean
flutter pub get

cd ios
rm -rf Pods Podfile.lock
pod repo update
pod install
cd ..

flutter run

echo "✅ Done!"
