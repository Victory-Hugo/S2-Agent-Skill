#!/usr/bin/env bash

set -euo pipefail

CODEX_DIR="${HOME}/.codex"
AUTH_FILE="${CODEX_DIR}/auth.json"
CONFIG_FILE="${CODEX_DIR}/config.toml"
ACTION_CHOICE=""

prompt_action() {
    local choice

    echo "请选择需要执行的操作："
    echo "【1】将codex账户登录切换为 AiCodeMirror？"
    echo "【2】将AiCodeMirror切换为 codex账户登录？"
    read -r -p "请输入选项编号(1/2，其他任意键取消): " choice

    case "$choice" in
        1|2)
            ACTION_CHOICE="$choice"
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

extract_api_key() {
    local api_key=""

    if [ -f "$AUTH_FILE" ]; then
        api_key="$(sed -n 's/.*"OPENAI_API_KEY"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$AUTH_FILE" | head -n 1)"
        if [ -n "$api_key" ]; then
            printf '%s\n' "$api_key"
            return 0
        fi
    fi

    if [ -n "${OPENAI_API_KEY:-}" ]; then
        printf '%s\n' "$OPENAI_API_KEY"
        return 0
    fi

    printf '%s\n' '你的API_KEY'
}

write_auth_file() {
    local api_key="$1"

    cat > "$AUTH_FILE" <<EOF
{
  "OPENAI_API_KEY": "$api_key"
}
EOF
}

write_config_file() {
    cat > "$CONFIG_FILE" <<'EOF'
model_provider = "aicodemirror"
model = "gpt-5.4"
model_reasoning_effort = "xhigh"
disable_response_storage = true
preferred_auth_method = "apikey"

[model_providers.aicodemirror]
name = "aicodemirror"
base_url = "https://api.aicodemirror.com/api/codex/backend-api/codex"
wire_api = "responses"
EOF
}

switch_to_aicodemirror() {
    local api_key="$1"

    mkdir -p "$CODEX_DIR"
    write_auth_file "$api_key"
    write_config_file
    echo "请重新启动系统生效！"
}

switch_to_codex_login() {
    mkdir -p "$CODEX_DIR"
    rm -f "$AUTH_FILE" "$CONFIG_FILE"
    echo "请重新启动系统生效！"
}

main() {
    local api_key

    if ! prompt_action; then
        echo "已取消切换。"
        exit 0
    fi

    case "$ACTION_CHOICE" in
        1)
            api_key="$(extract_api_key)"
            switch_to_aicodemirror "$api_key"
            ;;
        2)
            switch_to_codex_login
            ;;
        *)
            echo "已取消切换。"
            exit 0
            ;;
    esac
}

main "$@"
