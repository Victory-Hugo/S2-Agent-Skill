# notion MCP（HTTP）集成指南

## 介绍

Notion MCP（HTTP）集成允许 Claude Code 或者 Codex 通过 HTTP 协议与 Notion 进行交互，实现数据的读取和写入。通过以下步骤，您可以将 Notion MCP 集成到 Claude Code / Codex 中。

## 给 Claude Code 添加 Notion MCP

```sh
claude mcp add --transport http notion https://mcp.notion.com/mcp --scope user
```


# 2) 确认已添加

```sh
claude mcp list
claude mcp get notion
```

然后启动 Claude Code，在对话里输入：

```sh
/mcp
```

按菜单对 notion 做 OAuth 登录（会打开浏览器授权）。

授权成功后，您就可以在 Claude Code 中使用 Notion MCP 了：

```sh
❯ /mcp 
  ⎿  Authentication successful. Connected to notion.

❯ /mcp list                                                                                           
                                                                                                      
──────────────────────────────────────────────────────────────────────────────────────────────────────
  Manage MCP servers                                                                                  
  1 server
                                                                                                      
    User MCPs (/home/luolintao/.claude.json)                                                          
  ❯ notion · ✔ connected

  https://code.claude.com/docs/en/mcp for help
 ↑↓ to navigate · Enter to confirm · Esc to cancel
```

## 给 Codex 添加 Notion MCP

推荐使用 `Codex` IDE 插件来管理 MCP 集成，以下是添加 Notion MCP 的步骤：

1. 打开 `Codex` 插件，在左下角找到 `+` 选项。
2. 点击 `MCP` 快捷方式，加入 Notion MCP。
3. 按照提示完成 OAuth 登录，授权成功后即可使用 Notion MCP。

## 使用 Notion MCP

