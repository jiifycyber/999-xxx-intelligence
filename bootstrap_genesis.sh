#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "===== 999 GENESIS PROTOCOL LEVEL 6 ====="
echo "Preparing isolated Flutter platforms..."

if ! command -v flutter >/dev/null 2>&1; then
  echo "ERROR: Flutter is not available in PATH."
  exit 1
fi

flutter create \
  --project-name genesis_protocol_level_6 \
  --org io.intelligence999 \
  --platforms web,macos,ios,android \
  .

flutter pub get
dart format lib test
flutter analyze
flutter test

echo
echo "GENESIS LEVEL 6 IS READY."
echo "Run: flutter run -d chrome"
