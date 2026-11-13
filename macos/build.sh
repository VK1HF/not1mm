#!/bin/bash
# Build the macOS Not1MM app and an unsigned DMG from a clean checkout.
#   macos/build.sh
# Needs: Homebrew python@3.12 and create-dmg (brew install python@3.12 create-dmg).
# Safe to run again: it rebuilds the venv packages, the app and the DMG.
# --skip-jenkins: create-dmg's Finder layout step needs a GUI session and
# times out unattended, so the DMG keeps Finder's default icon layout.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PYTHON="${PYTHON:-/opt/homebrew/bin/python3.12}"
VENV="${VENV:-$ROOT/macos/.venv}"

[ -x "$PYTHON" ] || { echo "Need $PYTHON (brew install python@3.12)" >&2; exit 1; }
command -v create-dmg >/dev/null || { echo "Need create-dmg (brew install create-dmg)" >&2; exit 1; }

VERSION=$("$PYTHON" -c 'import tomllib;print(tomllib.load(open("pyproject.toml","rb"))["project"]["version"])')
DMG="$ROOT/dist/Not1MM-$VERSION-macOS-arm64-unsigned.dmg"

echo "=== Not1MM $VERSION: venv and dependencies"
[ -d "$VENV" ] || "$PYTHON" -m venv "$VENV"
"$VENV/bin/pip" install -q --upgrade pip
"$VENV/bin/pip" install -q . pyinstaller

echo "=== PyInstaller"
rm -rf "$ROOT/build/not1mm" "$ROOT/dist/not1mm" "$ROOT/dist/not1mm.app"
"$VENV/bin/pyinstaller" --noconfirm --clean \
    --distpath "$ROOT/dist" --workpath "$ROOT/build" macos/not1mm.spec

APP="$ROOT/dist/not1mm.app"
cp LICENSE "$APP/Contents/Resources/LICENSE"

echo "=== Ad-hoc signing"
codesign --force --deep -s - "$APP"
codesign --verify --deep --strict "$APP"

echo "=== DMG"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
cp -R "$APP" "$STAGE/"
cp LICENSE "$STAGE/LICENSE"
cp macos/README-macOS.txt "$STAGE/README-macOS.txt"
rm -f "$DMG"
create-dmg \
    --volname "Not1MM $VERSION" \
    --volicon macos/not1mm.icns \
    --window-size 640 400 \
    --icon-size 96 \
    --icon "not1mm.app" 140 160 \
    --app-drop-link 480 160 \
    --icon "LICENSE" 220 300 \
    --icon "README-macOS.txt" 400 300 \
    --no-internet-enable \
    --skip-jenkins \
    "$DMG" "$STAGE" >/dev/null

echo "=== Done"
echo "$DMG ($(du -h "$DMG" | cut -f1))"
