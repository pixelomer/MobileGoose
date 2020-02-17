#!/usr/bin/env bash

[ -z "${THEOS}" ] && { echo "THEOS is not set!"; exit 1; }

set -e

mkdir -p "${THEOS}/templates/ios/pixelomer"
cp iphone_goose_mod.nic.tar "${THEOS}/templates/ios/pixelomer/"
cp MobileGoose.h "${THEOS}/include/"