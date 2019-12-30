#!/usr/bin/env bash
# Generates MathSymbolsInputInstaller.pkg.

set -euxo pipefail

xcodebuild -alltargets -configuration Release

pkgbuild --install-location "/Library/Input Methods" --component build/Release/MathSymbolsInput.app build/Release/MathSymbolsInput.pkg
pkgbuild --install-location /Applications --component build/Release/MathSymbolsPreferences.app build/Release/MathSymbolsPreferences.pkg

mkdir -p build/Plugins
cp -r build/Release/InstallerActivatePane.bundle build/Plugins
cp InstallerSections.plist build/Plugins

productbuild --distribution distribution.xml --package-path build/Release --plugins build/Plugins MathSymbolsInputInstaller.pkg
