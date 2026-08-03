#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
CONFIG_PATH="$PROJECT_ROOT/conf/1-data_preprocessing.yaml"

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
        printf '%s\n' "$PROJECT_ROOT/$raw_path"
    fi
}

require_var CFG_PROJECT_INPUT_TABLE
require_var CFG_TOOLS_PYTHON_BIN
require_var CFG_PATHS_OUTPUT_RESULT
require_var CFG_PATHS_OUTPUT_FIGURE
require_var CFG_PATHS_OUTPUT_REPORT
require_var CFG_PATHS_TEMP
require_var CFG_RUNTIME_JOBS

PYTHON_BIN=$(resolve_path "$CFG_TOOLS_PYTHON_BIN")
INPUT_TABLE=$(resolve_path "$CFG_PROJECT_INPUT_TABLE")
OUTPUT_RESULT=$(resolve_path "$CFG_PATHS_OUTPUT_RESULT")
OUTPUT_FIGURE=$(resolve_path "$CFG_PATHS_OUTPUT_FIGURE")
OUTPUT_REPORT=$(resolve_path "$CFG_PATHS_OUTPUT_REPORT")
TEMP_DIR=$(resolve_path "$CFG_PATHS_TEMP")
JOBS="$CFG_RUNTIME_JOBS"

mkdir -p "$OUTPUT_RESULT" "$OUTPUT_FIGURE" "$OUTPUT_REPORT" "$TEMP_DIR"

"$PYTHON_BIN" "$PROJECT_ROOT/python/1-1-data_preprocessing.py" \
    --input  "$INPUT_TABLE" \
    --output "$OUTPUT_RESULT" \
    --figure "$OUTPUT_FIGURE" \
    --jobs   "$JOBS"

echo "[OK] 1-data_preprocessing finished."
