#!/bin/sh
# Build Sunshine on the Mac mini: Apple clang with the Command Line Tools SDK and Homebrew libraries.
# Produces build/Sunshine.app with the bundle ID dev.rubas.sunshine-sckit, which the Screen Recording
# and Accessibility grants belong to; does not install or sign.
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

# The prebuilt FFmpeg from build-deps lets VideoToolbox packets pile up for the whole session.
# Rebuild its VideoToolbox encoder from the same FFmpeg source with
# ffmpeg-videotoolbox-bounded-delay.patch and swap the object into the prebuilt libavcodec.a.
ff=build/ffmpeg-vt
rm -rf "$ff" && mkdir -p "$ff/src"
git -C third-party/build-deps/third-party/FFmpeg/FFmpeg archive HEAD | tar -x -C "$ff/src"
patch -d "$ff/src" -p1 < scripts/ffmpeg-videotoolbox-bounded-delay.patch
(cd "$ff" && src/configure --disable-everything --disable-autodetect --enable-videotoolbox \
  --enable-encoder=h264_videotoolbox,hevc_videotoolbox --disable-programs --disable-doc > configure.log &&
  make libavcodec/videotoolboxenc.o > make.log)
cp "$ff/libavcodec/videotoolboxenc.o" "$ff/videotoolboxenc.o"
(cd "$ff" && ar r ../_deps/ffmpeg/lib/libavcodec.a videotoolboxenc.o)

ninja -C build
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier dev.rubas.sunshine-sckit" -c "Set :CFBundleName Sunshine-sckit" \
  build/Sunshine.app/Contents/Info.plist
