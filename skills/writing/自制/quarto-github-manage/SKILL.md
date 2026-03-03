---
name: quarto-github-repo-structure
description: "组织Quarto文件内容结构至Github要求。确保用户通过`quarto use template`命令获得可立即渲染的项目。"
---

# Quarto 模板仓库结构

遵循此工作流，生成用户可立即实例化并渲染的仓库。

## 输入

收集以下信息：
- `template_kind`：`project | format_extension | project_type_extension`
- `github_owner`
- `repo_name`

按需收集可选字段：
- `extension_name`（kebab-case 格式，通常与 `repo_name` 一致）
- `project_type_base`（`default | website | book`，用于 `project_type_extension`）
- `entry_file` 覆盖值

## 选择唯一架构

每个仓库只使用以下模式之一：
- `project`：仅含起始脚手架
- `format_extension`：格式/期刊扩展 + 起始稿件
- `project_type_extension`：自定义项目类型 + 起始项目文件

## 遵守不可协商的规则

- 将所有 Quarto 扩展放在 `_extensions/<extension_name>/` 下。
- 将 `_extension.yml` 放在 `_extensions/<extension_name>/` 内。
- 将用户关键起始文件保留在仓库根目录。
- 不依赖 `README.md` 或 `LICENSE` 提供实例化项目必要内容。
- 在仓库根目录使用 `.quartoignore` 排除仅供开发使用的文件。

明确处理复制行为：
- `quarto use template` 会复制大多数文件。
- 隐藏文件/目录及 `README.md`、`LICENSE` 等常见仓库文件默认不被复制。
- `.quartoignore` 添加显式排除项。

## 生成仓库布局

### 模式 A：`template_kind = project`

必须位于根目录的文件：
- `_quarto.yml`
- `index.qmd`

可选的根目录文件/目录：
- `about.qmd`
- `styles.css` 或 `theme.scss`
- `images/`
- `data/`
- `.quartoignore`

### 模式 B：`template_kind = format_extension`

必须位于根目录的文件：
- `template.qmd`
- `_extensions/<extension_name>/_extension.yml`

可选文件：
- `bibliography.bib`
- `_extensions/<extension_name>/preamble.tex`（LaTeX 格式常用）
- `_extensions/<extension_name>/partials/`
- `_extensions/<extension_name>/*.cls`
- `_extensions/<extension_name>/*.csl`
- `_extensions/<extension_name>/theme.scss` 或 `*.css`
- `_extensions/<extension_name>/filter.lua`
- `.quartoignore`

将 `template.qmd` 保留在仓库根目录，以便用户在执行 `quarto use template` 后直接获得起始文档。

#### `_extension.yml` 必要字段（format_extension 示例）

```yaml
title: <扩展显示名称>
author: <作者>
version: 0.1.0
quarto-required: ">=1.4.0"
contributes:
  formats:
    <extension_name>-pdf:        # 格式名称，用户在 YAML 中用 format: <extension_name>-pdf
      pdf-engine: xelatex        # 或 pdflatex / lualatex
      documentclass: ctexart     # LaTeX 文档类
      include-in-header: preamble.tex   # 相对于 _extension.yml 的路径
```

关键约束：
- `contributes: formats:` 下的键即为用户调用的格式名，建议使用 `<extension_name>-<output>` 形式。
- `include-in-header`、`*.cls` 等路径均**相对于 `_extension.yml` 所在目录**，不要写绝对路径。
- `template.qmd` 中引用扩展内文件时，路径写为 `_extensions/<github_owner>/<extension_name>/preamble.tex`（本地渲染）；发布后用户通过 `quarto use template` 获取文件，路径自动变为本地。

#### 目录树示例（以 `ctexart_1` 为例）

```
ctexart_1/                        ← 仓库根目录
├── template.qmd                  ← 用户起始文档（必须）
├── example.bib                   ← 示例参考文献（可选，但推荐提供）
├── README.md                     ← 仓库说明（不会被复制）
└── _extensions/
    └── ctexart_1/                ← extension_name 与仓库名一致
        ├── _extension.yml        ← 扩展元数据与格式定义（必须）
        └── preamble.tex          ← LaTeX 导言区（由 _extension.yml 引用）
```

### 模式 C：`template_kind = project_type_extension`

必须位于根目录的文件：
- `_quarto.yml`
- `index.qmd`
- `_extensions/<extension_name>/_extension.yml`

可选的根目录或扩展文件：
- 附加页面（例如 `team.qmd`）
- `_extensions/<extension_name>/theme.scss`
- `_extensions/<extension_name>/filter.lua`
- `_extensions/<extension_name>/logo.png`
- `.quartoignore`

在根目录 `_quarto.yml` 中将 `project: type:` 指向自定义项目类型。在 `_extension.yml` 中声明贡献的项目类型，并继承自 `default`、`website` 或 `book`。

## 执行顺序

1. 根据输入确定 `template_kind`。
2. 仅使用匹配的模式生成仓库目录树（以 Markdown 代码块形式输出给用户确认）。
3. 将所有必需的起始文件放置在根目录。
4. 若基于扩展，先创建 `_extensions/<extension_name>/_extension.yml`（填写完整字段），再添加引用的资源文件（如 `preamble.tex`）。
5. 在 `template.qmd` 的 YAML 头中使用扩展格式名（如 `format: ctexart_1-pdf`），并确保所有引用路径正确。
6. 根据需要为 CI/测试/开发产物添加 `.quartoignore`。
7. 输出必需/可选文件清单及验证命令。

## 验证清单

在干净目录中进行验证：
1. 运行 `quarto use template <github_owner>/<repo_name>`。
2. 确认生成目录中存在 `template.qmd`（模式 B）或 `index.qmd`（模式 A/C）。
3. 对于基于扩展的模式，确认 `_extensions/<extension_name>/_extension.yml` 存在且字段完整。
4. 运行 `quarto render template.qmd`（或对应入口文件）且无致命错误。
5. 确认没有关键文件仅存在于隐藏路径、`README.md` 或 `LICENSE` 中。

## 参考资料

行为不明确时使用以下官方文档：
- https://quarto.org/docs/extensions/starter-templates.html
- https://quarto.org/docs/extensions/project-types.html
- https://quarto.org/docs/journals/formats.html
- https://quarto.org/docs/extensions/distributing.html
