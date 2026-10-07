---
name: cqmu-supercomputing-remote-command
description: 使用WSL和Windows以非交互式方法连接中科大重医超算。
---

# 中科大重医超算 远程命令

## 概述
通过 Windows TCP 转发 + WSL 侧 pexpect 驱动脚本，在 中科大重医超算 上非交互执行命令。
脚本已内置堡垒机登录、资源选择、目标账号与密码。

**关键优化——常驻会话**：默认情况下每条命令都要重走一遍堡垒机登录（约 15~30 秒）。
启动常驻会话守护进程后，**只登录一次**，之后每条命令只花"命令本身"的时间（约 0.1 秒），
提速约 80 倍。`run_remote.py` 会自动探测守护进程：在则走极速通道，不在则自动回退到一次性登录。

## 工作流程
0. **（仅一次，开机后永久有效）预留本地端口 2222**。WSL2/Hyper-V 的 `winnat` 会在每次开机动态占用一批 TCP 端口，若 2222 被圈进去，`relay.ps1` 绑定会报 `WSAEACCES(10013)`（窗口闪退）。用**管理员** PowerShell 运行一次即可永久解决：
```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\reserve_port.ps1
```
> 验证：`netsh int ipv4 show excludedportrange protocol=tcp` 中应能看到 2222 被单独持久预留。做过一次后无需再做。

1. 在 PowerShell 启动 Windows 转发（看到 `RELAY_UP listening :2222 ...` 即就绪）：
```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\relay.ps1
```
> 若仍报无法监听 2222，多半是没做第 0 步；relay.ps1 会打印修复命令并停住等待，不会再闪退。

2. 在 WSL 启动常驻会话（**推荐，首次约 10~30 秒登录，之后命令极速**）：
```bash
./scripts/session_ctl.sh start      # 幂等：已在跑则不重复登录
./scripts/session_ctl.sh status     # 查看状态
```

3. 在 中科大重医超算 上运行命令（接口不变，自动走极速通道）：
```bash
python3 ./scripts/run_remote.py "hostname; whoami; nproc; df -h /home"
```
脚本只输出远程命令的标准输出，结果可被其他程序解析。

> 不想用常驻会话也可以：跳过第 2 步，直接执行第 3 步即可（每条命令自动完整登录，较慢）。

## 重要特性与注意事项
* **会话状态是连续的**：常驻模式下所有命令跑在同一个 shell 里，`cd`、变量、`export` 会保留到下一条命令。需要独立环境时请在单条命令内自包含（如用 `cd /path && ...`）。
* `run_remote.py` 已对命令做了健壮包裹：命令末尾的 `#` 注释、引号、管道、中文、制表符、多行输出均正常。
* 守护进程内置 120 秒心跳防止堡垒机踢线；若会话掉线会自动重登后重试一次。
* Windows 重启后需重新启动 `relay.ps1`；之后用 `session_ctl.sh restart` 重建会话。
* **同账号并发会话可能被堡垒机拒绝**：不要同时开多个守护进程；换脚本前先 `session_ctl.sh stop` 清干净。

## 路径限制（务必遵守）
* 发命令时 Windows 上的 `relay.ps1` 必须在运行。
* 必须使用 WSL 原生 Linux `ssh` + `pexpect`，不要通过互操作调用 Windows `ssh.exe`（raw 模式下会冻结输出）。
* 不要用 `echo command | ssh` 替代 `run_remote.py`：堡垒机菜单按单字符 raw 读取，管道输入会被响铃拒绝。
* 保留旧式主机密钥所需的 ssh 选项：
```text
-o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa
```

## 脚本
* `scripts/reserve_port.ps1`：一次性把本地 `2222` 持久预留给本机（`store=persistent`），免疫 winnat 动态占用；幂等，需管理员。
* `scripts/relay.ps1`：Windows 侧 TCP 转发，本地 `2222` -> 堡垒机 `10.13.0.20:2222`；绑定失败会打印长期修复指引并暂停（不闪退）。
* `scripts/session_server.py`：常驻会话守护进程，登录一次并通过 Unix socket（`/tmp/cqmu_session.sock`）接收命令即时执行；含心跳保活与掉线自动重登。
* `scripts/session_ctl.sh`：常驻会话一键 `start|stop|restart|status`。
* `scripts/run_remote.py`：发命令入口。守护进程在线走极速通道，否则自动一次性登录执行。
