---
name: tidyplots-plot-builder
description: 生成和修复基于 tidyplots 的 R 绘图工作流。用于用户要求使用 tidyplots 包进行绘图、改图、配色优化、统计标注、分面输出、导出 PDF/PNG、多图排版、报错排查（如找不到函数/包）等场景。输入可以是数据结构描述、列名、目标图形类型、风格约束或期刊图规范。
---

# tidyplots-plot-builder

## Overview

将用户的绘图目标转成可直接运行的 tidyplots 代码，优先提供最小可运行版本，再给增强版本与排错路径。统一采用 tidyplots 管道式工作流并保持 `split_plot()` 在末尾阶段。

## Execution Workflow

1. 明确任务类型：
- 新建图：从 0 生成绘图代码。
- 改图：在现有管道上新增或移除图层。
- 调试：修复包、函数、列名、统计检验或导出问题。

2. 明确输入最小集：
- 数据来源：数据框对象名或文件加载方式。
- 列映射：`x`、`y`、`color`。
- 图目标：例如散点、均值+误差线、热图、比例、显著性比较。

3. 固定绘图顺序：
- `tidyplot(...)`
- 一个或多个 `add_*()`
- 必要时 `remove_*()`
- 必要时 `adjust_*()`
- 需要分面时最后调用 `split_plot()`
- 导出时调用 `save_plot()`

4. 输出策略：
- 先输出最小可运行代码。
- 再输出增强代码（主题、配色、注释、导出）。
- 最后给常见错误修复指引。

## Output Contract

始终按以下结构输出：

1. `最小可运行代码`
2. `增强版代码`（可选）
3. `排错清单`

最小可运行代码中必须出现：
- `library(tidyplots)`
- 至少一个 `tidyplot(...)`
- 至少一个 `add_*()`

## Version Compatibility Rule

优先使用 tidyplots 新命名：
- `rename_*_levels`
- `reorder_*_levels`
- `sort_*_levels`
- `reverse_*_levels`

若用户使用旧文档中的 `*_labels` 命名，明确给出兼容说明：
- 先解释旧新命名差异。
- 再给出当前环境可运行写法。

## Debug Priority

遇到报错时按以下顺序排查：

1. 包加载：`library(tidyplots)`、`library(tidyverse)`。
2. 环境检查：运行 `scripts/check_tidyplots_env.R`。
3. 列名检查：确认 `x`/`y`/`color` 在数据框中存在。
4. 管道顺序：确认 `split_plot()` 仅在末尾（之后仅允许 `save_plot()`）。
5. 统计层：`add_test_pvalue()` 的方法、分组与参考组参数。

## Script Usage

### 快速环境检查

```bash
Rscript scripts/check_tidyplots_env.R
```

### 生成模板脚本

```bash
Rscript scripts/new_tidyplot_template.R \
  --mode grouped-summary \
  --dataset study \
  --x treatment \
  --y score \
  --color treatment \
  --output /tmp/tidyplot_example.R
```

## Reference Loading Guide

按任务读取最少必要 references：

- 入门和标准流程：`references/01-get-started.md`
- 常见图形和统计表达：`references/02-visualizing-data.md`
- 栅格化、子集、多图、兼容性：`references/03-advanced-plotting.md`
- 内置与自定义配色：`references/04-color-schemes.md`
- 函数速查：`references/05-function-index.md`
- 可复用任务模板：`references/06-common-recipes.md`

仅在对应任务需要时读取相关文件，不要一次性加载全部参考文档。
