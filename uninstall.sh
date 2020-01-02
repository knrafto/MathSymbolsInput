#!/usr/bin/env bash
set -eux

sudo rm -rf "/Library/Input Methods/Math Symbols Input.app"
sudo rm -rf "/Applications/Math Symbols Input - Preferences.app"
killall -9 "Math Symbols Input"
