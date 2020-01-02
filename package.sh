#!/usr/bin/env bash
set -eux

xcodebuild -alltargets -configuration Release

mkdir -p build/Package

mkdir -p build/Root/MathSymbolsInput
cp -r "build/Release/Math Symbols Input.app" build/Root/MathSymbolsInput
 pkgbuild \
   --root build/Root/MathSymbolsInput \
   --component-plist MathSymbolsInput-components.plist \
   --install-location "/Library/Input Methods" \
   build/Package/MathSymbolsInput.pkg

mkdir -p build/root/MathSymbolsInputPreferences
cp -r "build/Release/Math Symbols Input - Preferences.app" build/root/MathSymbolsInputPreferences
 pkgbuild \
   --root build/root/MathSymbolsInputPreferences \
   --component-plist MathSymbolsInputPreferences-components.plist \
   --install-location "/Applications" \
   build/Package/MathSymbolsInputPreferences.pkg

mkdir -p build/Plugins
cp -r "build/Release/InstallerActivatePane.bundle" build/Plugins
cp InstallerSections.plist build/Plugins

 productbuild \
   --distribution distribution.xml \
   --package-path build/Package \
   --plugins build/Plugins \
   MathSymbolsInput.pkg
