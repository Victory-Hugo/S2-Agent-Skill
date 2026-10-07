---
name: cqmu-supercomputing-remote-trans
description: 使用SFTP协议连接中科大重医超算传输数据。
---

# 中科大重医超算 远程传输

仅能使用 SFTP 协议传输数据。

## 连接参数

```sh
主机：10.13.0.20
端口：2222
用户名：CQMU_Luolintao@CQMU_Luolintao@20.11.100.2
密码：lRz(34+*JK1m
```

## 前提

1. 先连 VPN `https://222.178.193.70:8887`，否则 `10.13.0.20` 不可达。
2. 客户端跑在 Windows 侧（Windows 主机有 VPN 路由可直达堡垒机），WSL 直连不通。

## 命令行测连（WinSCP.com，凭据 URL 编码内嵌）

```sh
"/mnt/c/Program Files (x86)/WinSCP/WinSCP.com" /ini=nul /script=脚本.txt
```

脚本内容：

```
option batch abort
option confirm off
open sftp://CQMU_Luolintao%40CQMU_Luolintao%4020.11.100.2:lRz%2834%2B%2AJK1m@10.13.0.20:2222/ -hostkey="*"
pwd
ls
exit
```

- URL 编码：`@`→`%40` `(`→`%28` `+`→`%2B` `*`→`%2A`。
- 此版 WinSCP 的 `open` 不支持 `-username`，必须 URL 内嵌。输出为 UTF-8。
- 脚本含明文密码，用完即删。

## ⚠️ 必看坑：目标机 `.bashrc` 会打断 SFTP 握手

SFTP 登录时目标机执行 `.bashrc`，其中 **conda 初始化 / 中文注释 / 任何 `echo`** 往通道吐字节，会污染 SFTP 二进制握手。症状：SSH 通道已开却永远收不到 `SSH_FXP_VERSION`，无限超时连不上。

修复——让非交互登录的 shell 保持静默，在 `.bashrc` 顶部加：

```bash
case $- in
  *i*) ;;        # 交互式才继续
    *) return ;; # 非交互（SFTP/scp）直接返回
esac
# conda 初始化、提示符、别名等放此行之后
```

诊断时认 WinSCP `/loglevel=2` 日志的协议时间线最准。
