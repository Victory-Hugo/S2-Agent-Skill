---
name: tidyplots-plot-builder
description: 使用 tidyplots 编写、修改或排查 R 绘图代码时使用，包括图形生成、配色、统计标注、分面、多图排版及图片导出。
---

# tidyplots 绘图规范

## 工作流程

按以下顺序组织代码：

1. `tidyplot(...)`
2. 一个或多个 `add_*()`
3. 必要时使用 `remove_*()` 或 `adjust_*()`
4. 分面时最后使用 `split_plot()`
5. 导出时使用 `save_plot()`

`split_plot()` 之后通常只允许调用 `save_plot()`。

## 输出要求

优先提供可直接运行的最简代码，必须包含：

```r
library(tidyplots)

tidyplot(...) |>
  add_*()
```

根据需要补充配色、统计标注、分面和导出代码。仅在发生报错时提供排错说明。

## 命名兼容

优先使用新版函数：

* `rename_*_levels`
* `reorder_*_levels`
* `sort_*_levels`
* `reverse_*_levels`

用户使用旧版 `*_labels` 函数时，说明命名差异并改为当前版本可用写法。

## 排错顺序

1. 检查 `tidyplots` 是否安装并加载
2. 检查数据框和列名
3. 检查管道顺序
4. 检查 `split_plot()` 的位置
5. 检查统计检验参数

## 参考文档

仅按任务读取必要文件：

* 基础流程：`references/01-get-started.md`
* 图形和统计：`references/02-visualizing-data.md`
* 高级绘图：`references/03-advanced-plotting.md`
* 配色：`references/04-color-schemes.md`
* 函数索引：`references/05-function-index.md`
* 常用模板：`references/06-common-recipes.md`
