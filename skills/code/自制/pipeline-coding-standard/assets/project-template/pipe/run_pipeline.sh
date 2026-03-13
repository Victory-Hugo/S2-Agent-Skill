#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
CONFIG_PATH="$PROJECT_ROOT/conf/Config.yaml"

if [[ ! -f "$CONFIG_PATH" ]]; then
    echo "[ERROR] Config file not found: $CONFIG_PATH" >&2
    exit 1
fi

bash "$PROJECT_ROOT/script/check_env.sh"

source "$PROJECT_ROOT/script/load_config.sh" "$CONFIG_PATH"

require_var() {
    local var_name="$1"
    if [[ -z "${!var_name:-}" ]]; then
        echo "[ERROR] Missing required config value: $var_name" >&2
        exit 1
    fi
}

require_var CFG_TOOLS_PYTHON
require_var CFG_PATHS_INPUT_DIR
require_var CFG_PATHS_OUTPUT_DIR
require_var CFG_PATHS_REFERENCE
require_var CFG_RUNTIME_JOBS

PYTHON_BIN="$CFG_TOOLS_PYTHON"
INPUT_DIR="$CFG_PATHS_INPUT_DIR"
OUTPUT_DIR="$CFG_PATHS_OUTPUT_DIR"
REFERENCE="$CFG_PATHS_REFERENCE"
JOBS="$CFG_RUNTIME_JOBS"

mkdir -p "$PROJECT_ROOT/$OUTPUT_DIR"

"$PYTHON_BIN" "$PROJECT_ROOT/python/example_step.py" \
    --input "$PROJECT_ROOT/$INPUT_DIR" \
    --output "$PROJECT_ROOT/$OUTPUT_DIR/step-summary.txt" \
    --ref "$PROJECT_ROOT/$REFERENCE" \
    --jobs "$JOBS"

echo "[OK] Pipeline finished."
