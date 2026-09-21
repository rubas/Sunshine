#!/bin/sh
# Build Sunshine on the Mac mini: Apple clang, the nixpkgs apple-sdk sysroot, and nixpkgs libraries.
# No Homebrew. Produces build/Sunshine.app; does not install or sign.
#
# libc++experimental (needed by -fexperimental-library) is missing from the nix apple-sdk,
# so the link gets a directory that holds only the copy from the Command Line Tools SDK.
set -eu
cd "$(dirname "$0")/.."
git submodule update --init --recursive
exec nix-shell -p cmake ninja pkg-config openssl curl miniupnpc libopus boost qt6.qtbase qt6.qtsvg --run "
  set -eux
  export CC=/usr/bin/clang CXX=/usr/bin/clang++
  export MACOSX_DEPLOYMENT_TARGET=15.0
  mkdir -p build/exlib
  cp /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib/libc++experimental.a build/exlib/
  cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DBUILD_DOCS=OFF -DBUILD_TESTS=OFF -DBUILD_WERROR=OFF \
    -DCMAKE_EXE_LINKER_FLAGS=-L\$PWD/build/exlib
  ninja -C build
"
