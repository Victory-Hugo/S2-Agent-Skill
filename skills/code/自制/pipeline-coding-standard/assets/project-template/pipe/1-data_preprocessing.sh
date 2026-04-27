#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
CONFIG_PATH="$PROJECT_ROOT/conf/Config.yaml"

if [[ ! -f "$CONFIG_PATH" ]]; then
    echo "[ERROR] Config file not found: $CONFIG_PATH" >&2
    exit 1
fi

source "$PROJECT_ROOT/script/load_config.sh" "$CONFIG_PATH"
bash "$PROJECT_ROOT/script/check_env.sh" "$CONFIG_PATH"

require_var() {
    local var_name="$1"
    if [[ -z "${!var_name:-}" ]]; then
        echo "[ERROR] Missing required config value: $var_name" >&2
        exit 1
    fi
}

resolve_path() {
    local raw_path="$1"
    if [[ "$raw_path" = /* ]]; then
        printf '%s\n' "$raw_path"
    else
        printf '%s\n' "$BASE_DIR/$raw_path"
    fi
}

resolve_project_path() {
    local raw_path="$1"
    if [[ "$raw_path" = /* ]]; then
        printf '%s\n' "$raw_path"
    else
        printf '%s\n' "$PROJECT_ROOT/$raw_path"
    fi
}

require_var CFG_PROJECT_BASE_DIR
require_var CFG_PROJECT_INPUT_TABLE
require_var CFG_TOOLS_PYTHON_BIN
require_var CFG_PATHS_PYTHON_DIR
require_var CFG_PATHS_OUTPUT_DIR
require_var CFG_PATHS_OUTPUT_STEP1_TABLE
require_var CFG_PATHS_OUTPUT_STEP1_FIGURE
require_var CFG_PATHS_OUTPUT_STEP1_REPORT
require_var CFG_PATHS_TEMP_STEP1
require_var CFG_PATHS_REFERENCE
require_var CFG_RUNTIME_JOBS

BASE_DIR=$(resolve_project_path "$CFG_PROJECT_BASE_DIR")
PYTHON_BIN=$(resolve_path "$CFG_TOOLS_PYTHON_BIN")
PYTHON_DIR=$(resolve_path "$CFG_PATHS_PYTHON_DIR")
INPUT_TABLE=$(resolve_path "$CFG_PROJECT_INPUT_TABLE")
OUTPUT_DIR=$(resolve_path "$CFG_PATHS_OUTPUT_DIR")
STEP1_TABLE_DIR=$(resolve_path "$CFG_PATHS_OUTPUT_STEP1_TABLE")
STEP1_FIGURE_DIR=$(resolve_path "$CFG_PATHS_OUTPUT_STEP1_FIGURE")
STEP1_REPORT_DIR=$(resolve_path "$CFG_PATHS_OUTPUT_STEP1_REPORT")
STEP1_TEMP_DIR=$(resolve_path "$CFG_PATHS_TEMP_STEP1")
REFERENCE=$(resolve_path "$CFG_PATHS_REFERENCE")
JOBS="$CFG_RUNTIME_JOBS"

mkdir -p "$OUTPUT_DIR" "$STEP1_TABLE_DIR" "$STEP1_FIGURE_DIR" "$STEP1_REPORT_DIR" "$STEP1_TEMP_DIR"

"$PYTHON_BIN" "$PYTHON_DIR/1-1-data_preprocessing.py" \
    --input "$INPUT_TABLE" \
    --output "$STEP1_TABLE_DIR/step-summary.txt" \
    --ref "$REFERENCE" \
    --jobs "$JOBS"

echo "[OK] Pipeline finished."
