#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
CONFIG_PATH="$PROJECT_ROOT/conf/Config.json"
BOOTSTRAP_PYTHON="python3"

if [[ ! -f "$CONFIG_PATH" ]]; then
    echo "[ERROR] Config file not found: $CONFIG_PATH" >&2
    exit 1
fi

bash "$PROJECT_ROOT/script/check_env.sh"

CONFIG_LOADER="$PROJECT_ROOT/python/config_loader.py"
PYTHON_BIN=$("$BOOTSTRAP_PYTHON" "$CONFIG_LOADER" --config "$CONFIG_PATH" --key tools.python)
INPUT_DIR=$("$BOOTSTRAP_PYTHON" "$CONFIG_LOADER" --config "$CONFIG_PATH" --key paths.input_dir)
OUTPUT_DIR=$("$BOOTSTRAP_PYTHON" "$CONFIG_LOADER" --config "$CONFIG_PATH" --key paths.output_dir)
REFERENCE=$("$BOOTSTRAP_PYTHON" "$CONFIG_LOADER" --config "$CONFIG_PATH" --key paths.reference)
JOBS=$("$BOOTSTRAP_PYTHON" "$CONFIG_LOADER" --config "$CONFIG_PATH" --key runtime.jobs)

mkdir -p "$PROJECT_ROOT/$OUTPUT_DIR"

"$PYTHON_BIN" "$PROJECT_ROOT/python/example_step.py" \
    --input "$PROJECT_ROOT/$INPUT_DIR" \
    --output "$PROJECT_ROOT/$OUTPUT_DIR/step-summary.txt" \
    --ref "$PROJECT_ROOT/$REFERENCE" \
    --jobs "$JOBS"

echo "[OK] Pipeline finished."
