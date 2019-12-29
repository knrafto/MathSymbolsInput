#!/usr/bin/env bash

set -euxo pipefail

cp -r build/Debug/MathSymbolsInput.app "$HOME/Library/Input Methods"
killall MathSymbolsInput.app
