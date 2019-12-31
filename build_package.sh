#!/usr/bin/env bash
# Generates MathSymbolsInput.pkg in the current directory.

set -euxo pipefail

xcodebuild -alltargets -configuration Release

pkgbuild --install-location "/Library/Input Methods" --component "build/Release/Math Symbols Input.app" build/Release/MathSymbolsInput.pkg
pkgbuild --install-location /Applications --component "build/Release/Math Symbols Input - Preferences.app" build/Release/MathSymbolsInputPreferences.pkg

mkdir -p build/Plugins
cp -r "build/Release/InstallerActivatePane.bundle" build/Plugins
cp InstallerSections.plist build/Plugins

productbuild --distribution distribution.xml --package-path build/Release --plugins build/Plugins MathSymbolsInput.pkg
