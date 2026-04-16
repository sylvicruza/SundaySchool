#!/bin/sh
set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FLUTTER_VERSION="${FLUTTER_VERSION:-3.29.3}"
FLUTTER_DIR="${HOME}/flutter"

echo "Preparing Flutter ${FLUTTER_VERSION} for Xcode Cloud..."

if ! command -v flutter >/dev/null 2>&1; then
  if [ ! -d "${FLUTTER_DIR}" ]; then
    git clone --depth 1 --branch "${FLUTTER_VERSION}" https://github.com/flutter/flutter.git "${FLUTTER_DIR}"
  fi
  export PATH="${FLUTTER_DIR}/bin:${PATH}"
fi

flutter --version
flutter precache --ios

cd "${REPO_ROOT}"
flutter pub get

cd "${REPO_ROOT}/ios"
pod install --repo-update
