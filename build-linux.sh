#!/usr/bin/env bash
set -x
set -euo pipefail

: "${VCPKG_ROOT:?Error: VCPKG_ROOT must be set to your vcpkg installation path}"

if [ -f "update.sh" ]; then
  ./update.sh
fi

triple="$1-linux"
CONFIGS=(Release Debug)
GENERATOR="Ninja"

for config in "${CONFIGS[@]}"; do
  BUILD_DIR="build/${triple}"
  OUT_DIR="../../out"  # relative to build dir
  echo "Building ${triple}, config: ${config} in ${BUILD_DIR}"
  mkdir -p "${BUILD_DIR}"

  CMAKE_ARGS=(
    -S "."
    -B "${BUILD_DIR}"
    -G "${GENERATOR}"
    -DCMAKE_TOOLCHAIN_FILE="${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
    -DVCPKG_TARGET_TRIPLET="${triple}"
    -DCMAKE_BUILD_TYPE="${config}"
    -DAG_OUT_DIR="${OUT_DIR}"
    -DAG_TRIPLE="${triple}"
  )
  cmake "${CMAKE_ARGS[@]}"
  cmake --build "${BUILD_DIR}" --parallel "$(nproc || echo 4)"
done
