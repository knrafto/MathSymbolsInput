#!/usr/bin/env bash
set -eux

sudo cp -r "build/Debug/Math Symbols Input.app" "/Library/Input Methods"
killall -9 "Math Symbols Input"
