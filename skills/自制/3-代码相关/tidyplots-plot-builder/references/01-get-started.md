# 01 - Get Started

来源：Notion 页面《Tidyplots 入门》
- https://www.notion.so/2de164434e4981c0904cc8d7a12e0da0

## 快速启动

```r
library(tidyplots)

study |>
  tidyplot(x = treatment, y = score) |>
  add_data_points()
```

## 核心工作流

1. 初始化：`tidyplot(x = ..., y = ..., color = ...)`
2. 添加图层：`add_*()`
3. 移除默认元素：`remove_*()`
4. 微调展示：`adjust_*()`
5. 分面：`split_plot()`（必须末尾）
6. 输出：`save_plot("xxx.pdf")`

## 高价值函数

- 数据点：`add_data_points()` `add_data_points_jitter()` `add_data_points_beeswarm()`
- 集中趋势：`add_mean_bar()` `add_mean_dash()`
- 误差表达：`add_sem_errorbar()`
- 主题：`theme_tidyplot()` `theme_ggplot2()` `theme_minimal_y()`
- 导出：`save_plot()`

## 常见参数

- `alpha`：透明度
- `shape`：点形状（`1` 常为空心点）
- `width` / `height`：`adjust_size()` 的绘图区尺寸（mm）
- `new_colors`：`adjust_colors()` 的配色输入

## 典型陷阱

1. 忘记加载包：
- 现象：`could not find function "tidyplot"`
- 处理：先执行 `library(tidyplots)`

2. `split_plot()` 放在中间：
- 现象：后续 add/remove/adjust 行为异常
- 处理：将 `split_plot()` 放到最后，仅在其后接 `save_plot()`

3. 图太挤：
- 处理：优先用 `adjust_size(width = ..., height = ...)` 和 `adjust_x_axis(rotate_labels = TRUE)`

## 推荐最小模板

```r
library(tidyplots)

study |>
  tidyplot(x = treatment, y = score, color = treatment) |>
  add_data_points_beeswarm() |>
  add_mean_dash() |>
  add_sem_errorbar() |>
  save_plot("study_grouped_summary.pdf")
```

## 官方参考

- 包索引：https://jbengler.github.io/tidyplots/reference/index.html
- 入门文档：https://jbengler.github.io/tidyplots/articles/Getting-started.html
