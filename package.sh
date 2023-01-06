#!/usr/bin/env bash
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

codesign $CODESIGN_FLAGS --sign "Developer ID Application: $IDENTITY" build/Release/InstallerActivatePane.bundle/Contents/MacOS/InstallerActivatePane
codesign $CODESIGN_FLAGS --sign "Developer ID Application: $IDENTITY" build/Release/InstallerActivatePane.bundle
mkdir -p build/Plugins
cp -R build/Release/InstallerActivatePane.bundle build/Plugins
cp InstallerSections.plist build/Plugins

productbuild \
  --distribution distribution.xml \
  --package-path build/Package \
  --plugins build/Plugins \
  --sign "Developer ID Installer: $IDENTITY" \
  MathSymbolsInput.pkg
