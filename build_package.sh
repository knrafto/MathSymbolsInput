#!/usr/bin/env bash
# Generates MathSymbolsInputInstaller.pkg.

set -euxo pipefail

xcodebuild -alltargets -configuration Release

pkgbuild --install-location "/Library/Input Methods" --component build/Release/MathSymbolsInput.app build/Release/MathSymbolsInput.pkg
pkgbuild --install-location /Applications --component build/Release/MathSymbolsPreferences.app build/Release/MathSymbolsPreferences.pkg

productbuild --distribution distribution.xml --package-path build/Release MathSymbolsInputInstaller.pkg
