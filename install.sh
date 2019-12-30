#!/usr/bin/env bash

set -euxo pipefail

sudo cp -r build/Debug/MathSymbolsInput.app "/Library/Input Methods"
killall MathSymbolsInput
