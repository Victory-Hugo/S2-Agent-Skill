#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
常驻会话守护进程：只登录「4-中科大重医」堡垒机 -> 目标服务器 中科大重医超算 一次，
之后把目标机 shell 长期握在手里，通过本地 Unix socket 接收命令并即时执行。

这样后续每条命令只花"命令本身"的时间，不再重复 15~30 秒的登录流程。

用法：
    # 前台启动（看日志）：
    python3 session_server.py
    # 后台启动：
    nohup python3 session_server.py >/tmp/cqmu_session.log 2>&1 &

启动成功后会打印一行 "SESSION_READY"。之后照常用 run_remote.py 发命令即可，
run_remote.py 会自动探测到本守护进程并走极速通道。

前置条件：Windows 侧 relay.ps1 已在运行（把 127.0.0.1:2222 转发到堡垒机 10.13.0.20:2222）。
"""
import os, sys, time, re, socket, threading, uuid, signal
import pexpect

# ---- 连接信息（与 run_remote.py 保持一致）----
PROXY = "127.0.0.1"
PORT = "2222"
BASTION_USER = "CQMU_Luolintao"
BASTION_PASS = "lRz(34+*JK1m"
RESOURCE_SEL = "1"
TARGET_ACCOUNT = "CQMU_Luolintao"
TARGET_PASS = "wu#9g33"

SOCK_PATH = "/tmp/cqmu_session.sock"     # run_remote.py 探测同一路径
KEEPALIVE_SEC = 120                      # 空闲心跳，避免堡垒机/目标机踢掉会话

ssh_cmd = (
    f"ssh -tt -p {PORT} "
    "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "
    "-o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa "
    "-o ServerAliveInterval=30 -o ServerAliveCountMax=6 "
    f"{BASTION_USER}@{PROXY}"
)


def submit(child, text, eol="\r"):
    """堡垒机菜单为单字符 raw 读取：逐字符发送 + 单独回车。"""
    for ch in text:
        child.send(ch)
        time.sleep(0.08)
    time.sleep(0.4)
    child.send(eol)
    time.sleep(0.4)


def _strip(raw):
    raw = re.sub(r"\x1b\][^\x07]*\x07", "", raw)       # 去 OSC 标题
    raw = re.sub(r"\x1b\[[0-9;?]*[A-Za-z]", "", raw)   # 去 CSI
    return raw.replace("\r", "")


class Session:
    """握住一个已登录到目标机的 pexpect 会话，串行执行命令；掉线自动重登。"""

    def __init__(self):
        self.lock = threading.Lock()
        self.child = None
        self.last = 0.0

    def login(self):
        child = pexpect.spawn(ssh_cmd, encoding="utf-8", timeout=40, codec_errors="replace")
        child.setwinsize(50, 200)
        child.expect(r"[Pp]assword:", timeout=30)
        submit(child, BASTION_PASS)
        child.expect(r"\[e\][^\n]*退出", timeout=30)
        child.expect(r">\s", timeout=10)
        submit(child, RESOURCE_SEL)
        child.expect(r"账户[:：]", timeout=30)
        submit(child, TARGET_ACCOUNT)
        child.expect([r"[Pp]assword[:：]", r"密码[:：]"], timeout=30)
        submit(child, TARGET_PASS)
        child.expect(r"\][\$#]\s*$", timeout=40)
        # 净化会话：关回显(无命令回显)、清空 PS1、去掉 conda 的 PROMPT_COMMAND
        # （后者会在每行前注入 xterm 标题 OSC 序列，干扰标记匹配）。之后输出纯净。
        child.sendline("stty -echo 2>/dev/null; export PS1=''; unset PROMPT_COMMAND")
        child.sendline("echo __SYNC_READY__")
        child.expect(r"__SYNC_READY__", timeout=15)
        self.child = child
        self.last = time.time()
        print("LOGIN_OK", flush=True)

    def _alive(self):
        return self.child is not None and self.child.isalive()

    def _exec(self, cmd, timeout=120):
        """假定已持锁。用唯一 nonce 标记包裹输出，只匹配行首 marker。"""
        nonce = uuid.uuid4().hex[:8]
        beg, end = f"__B_{nonce}__", f"__E_{nonce}__"
        # 已在目标机正常 shell，整段瞬间发送（逐字符慢发只有堡垒机菜单才需要）。
        # END 标记单独成行，绝不和 cmd 用 ';' 拼接，否则 cmd 末尾的 '#' 注释会把它吃掉。
        self.child.send(f"echo {beg}\n{cmd}\necho {end}:$?\n")
        # 回显已关，命令不被回显，故标记只出现一次，无需行首锚定（行首可能被 OSC 序列污染）。
        self.child.expect(re.escape(end) + r":(\d+)", timeout=timeout)
        code = self.child.match.group(1)
        raw = _strip(self.child.before)
        body = raw.split(beg, 1)[1] if beg in raw else raw
        self.last = time.time()
        return body.strip(), code

    def run(self, cmd, timeout=120):
        with self.lock:
            if not self._alive():
                self.login()
            try:
                return self._exec(cmd, timeout)
            except (pexpect.EOF, pexpect.TIMEOUT, OSError):
                # 掉线或卡死：重登一次再试
                try:
                    self.child.close(force=True)
                except Exception:
                    pass
                self.login()
                return self._exec(cmd, timeout)


SESS = Session()


def keepalive():
    while True:
        time.sleep(KEEPALIVE_SEC)
        try:
            if time.time() - SESS.last >= KEEPALIVE_SEC:
                SESS.run(":")   # 无副作用的心跳，刷新空闲计时
        except Exception as e:
            print(f"KEEPALIVE_ERR {e}", flush=True)


def handle(conn):
    try:
        data = b""
        while True:
            chunk = conn.recv(65536)
            if not chunk:
                break
            data += chunk
        cmd = data.decode("utf-8", "replace")
        if not cmd.strip():
            conn.sendall(b"")
            return
        try:
            body, _code = SESS.run(cmd)
            conn.sendall(body.encode("utf-8", "replace"))
        except Exception as e:
            conn.sendall(f"__SESSION_ERROR__ {e}".encode("utf-8", "replace"))
    finally:
        try:
            conn.close()
        except Exception:
            pass


def cleanup(*_):
    try:
        if os.path.exists(SOCK_PATH):
            os.unlink(SOCK_PATH)
    finally:
        os._exit(0)


def main():
    if os.path.exists(SOCK_PATH):
        os.unlink(SOCK_PATH)
    signal.signal(signal.SIGINT, cleanup)
    signal.signal(signal.SIGTERM, cleanup)

    SESS.login()                              # 启动即登录，失败直接退出
    threading.Thread(target=keepalive, daemon=True).start()

    srv = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    srv.bind(SOCK_PATH)
    srv.listen(16)
    print(f"SESSION_READY {SOCK_PATH}", flush=True)
    while True:
        conn, _ = srv.accept()
        threading.Thread(target=handle, args=(conn,), daemon=True).start()


if __name__ == "__main__":
    main()
