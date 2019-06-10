#!/usr/bin/env bash

set -euxo pipefail

cp -r build/Debug/UnicodeIM.app "$HOME/Library/Input Methods"
killall UnicodeIM
