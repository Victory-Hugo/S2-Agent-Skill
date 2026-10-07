#!/usr/bin/env bash
# 会话守护进程一键启停脚本。
#   ./session_ctl.sh start    启动常驻会话（只登录一次，之后命令极速）
#   ./session_ctl.sh stop     停止常驻会话
#   ./session_ctl.sh status   查看状态
#   ./session_ctl.sh restart  重启
#
# 前置：Windows 侧 relay.ps1 已在运行。
set -u
DIR="$(cd "$(dirname "$0")" && pwd)"
SOCK="/tmp/cqmu_session.sock"
LOG="/tmp/cqmu_session.log"

alive() {  # socket 真正可连才算活着（排除陈旧 socket 文件）
  [ -S "$SOCK" ] || return 1
  python3 - "$SOCK" <<'PY' 2>/dev/null
import socket, sys
s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.settimeout(2)
try:
    s.connect(sys.argv[1]); s.close()
except Exception:
    sys.exit(1)
PY
}

start() {
  if alive; then echo "已在运行：$SOCK"; return 0; fi
  pkill -9 -f session_server.py 2>/dev/null
  rm -f "$SOCK"
  echo "启动会话守护进程（首次登录约需 10~30 秒）..."
  setsid nohup python3 "$DIR/session_server.py" >"$LOG" 2>&1 </dev/null &
  for _ in $(seq 1 60); do
    grep -q SESSION_READY "$LOG" 2>/dev/null && { echo "就绪：$SOCK"; return 0; }
    sleep 1
  done
  echo "启动失败，日志："; cat "$LOG"; return 1
}

stop() {
  pkill -9 -f session_server.py 2>/dev/null
  rm -f "$SOCK"
  echo "已停止。"
}

case "${1:-status}" in
  start)   start ;;
  stop)    stop ;;
  restart) stop; sleep 1; start ;;
  status)  if alive; then echo "运行中：$SOCK"; else echo "未运行"; fi ;;
  *) echo "用法: $0 {start|stop|restart|status}"; exit 2 ;;
esac
