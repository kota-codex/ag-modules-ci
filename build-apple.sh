#!/usr/bin/env bash
set -x
set -euo pipefail

: "${VCPKG_ROOT:?Error: VCPKG_ROOT must be set to your vcpkg installation path}"

# update subpackages
if [ -f "update.sh" ]; then
  bash update.sh
fi

#  name           ag-triple sysName osxArc osxDeplTarget osxSysRoot      buildType
TRIPLES=(
  "x86-macos-rel   x64-osx   Darwin  x86_64    11.0       macosx          Release"
  "x86-macos-dbg   x64-osx   Darwin  x86_64    11.0       macosx          Debug"
  "arm-macos-rel   arm64-osx Darwin  arm64     11.0       macosx          Release"
  "arm-macos-dbg   arm64-osx Darwin  arm64     11.0       macosx          Debug"
  "x86-iphone-sim  x64-ios   iOS     x86_64    13.0       iphonesimulator Debug"
  "arm-iphone-sim  arm64-ios iOS     arm64     13.0       iphonesimulator Debug"
  "iphone-ipad     arm64-ios iOS     arm64     13.0       iphoneos        Release"
)
# Excluded: release for iphonesimulator and x86_64/iphone

GENERATOR="Ninja"

for tripleEntry in "${TRIPLES[@]}"; do
  read -r name triple sysName arch depl sysroot config<<< "$tripleEntry"

  BUILD_DIR="build/${triple}"
  OUT_DIR="../../out"  # relative to build dir
  echo "Building ${name} in ${BUILD_DIR}"
  mkdir -p "${BUILD_DIR}"

  cmake -S "." -B "${BUILD_DIR}" -G "${GENERATOR}" \
    -DCMAKE_TOOLCHAIN_FILE="${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake" \
    -DCMAKE_SYSTEM_NAME="${sysName}" \
    -DCMAKE_OSX_ARCHITECTURES="${arch}" \
    -DVCPKG_TARGET_TRIPLET="${triple}" \
    -DCMAKE_BUILD_TYPE="${config}" \
    -DAG_OUT_DIR="${OUT_DIR}" \
    -DAG_TRIPLE="${triple}" \
    -DCMAKE_OSX_SYSROOT="${sysroot}" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET="${depl}"

  cmake --build "${BUILD_DIR}" --parallel "$(sysctl -n hw.logicalcpu)"
done
