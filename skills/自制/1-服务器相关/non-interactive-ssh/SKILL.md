---
name: non-interactive-ssh
description: 以非交互式SSH方式连接远程服务器，执行命令并返回结果。
---

# 非交互式 SSH 连接技能
## 作用
本技能用于协助 AI agent 通过非交互式 SSH 方式连接多个远程服务器，在远程服务器上执行命令，并返回标准输出、标准错误和退出状态。

## 重要要求
1. 执行远程命令时必须使用非交互式方式，避免进入交互式 shell（始终使用 `ssh -T`）。
2. 连接前检查 `~/.ssh/config` 是否已配置目标服务器：
   - **若已配置**：直接使用 `sshpass` + `ssh` 连接，无需额外参数。
   - **若未配置**：参考 `~/.ssh/0-服务器.key.md` 中的命令示例，直接使用完整命令连接，不必先写入 SSH config。
3. 认证方式按 key.md 中的 `auth_methods` 字段决定：
   - `password`：使用 `sshpass -p 'password' ssh ...` 传入密码。
   - `public_key`：使用 `-i IdentityFile` 密钥登录。
4. 对于需要跳板机的服务器（key.md 中注释有"必须通过跳板机"），连接时必须加 ProxyCommand，格式见 key.md 末尾的命令示例。
5. 首次连接时使用 `-o StrictHostKeyChecking=accept-new` 自动信任新指纹，无需手动确认。

## SSH 配置文件
默认 SSH 配置文件位置：
```sh
~/.ssh/config
```

## 已配置服务器
请访问 `~/.ssh/0-服务器.key.md` 文件查看已配置的服务器列表、连接信息和命令示例。

## 使用 sudo 执行命令
如果远程命令需要 sudo，应使用非交互式方式传入 sudo 密码：
```sh
sshpass -p 'password' ssh -T user@host 'echo "sudopass" | sudo -S <command>'
```


## 提示
1. 香港中文大学服务器c2：`conda`路径为`/pool/wang/leiyao/miniforge3/bin/conda`，优先使用`BigLin`环境。完成任务后使用`/mnt/d1/pool/wang/leiyao/7-luolintao/text_email.py`发送邮件通知。
