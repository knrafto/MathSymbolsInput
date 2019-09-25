#!/usr/bin/env bash

set -euxo pipefail

cp -r build/Debug/UnicodeInput.app "$HOME/Library/Input Methods"
killall UnicodeInput
