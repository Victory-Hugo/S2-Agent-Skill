#!/usr/bin/env bash
# 将 assets/project-template/ 复制到目标目录，作为新 pipeline 项目的起点。
# 模板包含：conf/1-data_preprocessing.yaml、pipe/1-data_preprocessing.sh 等。
# 每新增一个 pipe 步骤，需同步新建对应编号的 conf/N-<name>.yaml，
# 并在 output/N-<name>/ 下创建 1-table/、2-figure/、3-report/ 子目录。
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
echo "[NOTE] Edit conf/1-data_preprocessing.yaml to configure step 1."
echo "[NOTE] Add conf/2-<name>.yaml + pipe/2-<name>.sh for each additional step."
