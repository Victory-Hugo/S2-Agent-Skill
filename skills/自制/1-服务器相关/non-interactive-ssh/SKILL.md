---
name: non-interactive-ssh
description: 非交互式SSH连接及备用方案；优先使用 OpenSSH ControlMaster 复用持久化连接，失败时回退至非交互式 SSH。
---

# SSH 远程连接技能

## 作用
协助 AI Agent 高效连接远程服务器，执行命令并获取标准输出、标准错误和退出状态。

## 核心要求

1. **优先使用 OpenSSH ControlMaster**，复用已有 SSH 连接，避免重复握手和认证。若无法建立或复用主连接，自动回退至普通非交互式 SSH。
2. 所有命令均使用 `ssh -T`，不进入交互式 Shell。
3. 优先读取 `~/.ssh/config` 中的服务器配置；未配置时，使用 `~/.ssh/0-服务器.key.md` 中的完整连接命令。
4. 认证方式依据 `key.md` 中的 `auth_methods`：
   - `password`：使用 `sshpass` 认证。
   - `public_key`：使用 `-i IdentityFile` 认证。
5. 需要跳板机或 SOCKS 代理时，保留原有 `ProxyCommand`，不得绕过代理。
6. 首次连接使用 `StrictHostKeyChecking=accept-new`，自动接受新主机指纹，保留已有指纹校验。

## 连接复用

首次连接时，优先建立持久化主连接：

```bash
mkdir -p ~/.ssh/cm
chmod 700 ~/.ssh/cm
ssh -T -o ControlMaster=auto \
  -o ControlPath=~/.ssh/cm/%C \
  -o ControlPersist=2h \
  -o ConnectTimeout=10 \
  -o BatchMode=yes \
  <host> '<command>'
```

后续命令复用相同连接参数。使用 `ssh -O check` 检查主连接状态。

**执行策略：**
- 已有主连接时直接复用，不重复认证。
- 没有主连接时自动建立。
- 密码认证的首次连接使用 `sshpass`，并设置 `BatchMode=no`；后续优先复用。
- ControlMaster 失败时，移除连接复用参数，回退普通 `ssh -T`。
- 每条命令设置合理超时；连接失败及时返回错误，避免无意义等待。
- 优先批量执行相关命令，减少 SSH 调用次数。
- 不主动关闭仍可复用的主连接。

## 服务器信息

SSH 配置：`~/.ssh/config`

服务器列表、认证信息及连接示例：`~/.ssh/0-服务器.key.md`

## sudo

需要 sudo 时，优先使用免密码 sudo；否则通过 `sudo -S` 从标准输入传递密码，避免将密码直接写入命令参数或日志。