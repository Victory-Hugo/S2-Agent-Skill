# 06 - Common Recipes

## Recipe 1: 分组均值 + SEM + 原始点

```r
library(tidyplots)

study |>
  tidyplot(x = treatment, y = score, color = treatment) |>
  add_data_points_beeswarm(alpha = 0.8) |>
  add_mean_dash() |>
  add_sem_errorbar() |>
  adjust_title("Grouped mean with SEM") |>
  save_plot("recipe_grouped_sem.pdf")
```

## Recipe 2: 热图 + row z-score + 排序

```r
library(tidyplots)

gene_expression |>
  tidyplot(x = sample, y = external_gene_name, color = expression) |>
  add_heatmap(scale = "row") |>
  sort_y_axis_levels(direction) |>
  adjust_size(height = 100) |>
  save_plot("recipe_heatmap_row_zscore.pdf")
```

兼容备选（旧命名环境）：`sort_y_axis_labels(direction)`。

## Recipe 3: 显著性标注（Wilcoxon + BH）

```r
library(tidyplots)

study |>
  tidyplot(x = dose, y = score, color = group) |>
  add_data_points() |>
  add_mean_dash() |>
  add_sem_errorbar() |>
  add_test_pvalue(method = "wilcoxon", p.adjust.method = "BH", hide.ns = TRUE) |>
  save_plot("recipe_stat_compare.pdf")
```

## Recipe 4: 多图分面导出

```r
library(tidyplots)

gene_expression |>
  dplyr::filter(external_gene_name %in% c("Apol6", "Bsn", "Vgf", "Mpc2")) |>
  tidyplot(x = condition, y = expression, color = sample_type) |>
  add_data_points_beeswarm() |>
  add_mean_dash() |>
  add_sem_errorbar() |>
  add_test_asterisks(hide_info = TRUE) |>
  adjust_size(width = 30, height = 25) |>
  split_plot(by = external_gene_name, ncol = 2, nrow = 2) |>
  save_plot("recipe_split_multiplot.pdf")
```

## Recipe 5: 色盲友好出版配色

```r
library(tidyplots)

energy |>
  tidyplot(x = year, y = energy, color = energy_source) |>
  add_barstack_relative() |>
  adjust_colors(colors_discrete_friendly) |>
  theme_minimal_y() |>
  save_plot("recipe_colorblind_friendly.pdf")
```

## Recipe 6: 常见报错最短修复

### 报错：`could not find function "tidyplot"`

```r
library(tidyplots)
```

### 报错：包不存在

```r
install.packages("tidyplots")
install.packages("tidyverse")
```

### 报错：列名不存在

```r
colnames(your_data)
```

并同步修正 `tidyplot(x = ..., y = ..., color = ...)` 的列映射。
