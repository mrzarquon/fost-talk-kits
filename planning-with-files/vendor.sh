#!/usr/bin/env bash
# Refresh the vendored planning-with-files skill from upstream master.
# Runs on the HOST (not in a sandbox). Requires git.
set -euo pipefail

REPO="https://github.com/OthmanAdi/planning-with-files.git"
KIT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEST="$KIT_DIR/files/workspace/.claude/skills/planning-with-files"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

git clone --depth 1 "$REPO" "$TMP/repo"

rm -rf "$DEST"
mkdir -p "$DEST"
cp -R "$TMP/repo/skills/planning-with-files/." "$DEST/"
cp "$TMP/repo/LICENSE" "$DEST/LICENSE"
chmod +x "$DEST"/scripts/*.sh 2>/dev/null || true

VERSION="$(grep -m1 -E '^\s*version:' "$DEST/SKILL.md" | awk '{print $2}' || true)"
echo "Vendored planning-with-files ${VERSION:-(version not found)} from upstream master."
echo "Review the diff, then update the version note in README.md."
