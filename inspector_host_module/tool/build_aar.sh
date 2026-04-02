#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
flutter pub get
flutter build aar
echo ""
echo "Maven repo: $(pwd)/build/host/outputs/repo"
echo "See ../ANDROID_AAR.md for Gradle setup."
