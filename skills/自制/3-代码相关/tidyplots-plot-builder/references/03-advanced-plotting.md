# 03 - Advanced Plotting

来源：Notion 页面《Tidyplots 高级绘图》
- https://www.notion.so/2de164434e4981489a64e3c74f797843

## 栅格化（大图加速）

```r
gene_expression |>
  tidyplot(x = sample, y = external_gene_name, color = expression) |>
  add_heatmap(scale = "row", rasterize = TRUE, rasterize_dpi = 300)
```

建议：
- 打印导出建议 `rasterize_dpi >= 300`
- 仅栅格化重负载图层（散点/热图）

## 自定义统一风格

```r
my_style <- function(p) {
  p |>
    adjust_colors(colors_continuous_bluepinkyellow) |>
    adjust_font(family = "mono", face = "bold") |>
    remove_x_axis_ticks() |>
    remove_y_axis_ticks()
}
```

## 绘图阶段数据子集

```r
animals |>
  tidyplot(x = weight, y = size) |>
  add_data_points() |>
  add_data_points(data = filter_rows(size > 300), color = "red")
```

常见用途：
- 背景画全体数据
- 前景高亮 topN/阈值数据

## 管道中间结果与多变体

```r
study |>
  tidyplot(x = treatment, y = score, color = treatment) |>
  add_mean_dash() |>
  save_plot("stage_1.pdf") |>
  add_sem_errorbar() |>
  save_plot("stage_2.pdf")
```

## 配对数据

```r
study |>
  tidyplot(x = treatment, y = score, color = group) |>
  add_mean_dash() |>
  add_sem_errorbar() |>
  add_line(group = participant, color = "grey") |>
  add_data_points()
```

## 缺失值与结构性 0

```r
animals |>
  tidyplot(x = number_of_legs, color = family) |>
  add_areastack_absolute(replace_na = TRUE)
```

说明：`replace_na = TRUE` 可避免堆叠面积图中类别“消失”。

## 多图布局

```r
gene_expression |>
  dplyr::filter(external_gene_name %in% c("Apol6", "Bsn", "Vgf", "Mpc2")) |>
  tidyplot(x = condition, y = expression, color = sample_type) |>
  add_mean_dash() |>
  add_sem_errorbar() |>
  add_data_points_beeswarm() |>
  split_plot(by = external_gene_name, ncol = 2, nrow = 2)
```

关键规则：`split_plot()` 放到最后（之后仅接 `save_plot()`）。

## 方向、留白、dodge

- 方向：`orientation = "x"` 或 `"y"`
- 留白：`adjust_padding()` / `remove_padding()`
- 组间距：`dodge_width`

## ggplot2 兼容

```r
study |>
  tidyplot(x = treatment, y = score, color = treatment) |>
  add_mean_bar(alpha = 0.4) |>
  add(ggplot2::geom_point())
```

说明：可混用但需谨慎，复杂场景尽量保持单一体系。

## 官方参考

- Advanced plotting：https://jbengler.github.io/tidyplots/articles/Advanced-plotting.html
