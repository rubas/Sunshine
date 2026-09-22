#!/bin/sh
# Build Sunshine on the Mac mini: Apple clang with the Command Line Tools SDK and Homebrew libraries.
# Produces build/Sunshine.app; does not install or sign.
set -eux
cd "$(dirname "$0")/.."
export PATH=/opt/homebrew/bin:$PATH
brew install cmake ninja pkg-config openssl@3 curl miniupnpc opus boost node qt
git submodule update --init --recursive
export CC=/usr/bin/clang CXX=/usr/bin/clang++
export MACOSX_DEPLOYMENT_TARGET=15.0
export PKG_CONFIG_PATH=/opt/homebrew/opt/curl/lib/pkgconfig:/opt/homebrew/opt/openssl@3/lib/pkgconfig
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DBUILD_DOCS=OFF -DBUILD_TESTS=OFF -DBUILD_WERROR=OFF \
  "-DCMAKE_PREFIX_PATH=/opt/homebrew;/opt/homebrew/opt/openssl@3;/opt/homebrew/opt/curl;/opt/homebrew/opt/qt"
ninja -C build
