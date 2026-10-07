#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
非交互地登录「4-中科大重医」堡垒机并在目标服务器 中科大重医超算(20.11.100.2) 执行命令。

用法:
    python3 run_remote.py "要在目标服务器执行的命令"
例:
    python3 run_remote.py "hostname && whoami && df -h"

加速:
    若 session_server.py 已在后台运行，本脚本会自动探测到 /tmp/cqmu_session.sock
    并走"复用已登录会话"的极速通道（只花命令本身的时间）；探测不到则回退到
    下面的一次性完整登录流程，行为与以前完全一致。

前置条件:
    Windows 侧已运行 relay.ps1（把本机 127.0.0.1:2222 转发到堡垒机 10.13.0.20:2222），
    因为只有 Windows 主机能到堡垒机内网，而 WSL 处于 mirrored 网络模式可共享 127.0.0.1。
"""
import os, sys, time, re, socket, pexpect

SOCK_PATH = "/tmp/cqmu_session.sock"   # 与 session_server.py 一致

PROXY = "127.0.0.1"          # Windows relay 监听地址（mirrored 模式下 WSL 可直接访问）
PORT = "2222"
BASTION_USER = "CQMU_Luolintao"
BASTION_PASS = "lRz(34+*JK1m"
RESOURCE_SEL = "1"           # 菜单中 [1] [Empty]@20.11.100.2 (中科大重医超算)
TARGET_ACCOUNT = "CQMU_Luolintao"
TARGET_PASS = "wu#9g33"

cmd = sys.argv[1] if len(sys.argv) > 1 else "echo hello && hostname"
BEG, END = "__OUT_BEGIN__", "__OUT_END__"

ssh_cmd = (
    f"ssh -tt -p {PORT} "
    "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "
    "-o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa "
    f"{BASTION_USER}@{PROXY}"
)

def via_daemon(command):
    """守护进程在线则走极速通道；返回输出字符串，否则返回 None（让调用方回退）。"""
    if not os.path.exists(SOCK_PATH):
        return None
    try:
        s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        s.settimeout(300)
        s.connect(SOCK_PATH)
        s.sendall(command.encode("utf-8"))
        s.shutdown(socket.SHUT_WR)          # 半关闭，告诉服务端命令发完了
        buf = b""
        while True:
            ch = s.recv(65536)
            if not ch:
                break
            buf += ch
        s.close()
        return buf.decode("utf-8", "replace")
    except Exception:
        return None


def submit(child, text, eol="\r"):
    """堡垒机菜单为单字符 raw 读取：逐字符发送 + 单独回车。"""
    for ch in text:
        child.send(ch)
        time.sleep(0.08)
    time.sleep(0.4)
    child.send(eol)
    time.sleep(0.4)

def main():
    # 极速通道：常驻会话守护进程在线则直接复用，跳过整套登录
    fast = via_daemon(cmd)
    if fast is not None:
        print(fast.strip())
        return

    # 回退：一次性完整登录流程（与守护进程未运行时行为一致）
    child = pexpect.spawn(ssh_cmd, encoding="utf-8", timeout=40, codec_errors="replace")
    child.setwinsize(50, 200)
    # child.logfile_read = sys.stderr   # 调试时取消注释
    try:
        child.expect(r"[Pp]assword:", timeout=30)
        submit(child, BASTION_PASS)

        child.expect(r"\[e\][^\n]*退出", timeout=30)
        child.expect(r">\s", timeout=10)
        submit(child, RESOURCE_SEL)

        child.expect(r"账户[:：]", timeout=30)
        submit(child, TARGET_ACCOUNT)

        child.expect([r"[Pp]assword[:：]", r"密码[:：]"], timeout=30)
        submit(child, TARGET_PASS)

        # 等目标 shell 提示符
        child.expect(r"\][\$#]\s*$", timeout=40)
        # 净化会话：关回显、清空 PS1、去掉 conda 的 PROMPT_COMMAND（它会注入 OSC 标题序列）。
        child.sendline("stty -echo 2>/dev/null; export PS1=''; unset PROMPT_COMMAND")
        child.sendline("echo __SYNC_READY__")
        child.expect(r"__SYNC_READY__", timeout=15)

        # END 标记单独成行（不与 cmd 用 ';' 拼接），否则 cmd 末尾的 '#' 注释会把它吃掉。
        # 回显已关，标记只出现一次，无需行首锚定（行首可能被 OSC 序列污染）。
        child.send(f"echo {BEG}\n{cmd}\necho {END}\n")
        child.expect(re.escape(END), timeout=60)
        raw = child.before

        # 退出目标 -> 退出堡垒机
        submit(child, "exit")
        time.sleep(0.5)
        try:
            child.send("e\r"); time.sleep(0.3)
        except Exception:
            pass
    finally:
        try:
            child.close(force=True)
        except Exception:
            pass

    # 取 BEGIN 之后的内容（回显已关，BEGIN 只出现一次）
    raw = re.sub(r"\x1b\][^\x07]*\x07", "", raw)        # 去 OSC 标题
    raw = re.sub(r"\x1b\[[0-9;?]*[A-Za-z]", "", raw)    # 去 CSI
    raw = raw.replace("\r", "")
    body = raw.split(BEG, 1)[1] if BEG in raw else raw
    print(body.strip())

if __name__ == "__main__":
    main()
