#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: bash scripts/init_pipeline_layout.sh <target_dir>" >&2
    exit 1
fi

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SKILL_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
TEMPLATE_DIR="$SKILL_ROOT/assets/project-template"
TARGET_DIR="$1"

if [[ ! -d "$TEMPLATE_DIR" ]]; then
    echo "[ERROR] Template directory not found: $TEMPLATE_DIR" >&2
    exit 1
fi

if [[ -e "$TARGET_DIR" ]] && [[ -n "$(find "$TARGET_DIR" -mindepth 1 -maxdepth 1 2>/dev/null)" ]]; then
    echo "[ERROR] Target directory is not empty: $TARGET_DIR" >&2
    exit 1
fi

mkdir -p "$TARGET_DIR"
cp -R "$TEMPLATE_DIR"/. "$TARGET_DIR"/

echo "[OK] Project template copied to: $TARGET_DIR"
