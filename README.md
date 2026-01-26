# S2-Agent-Skill

Agent 技能库集合，为 Claude 提供结构化的工具和最佳实践指南。

## 项目概述

S2-Agent-Skill 是一个模块化技能库，包含针对不同数据处理和编程任务的标准化指南和工具。每个技能都包含详细的文档、代码示例和最佳实践，帮助 AI Agent 在特定领域中高效完成任务。

## 如何使用

### Codex 为例
首先进入 `Codex` 的配置页面，按照以下步骤操作：

```bash
cd /home/[你的文件夹]/.codex/
ls
tree -L 1
# .
# ├── archived_sessions
# ├── auth.json
# ├── config.toml
# ├── models_cache.json
# ├── sessions
# ├── skills
# └── tmp
```
在这里有一个 `skills` 目录，用于存放 Agent 技能。将`Github`中所有的Skill全部放到`/skills/.system`中
编辑`config.toml`，添加如下配置：

```toml
[[skills.config]]
path = "/home/[你的文件夹]/.codex/skills/"
enabled = true
```

保存后，重启 Codex 应用即可加载新的技能库。