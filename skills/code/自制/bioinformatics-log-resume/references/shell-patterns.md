# Shell Patterns

## Initialize Logs

```bash
LOG_DIR="${PROJECT_DIR}/log"
LOCK_FILE="${LOG_DIR}/.resume.lock"
SUCCESS_LOG="${LOG_DIR}/success.log"
FAIL_LOG="${LOG_DIR}/fail.log"

mkdir -p "$LOG_DIR"
touch "$LOCK_FILE" "$SUCCESS_LOG" "$FAIL_LOG"
```

## Load Completed Samples

只读取 `success.log` 第一列：

```bash
declare -A COMPLETED=()

while IFS=$'\t' read -r sample_id _; do
  [ -n "$sample_id" ] || continue
  COMPLETED["$sample_id"]=1
done < "$SUCCESS_LOG"
```

## Skip Check

使用精确样本 ID 匹配，不做模糊匹配：

```bash
is_completed() {
  local sample_id="$1"
  [[ -n "${COMPLETED[$sample_id]:-}" ]]
}
```

## Locked Append

```bash
record_success() {
  local sample_id="$1"
  local ts
  ts="$(date -Iseconds)"
  flock "$LOCK_FILE" bash -c 'printf "%s\t%s\n" "$1" "$2" >> "$3"' _ \
    "$sample_id" "$ts" "$SUCCESS_LOG"
  COMPLETED["$sample_id"]=1
}

record_fail() {
  local sample_id="$1"
  flock "$LOCK_FILE" bash -c 'printf "%s\n" "$1" >> "$2"' _ \
    "$sample_id" "$FAIL_LOG"
}
```

## Per-Sample Worker Skeleton

```bash
run_one_sample() {
  local sample_id="$1"

  if is_completed "$sample_id"; then
    printf "[skip] %s already in success.log\n" "$sample_id" >&2
    return 0
  fi

  if run_sample_pipeline "$sample_id"; then
    record_success "$sample_id"
  else
    record_fail "$sample_id"
  fi
}
```

## Anti-Examples

以下写法是禁止的，因为它依赖输出文件而不是日志：

```bash
if [ -s "${OUTPUT_DIR}/${sample_id}/result.tsv" ]; then
  echo "[skip] ${sample_id} finished before"
  continue
fi
```

应改为只查询 `success.log`。
