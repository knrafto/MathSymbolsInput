#!/usr/bin/env bash

# Creates an installer package for distribution. Before running, create an
# "app-specific password" for notarytool and store it in the keychain:
#
# xcrun notarytool store-credentials "AC_PASSWORD" --apple-id <email> --team-id <team-id> --password <password>

if [[ $# -ne 1 ]] ; then
  echo 'usage: ./package.sh IDENTITY'
  echo 'e.g. ./package.sh "John Doe (12345ABCDE)"'
  exit 1
fi
IDENTITY=$1
CODESIGN_FLAGS="-v --force --timestamp --options=runtime"

set -eux

xcodebuild -alltargets -configuration Release

mkdir -p build/Package

# Order matters! The .app bundle must be signed last.
codesign $CODESIGN_FLAGS --sign "Developer ID Application: $IDENTITY" "build/Release/Math Symbols Input.app/Contents/MacOS/Math Symbols Input"
find "build/Release/Math Symbols Input.app" -name "*.dylib" -exec codesign $CODESIGN_FLAGS --sign "Developer ID Application: $IDENTITY" {} \;
codesign $CODESIGN_FLAGS --sign "Developer ID Application: $IDENTITY" "build/Release/Math Symbols Input.app"
mkdir -p build/Root/MathSymbolsInput
cp -R "build/Release/Math Symbols Input.app" build/Root/MathSymbolsInput
pkgbuild \
  --root build/Root/MathSymbolsInput \
  --component-plist MathSymbolsInput-components.plist \
  --install-location "/Library/Input Methods" \
  build/Package/MathSymbolsInput.pkg

codesign $CODESIGN_FLAGS --sign "Developer ID Application: $IDENTITY" "build/Release/Math Symbols Input - Preferences.app/Contents/MacOS/Math Symbols Input - Preferences"
find "build/Release/Math Symbols Input - Preferences.app" -name "*.dylib" -exec codesign $CODESIGN_FLAGS --sign "Developer ID Application: $IDENTITY" {} \;
codesign $CODESIGN_FLAGS --sign "Developer ID Application: $IDENTITY" "build/Release/Math Symbols Input - Preferences.app"
mkdir -p build/root/MathSymbolsInputPreferences
cp -R "build/Release/Math Symbols Input - Preferences.app" build/root/MathSymbolsInputPreferences
pkgbuild \
  --root build/root/MathSymbolsInputPreferences \
  --component-plist MathSymbolsInputPreferences-components.plist \
  --install-location /Applications \
  build/Package/MathSymbolsInputPreferences.pkg

productbuild \
  --distribution distribution.xml \
  --package-path build/Package \
  --sign "Developer ID Installer: $IDENTITY" \
  MathSymbolsInput.pkg

xcrun notarytool submit MathSymbolsInput.pkg --keychain-profile "AC_PASSWORD" --wait
xcrun stapler staple MathSymbolsInput.pkg
